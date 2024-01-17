//
//  ItemCaptureModel.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 1/16/24.
//

import SwiftUI

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
}

fileprivate extension CIImage {
    var image: CGImage? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil}
        return cgImage
    }
}
