//
//  ViewfinderView.swift
//  DreamsOfCloth
//
//  Adapted by Dante Gil-Marin on 8/16/23 from:
//  https://developer.apple.com/tutorials/sample-apps/capturingphotos-camerapreview
//

import SwiftUI

struct ViewfinderView: View {
    @Binding var viewfinderImage: Image?
    @Binding var isSwitchingCaptureDevice: Bool
    
    var body: some View {
        GeometryReader { geometry in
            if let image = viewfinderImage {
                if !isSwitchingCaptureDevice {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    //TODO: Switch to be something interesting maybe same as other loading screens
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
    }
}
