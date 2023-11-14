//
//  CameraButtonsView.swift
//  DreamsOfCloth
//
//  Adapted by Dante Gil-Marin on 11/13/23 from:
//  https://developer.apple.com/tutorials/sample-apps/capturingphotos-camerapreview
//

import SwiftUI

struct CameraButtonsView: View {
    var body: some View {
        HStack {
            Button {
                // fill in later
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

#Preview {
    CameraButtonsView()
}
