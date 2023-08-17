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

    var body: some View {
        
        GeometryReader { geometry in
            ViewfinderView(image: $model.viewfinderImage)
        }
        .task {
            await model.camera.start()
        }
//        .ignoresSafeArea()
    }
}
