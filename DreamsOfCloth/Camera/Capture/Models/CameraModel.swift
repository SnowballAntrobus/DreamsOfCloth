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

    
    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            logger.debug("Using capture device: \(captureDevice.localizedName)")
        }
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
        
        captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
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
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        let videoOutputConnection = videoOutput.connection(with: .video)
        videoOutputConnection?.isVideoMirrored = false
        
        isCaptureSessionConfigured = true
        
        success = true
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

            photoSettings.photoQualityPrioritization = .quality

            if let photoOutputVideoConnection = photoOutput.connection(with: .video) {
                if photoOutputVideoConnection.isVideoOrientationSupported {
                    photoOutputVideoConnection.videoOrientation = self.videoOrientation
                }
            }

            photoOutput.capturePhoto(with: photoSettings, delegate: self)
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
