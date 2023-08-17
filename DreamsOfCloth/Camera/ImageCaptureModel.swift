//
//  ImageCaptureModel.swift
//  DreamsOfCloth
//
//  Adapted by Dante Gil-Marin on 8/16/23 from:
//  https://developer.apple.com/tutorials/sample-apps/capturingphotos-camerapreview
//

import Foundation
import SwiftUI

final class ImageCaptureModel: ObservableObject {
    let camera = CameraModel()
    
    @Published var viewfinderImage: Image?
    
    init() {
        Task {
            await handleCameraPreviews()
        }
    }
    
    func handleCameraPreviews() async {
        let imageStream = camera.previewStream.map{ $0.image }
        
        for await image in imageStream {
            Task {
                @MainActor in viewfinderImage = image
            }
        }
    }
    
    
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil}
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}
