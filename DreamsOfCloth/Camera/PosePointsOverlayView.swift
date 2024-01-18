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
        let neckPoint = poseModel.posePoints.neck?.0
        if neckPoint != nil {
            let viewPoint = convertImagePointToViewPoint(point: neckPoint!)
            if viewPoint != nil {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                    .position(viewPoint!)
            }
        }
    }
    
    func convertImagePointToViewPoint(point: CGPoint) -> CGPoint? {
        guard let imageWidth = poseModel.imageWidth, let imageHeight = poseModel.imageHeight else {
            return nil
        }
        let newHeight = (point.y * parentHeight) / CGFloat(imageHeight)
        let newWidth = (point.x * parentWidth) / CGFloat(imageWidth)
        print("currentHeight: \(point.y), currentWdith: \(point.x)")
        print("parentHeight: \(parentHeight), parentWidth: \(parentWidth)")
        print("imageHeight: \(imageHeight), imageWidth: \(imageWidth)")
        print("newHeight: \(newHeight), newWidth: \(newWidth)")
        return CGPoint(x: newWidth, y: newHeight)
    }
}
