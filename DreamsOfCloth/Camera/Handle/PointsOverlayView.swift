//
//  PointsOverlayView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 12/15/23.
//

import SwiftUI

struct PointsOverlayView: View {
    var displayPosPoints: [CGPoint]
    var displayNegPoints: [CGPoint]
    var body: some View {
        ForEach(0..<displayPosPoints.count, id: \.self) { index in
            Circle()
                .fill(Color.green)
                .frame(width: 10, height: 10)
                .position(displayPosPoints[index])
        }
        ForEach(0..<displayNegPoints.count, id: \.self) { index in
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .position(displayNegPoints[index])
        }
    }
}
