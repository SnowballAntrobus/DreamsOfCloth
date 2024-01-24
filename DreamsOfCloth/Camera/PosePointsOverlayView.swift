//
//  PosePointsOverlayView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 1/17/24.
//

import SwiftUI

struct PosePointsOverlayView: View {
    var parentWidth: CGFloat
    var parentHeight: CGFloat
    @ObservedObject var poseModel: PoseDetectionModel
    
    var body: some View {
        ForEach(poseModel.posePoints.allPoints, id:\.0) { point in
            if let cgPoint = point.1 {
                if let viewPoint = convertImagePointToViewPoint(point: cgPoint) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                        Text(point.0)
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .position(x: viewPoint.x, y: viewPoint.y)
                }
            }
        }
    }
    
    func convertImagePointToViewPoint(point: CGPoint) -> CGPoint? {
        guard let imageWidth = poseModel.imageWidth, let imageHeight = poseModel.imageHeight else {
            return nil
        }
        let newHeight = (point.y * parentHeight) / CGFloat(imageHeight)
        let newWidth = (point.x * parentWidth) / CGFloat(imageWidth)
        return CGPoint(x: newWidth, y: newHeight)
    }
}
