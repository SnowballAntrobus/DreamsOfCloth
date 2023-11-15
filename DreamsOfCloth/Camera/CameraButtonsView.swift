//
//  CameraButtonsView.swift
//  DreamsOfCloth
//
//  Adapted by Dante Gil-Marin on 11/13/23 from:
//  https://developer.apple.com/tutorials/sample-apps/capturingphotos-camerapreview
//

import SwiftUI

struct CameraButtonsView: View {
    @StateObject var model: ImageCaptureModel
    var body: some View {
        HStack {
            Button {
                model.camera.takePhoto()
            } label: {
                Label {
                    Text("Take Photo")
                } icon: {
                    ZStack {
                        Circle()
                            .strokeBorder(.green, lineWidth: 3)
                            .frame(width: 62, height: 62)
                        Circle()
                            .fill(.green)
                            .frame(width: 50, height: 50)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
    }
}
