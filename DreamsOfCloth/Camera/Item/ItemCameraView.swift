//
//  ItemCameraView.swift
//  DreamsOfCloth
//
//  Adapted by Dante Gil-Marin on 8/16/23 from:
//  https://developer.apple.com/tutorials/sample-apps/capturingphotos-camerapreview
//

import SwiftUI

struct ItemCameraView: View {
    @StateObject private var model: ItemCaptureModel = ItemCaptureModel()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if model.displayImage != nil {
                    EditCaptureView(displayImage: $model.displayImage, photoData: model.photoData)
                        .onAppear {
                            model.camera.isPreviewPaused = true
                        }
                        .onDisappear {
                            model.camera.isPreviewPaused = false
                        }
                } else {
                    ItemViewfinderView(viewfinderImage: $model.viewfinderImage, isSwitchingCaptureDevice: $model.isSwitchingCaptureDevice, poseModel: model.poseDetectionModel)
                        .frame(width: geometry.size.width, height: geometry.size.width * CGFloat(model.getViewfinderImageAspectRatio()))
                    
                    ItemCameraButtonsView(model: model)
                        .frame(height: geometry.size.height * 1.8)
                }
            }
            .task {
                await model.camera.start()
            }
        }
        .navigationTitle("Camera")
    }
}
