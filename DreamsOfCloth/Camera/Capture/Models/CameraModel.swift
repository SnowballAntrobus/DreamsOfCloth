//
//  CameraModel.swift
//  DreamsOfCloth
//
//  Adapted by Dante Gil-Marin on 8/15/23 from:
//  https://developer.apple.com/tutorials/sample-apps/capturingphotos-camerapreview
//

import UIKit
import AVFoundation
import os.log

class CameraModel: NSObject {
    private let captureSession = AVCaptureSession()
    private var sessionQueue: DispatchQueue!
    private var isCaptureSessionConfigured = false
    private var deviceInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var photoOutput: AVCapturePhotoOutput?
    private var isUsingFrontCaptureDevice = true
    
    private var qualityPrioritization: AVCapturePhotoOutput.QualityPrioritization = .balanced

    private var captureDevices: [AVCaptureDevice] {
        var devices = [AVCaptureDevice]()
        if let frontDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            devices += [frontDevice]
            logger.debug("Found front capture device")
        }
        if let backDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            devices += [backDevice]
            logger.debug("Found back capture device")
        }
        if devices.isEmpty {
            logger.debug("Did not find any capture devices")
        }
        return devices
    }

    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            logger.debug("Using capture device: \(captureDevice.localizedName)")
            sessionQueue.async {
                self.updateSessionForCaptureDevice(captureDevice)
            }
        }
    }
    
    private var availableCaptureDevices: [AVCaptureDevice] {
        captureDevices
            .filter( { $0.isConnected } )
            .filter( { !$0.isSuspended } )
    }
    
    var isRunning: Bool {
        captureSession.isRunning
    }
    
    private var addToPreviewStream: ((CIImage) -> Void)?
    
    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?
    
    var isPreviewPaused = false
    
    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { ciImage in
                if !self.isPreviewPaused {
                    continuation.yield(ciImage)
                }
            }
        }
    }()
    
    lazy var photoStream: AsyncStream<AVCapturePhoto> = {
        AsyncStream { continuation in
            addToPhotoStream = { photo in
                continuation.yield(photo)
            }
        }
    }()
    
    override init() {
        super.init()
        initialize()
    }
    
    private func initialize() {
        sessionQueue = DispatchQueue(label: "Camera Session Queue")
        
        var availableCaptureDevice = availableCaptureDevices.first
        
        if availableCaptureDevice == nil {
            availableCaptureDevice = AVCaptureDevice.default(for: .video)
            logger.debug("No available capture devices using default video instead")
        }
        captureDevice = availableCaptureDevice
    }
    
    private var deviceOrientation: UIDeviceOrientation = UIDeviceOrientation.portrait;
    
    private var videoOrientation: AVCaptureVideoOrientation = AVCaptureVideoOrientation.portrait;
    
    private func deviceInputFor(_ device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let error {
            logger.error("Error getting capture device input: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            logger.debug("Camera access authorized.")
            return true
        case .notDetermined:
            logger.debug("Camera access not determined.")
            sessionQueue.suspend()
            let status = await AVCaptureDevice.requestAccess(for: .video)
            sessionQueue.resume()
            return status
        case .denied:
            logger.debug("Camera access denied.")
            return false
        case .restricted:
            logger.debug("Camera library access restricted.")
            return false
        @unknown default:
            return false
        }
    }
    
    private func getMaxPhotoDimensions() -> CMVideoDimensions? {
        guard let captureDevice = captureDevice else {
            logger.error("Capture device is nil when getting max dimensions")
            return nil
        }
        
        let captureDeviceFormat = captureDevice.activeFormat
        let maxPhotoDimensions = captureDeviceFormat.supportedMaxPhotoDimensions[0]
        logger.debug("Max photo dimensions: (\(maxPhotoDimensions.width), \(maxPhotoDimensions.height))")
        
        return maxPhotoDimensions
    }
    
    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {
        var success = false
        
        self.captureSession.beginConfiguration()
        
        defer {
            self.captureSession.commitConfiguration()
            completionHandler(success)
        }
        
        guard let captureDevice = captureDevice, let deviceInput = deviceInputFor(captureDevice)
        else {
            logger.error("Failed to obtain video input.")
            return
        }
        
        let photoOutput = AVCapturePhotoOutput()
        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoDataOutputQueue"))
        
        guard captureSession.canAddInput(deviceInput) else {
            logger.error("Unable to add device input to capture session.")
            return
        }
        guard captureSession.canAddOutput(photoOutput) else {
            logger.error("Unable to add photo output to capture session.")
            return
        }
        guard captureSession.canAddOutput(videoOutput) else {
            logger.error("Unable to add video output to capture session.")
            return
        }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        
        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        self.videoOutput = videoOutput
        
        let maxPhotoDimensions = getMaxPhotoDimensions()
        guard let maxPhotoDimensions = maxPhotoDimensions else { return }
        photoOutput.maxPhotoDimensions = maxPhotoDimensions
        
        // is optical image stabilization on?
        photoOutput.maxPhotoQualityPrioritization = self.qualityPrioritization
        
        updateVideoOutputConnection()
        
        isCaptureSessionConfigured = true
        
        success = true
    }
    
    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice){
        guard isCaptureSessionConfigured else { return }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }
        
        if let deviceInput = deviceInputFor(captureDevice) {
            if !captureSession.inputs.contains(deviceInput), captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
        }
        
        updateVideoOutputConnection()
    }
    
    private func updateVideoOutputConnection() {
        if let videoOutput = videoOutput, let videoOutputConnection =
            videoOutput.connection(with: .video) {
            if videoOutputConnection.isVideoMirroringSupported {
                videoOutputConnection.isVideoMirrored = self.isUsingFrontCaptureDevice
            }
        }
    }
    
    func start() async {
        let authorized = await checkAuthorization()
        guard authorized else {
            logger.error("Camera access was not authorized.")
            return
        }
        
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                sessionQueue.async { [self] in
                    self.captureSession.startRunning()
                }
            }
            return
        }
        
        sessionQueue.async { [self] in
            self.configureCaptureSession { success in
                guard success else { return }
                self.captureSession.startRunning()
            }
        }
    }
    
    func stop() {
        guard isCaptureSessionConfigured else { return }
        
        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func takePhoto() {
        guard let photoOutput = self.photoOutput else { return }

        sessionQueue.async {
            var photoSettings = AVCapturePhotoSettings()
            
            // TODO: Determine if this is the best codec for usecase (it seems promising that apparently this one can store depth data)
            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }

            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
            photoSettings.flashMode = isFlashAvailable ? .auto : .off

            let maxPhotoDimensions = self.getMaxPhotoDimensions()
            guard let maxPhotoDimensions = maxPhotoDimensions else { return }
            photoSettings.maxPhotoDimensions = maxPhotoDimensions

            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }

            photoSettings.photoQualityPrioritization = self.qualityPrioritization

            if let photoOutputVideoConnection = photoOutput.connection(with: .video) {
                if photoOutputVideoConnection.isVideoOrientationSupported {
                    photoOutputVideoConnection.videoOrientation = self.videoOrientation
                }
            }

            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func switchCaptureDevice() {
        if let captureDevice = captureDevice, let index = availableCaptureDevices.firstIndex(of: captureDevice) {
            let nextIndex = (index + 1) % availableCaptureDevices.count
            self.isUsingFrontCaptureDevice = !self.isUsingFrontCaptureDevice
            logger.debug("Switching capture device to \(self.isUsingFrontCaptureDevice ? "front" : "back")")
            self.captureDevice = availableCaptureDevices[nextIndex]
        } else {
            self.captureDevice = AVCaptureDevice.default(for: .video)
            logger.debug("Could not find next capture device using default video instead")
        }
    }
    
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            logger.error("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        addToPhotoStream?(photo)
    }
}

extension CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = videoOrientation
        }
        
        addToPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
    }
}



fileprivate let logger = Logger(subsystem: "com.musa.DreamsOfCloth.camera", category: "CameraModel")
