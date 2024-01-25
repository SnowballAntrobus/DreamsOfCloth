//
//  ItemCameraButtonsView.swift
//  DreamsOfCloth
//
//  Adapted by Dante Gil-Marin on 11/13/23 from:
//  https://developer.apple.com/tutorials/sample-apps/capturingphotos-camerapreview
//

import SwiftUI

struct ItemCameraButtonsView: View {
    @ObservedObject var model: ImageCaptureModel
    @State private var countdown: Int
    
    init(model: ImageCaptureModel) {
        self.model = model
        self.countdown = Int(model.timerForFrontPictureLength)
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                model.captureImage()
                startCountdown()
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
                        if model.isUsingFrontCamera {
                            Text("\(countdown)")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            Button {
                model.switchCamera()
            } label: {
                Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.green)
            }
            Spacer()
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
    }
    
    func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                timer.invalidate()
                self.countdown = Int(self.model.timerForFrontPictureLength)
            }
        }
    }
}
