//
//  SelectionOverlayView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 12/15/23.
//

import SwiftUI

struct SelectionOverlayView: View {
    @ObservedObject var handleModel: ImageHandlingModel
    
    var body: some View {
        ForEach(0..<handleModel.displayPosPoints.count, id: \.self) { index in
            Circle()
                .fill(Color.green)
                .frame(width: 18, height: 18)
                .position(handleModel.displayPosPoints[index])
                .onTapGesture {
                    handleModel.removePoint(index: index, isPositive: true)
                }
        }
        ForEach(0..<handleModel.displayNegPoints.count, id: \.self) { index in
            Circle()
                .fill(Color.red)
                .frame(width: 18, height: 18)
                .position(handleModel.displayNegPoints[index])
                .onTapGesture {
                    handleModel.removePoint(index: index, isPositive: false)
                }
        }
    }
}
