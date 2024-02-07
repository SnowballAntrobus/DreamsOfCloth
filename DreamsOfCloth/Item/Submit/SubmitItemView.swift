//
//  SubmitItemView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 12/26/23.
//

import SwiftUI

struct SubmitItemView: View {
    @ObservedObject var submitModel: SubmitItemModel
    
    init(aspectRatio: Float, croppedItem: UIImage?, posePoints: PosePoints, realDistanceBetweenEyesInCm: Int) {
        self.submitModel = SubmitItemModel(aspectRatio: aspectRatio, croppedItem: croppedItem, posePoints: posePoints, realDistanceBetweenEyesInCm: realDistanceBetweenEyesInCm)!
    }
    var body: some View {
        let imageAspectRatio = submitModel.aspectRatio
        GeometryReader { geometry in
            if let uiItemImage = submitModel.standardizedItem {
                let itemImage = Image(uiImage: uiItemImage)
                itemImage
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.width * CGFloat(imageAspectRatio))
            } else {
                //TODO: Add proper loading image
                Image(systemName: "square.and.arrow.up.circle")
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.width * CGFloat(imageAspectRatio))
                    .onAppear(perform: {
                        submitModel.standardizeItem()
                    })
            }
        }
    }
}
