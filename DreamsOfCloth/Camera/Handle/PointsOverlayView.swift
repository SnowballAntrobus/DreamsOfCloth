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
                    removePoint(index: index, array: $displayPosPoints)
                }
        }
        ForEach(0..<displayNegPoints.count, id: \.self) { index in
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .position(displayNegPoints[index])
                .onTapGesture {
                    removePoint(index: index, array: $displayNegPoints)
                }
        }
    }
    
    func removePoint(index: Int, array: Binding<[CGPoint]>) {
        inputPointsforUpload.pos_points.remove(at: index)
        array.wrappedValue.remove(at: index)
    }
}
