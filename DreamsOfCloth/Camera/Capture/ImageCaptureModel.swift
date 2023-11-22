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
    @Published var thumbnailImage: Image?
    
    init() {
        Task {
            await handleCameraPreviews()
        }
        Task {
            await handleCameraPhotos()
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
            Task { @MainActor in
                thumbnailImage = photoData.thumbnailImage
            }
            self.photoData = photoData
        }
    }
    
    func rejectPhoto() {
        self.thumbnailImage = nil
        logger.debug("Rejected photo")
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
        
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        
        logger.debug("Unpacked photo of size:(\(imageSize.width), \(imageSize.height)) and thumbnail of size:(\(thumbnailSize.width), \(thumbnailSize.height))")
        
        return PhotoData(thumbnailImage: thumbnailImage, thumbnailSize: thumbnailSize, imageData: imageData, imageSize: imageSize)
    }
    
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
