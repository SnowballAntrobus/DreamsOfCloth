//
//  ItemViewfinderView.swift
//  DreamsOfCloth
//
//  Adapted by Dante Gil-Marin on 8/16/23 from:
//  https://developer.apple.com/tutorials/sample-apps/capturingphotos-camerapreview
//

import SwiftUI

struct ItemViewfinderView: View {
    @Binding var viewfinderImage: Image?
    @Binding var isSwitchingCaptureDevice: Bool
    @ObservedObject var poseModel: PoseDetectionModel
    
    var body: some View {
        GeometryReader { geometry in
            if let image = viewfinderImage {
                if !isSwitchingCaptureDevice {
                    image
                        .resizable()
                        .overlay(PosePointsOverlayView(parentWidth: geometry.size.width, parentHeight: geometry.size.height, poseModel: poseModel))
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
