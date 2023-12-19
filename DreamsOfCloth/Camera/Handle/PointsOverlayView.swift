//
//  PointsOverlayView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 12/15/23.
//

import SwiftUI

struct PointsOverlayView: View {
    @Binding var displayPosPoints: [CGPoint]
    @Binding var displayNegPoints: [CGPoint]
    @Binding var inputPointsforUpload: InputPointsForUpload
    
    var body: some View {
        ForEach(0..<displayPosPoints.count, id: \.self) { index in
            Circle()
                .fill(Color.green)
                .frame(width: 18, height: 18)
                .position(displayPosPoints[index])
                .onTapGesture {
                    removePoint(index: index, isPositive: true)
                }
        }
        ForEach(0..<displayNegPoints.count, id: \.self) { index in
            Circle()
                .fill(Color.red)
                .frame(width: 18, height: 18)
                .position(displayNegPoints[index])
                .onTapGesture {
                    removePoint(index: index, isPositive: false)
                }
        }
    }
    
    func removePoint(index: Int, isPositive: Bool) {
        if (isPositive) {
            inputPointsforUpload.pos_points.remove(at: index)
            displayPosPoints.remove(at: index)
        } else {
            inputPointsforUpload.neg_points.remove(at: index)
            displayNegPoints.remove(at: index)
        }
    }
}
