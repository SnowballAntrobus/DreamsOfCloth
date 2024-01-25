//
//  SubmitItemView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 12/26/23.
//

import SwiftUI

struct SubmitItemView: View {
    @ObservedObject var cropModel: ItemCroppingModel
    
    init(cropModel: ItemCroppingModel) {
        self.cropModel = cropModel
    }
    var body: some View {
        let imageAspectRatio = cropModel.getAspectRatio()
        GeometryReader { geometry in
            if let uiItemImage = cropModel.croppedItem {
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
                        cropModel.cropItemFullSize()
                    })
            }
        }
    }
}
