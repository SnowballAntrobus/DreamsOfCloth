//
//  SelectionOverlayView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 12/15/23.
//

import SwiftUI

struct SelectionOverlayView: View {
    @ObservedObject var cropModel: ItemCroppingModel
    
    var body: some View {
        ForEach(0..<cropModel.displayPosPoints.count, id: \.self) { index in
            Circle()
                .fill(Color.green)
                .frame(width: 18, height: 18)
                .position(cropModel.displayPosPoints[index])
                .onTapGesture {
                    cropModel.removePoint(index: index, isPositive: true)
                }
        }
        ForEach(0..<cropModel.displayNegPoints.count, id: \.self) { index in
            Circle()
                .fill(Color.red)
                .frame(width: 18, height: 18)
                .position(cropModel.displayNegPoints[index])
                .onTapGesture {
                    cropModel.removePoint(index: index, isPositive: false)
                }
        }
        
        if let boxPoints = cropModel.displayBoxPoints {
            let width = abs(boxPoints.0.x - boxPoints.1.x)
            let height = abs(boxPoints.0.y - boxPoints.1.y)
            let originX = min(boxPoints.0.x, boxPoints.1.x)
            let originY = min(boxPoints.0.y, boxPoints.1.y)
            Rectangle()
                .stroke(Color.green, lineWidth: 5)
                .frame(width: width, height: height)
                .position(x: originX + width / 2, y: originY + height / 2)
        }
    }
}
