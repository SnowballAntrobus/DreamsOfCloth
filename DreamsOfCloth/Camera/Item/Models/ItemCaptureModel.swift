//
//  ItemCaptureModel.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 1/16/24.
//

import SwiftUI
import os.log

final class ItemCaptureModel: ImageCaptureModel {
    @Published var poseDetectionModel: PoseDetectionModel
    
    override init() {
        poseDetectionModel = PoseDetectionModel()
        super.init()
    }
    
    override func handleCameraPreviews() async {
        let imageStream = camera.previewStream.map{ $0.image }
        
        for await image in imageStream {
            Task { @MainActor in
                guard let image = image else {
                    return
                }
                poseDetectionModel.performBodyPoseRequest(image)
                viewfinderImage = Image(decorative: image, scale: 1, orientation: .up)
            }
        }
    }
    
    override func handleCameraPhotos() async {
        let unpackedPhotoStream = camera.photoStream.compactMap { self.unpackPhoto($0) }
        
        for await photoData in unpackedPhotoStream {
            self.photoData = photoData
            Task { @MainActor in
                guard let fullSizeCaptureUIImage = UIImage(data: photoData.imageData), let fullSizeCaptureCGImage = fullSizeCaptureUIImage.cgImage else {
                    logger.debug("Could not turn photo data into cgimage for pose detection in item capture")
                    return
                }
                poseDetectionModel.performBodyPoseRequest(fullSizeCaptureCGImage)
                displayImage = photoData.thumbnailImage
            }
            logger.debug("Found pose points: \(self.poseDetectionModel.posePoints.allPoints)")
        }
    }
}

fileprivate extension CIImage {
    var image: CGImage? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil}
        return cgImage
    }
}

fileprivate let logger = Logger(subsystem: "com.musa.DreamsOfCloth.capturingitem", category: "ItemCaptureModel")
