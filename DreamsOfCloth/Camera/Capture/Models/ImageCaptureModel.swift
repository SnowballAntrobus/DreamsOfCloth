//
//  ImageCaptureModel.swift
//  DreamsOfCloth
//
//  Adapted by Dante Gil-Marin on 8/16/23 from:
//  https://developer.apple.com/tutorials/sample-apps/capturingphotos-camerapreview
//

import SwiftUI
import AVFoundation
import os.log

final class ImageCaptureModel: ObservableObject {
    let camera = CameraModel()
    
    var photoData: PhotoData?
    
    @Published var viewfinderImage: Image?
    @Published var displayImage: Image?
    @Published var isSwitchingCaptureDevice: Bool = false
    
    init() {
        Task {
            await handleCameraPreviews()
        }
        Task {
            await handleCameraPhotos()
        }
    }
    
    func switchCamera() {
        self.isSwitchingCaptureDevice = true
        camera.switchCaptureDevice()
        //TODO: Consider change to delegate strategy so that we can have as short a delay as possible
        // Used to prevent visual glitch when device input is changed
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isSwitchingCaptureDevice = false
        }
    }
    
    func handleCameraPreviews() async {
        let imageStream = camera.previewStream.map{ $0.image }
        
        for await image in imageStream {
            Task { @MainActor in
                viewfinderImage = image
            }
        }
    }
    
    func handleCameraPhotos() async {
        let unpackedPhotoStream = camera.photoStream.compactMap { self.unpackPhoto($0) }
        
        for await photoData in unpackedPhotoStream {
            self.photoData = photoData
            Task { @MainActor in
                displayImage = photoData.thumbnailImage
            }
        }
    }
    
    private func unpackPhoto(_ photo: AVCapturePhoto) -> PhotoData? {
        guard let imageData = photo.fileDataRepresentation()
        else { return nil }
        
        guard let previewCGIImage = photo.previewCGImageRepresentation(),
              let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation)
        else { return nil }
        
        let imageOrientation = Image.Orientation(cgImageOrientation)
        let thumbnailImage = Image(decorative: previewCGIImage, scale: 1, orientation: imageOrientation)
        
        // We swap height and width since that is correct accroding to orientation
        // TODO: Is there a better way?
        let thumbnailSize = (width: Int(previewCGIImage.height), height: Int(previewCGIImage.width))
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.height), height: Int(photoDimensions.width))
        
        logger.debug("Unpacked photo of size:(width: \(imageSize.width), height: \(imageSize.height)) and thumbnail of size:(width: \(thumbnailSize.width), height: \(thumbnailSize.height)).")
        
        return PhotoData(thumbnailImage: thumbnailImage, thumbnailCGImage: previewCGIImage, thumbnailSize: thumbnailSize, imageOrientation: cgImageOrientation, imageData: imageData, imageSize: imageSize)
    }
    
}

struct PhotoData {
    var thumbnailImage: Image
    var thumbnailCGImage: CGImage
    var thumbnailSize: (width: Int, height: Int)
    var imageOrientation: CGImagePropertyOrientation
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil}
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

fileprivate extension Image.Orientation {

    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

fileprivate let logger = Logger(subsystem: "com.musa.DreamsOfCloth.capturingphotos", category: "ImageCaptureModel")
