//
//  CameraView.swift
//  DreamsOfCloth
//
//  Adapted by Dante Gil-Marin on 8/16/23 from:
//  https://developer.apple.com/tutorials/sample-apps/capturingphotos-camerapreview
//

import SwiftUI

struct CameraView: View {
    @StateObject private var model = ImageCaptureModel()
    
    private static let barHeightFactor = 0.15

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
                    ViewfinderView(viewfinderImage: $model.viewfinderImage)
                        .overlay(alignment: .bottom) {
                            CameraButtonsView(model: model)
                                .frame(height: geometry.size.height * Self.barHeightFactor)
                        }
                }
            }
            .task {
                await model.camera.start()
            }
        }
        .navigationTitle("Camera")
    }
}
