//
//  SubmitItemView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 12/26/23.
//

import SwiftUI

struct SubmitItemView: View {
    @ObservedObject var handleModel: ImageHandlingModel
    
    init(handleModel: ImageHandlingModel) {
        self.handleModel = handleModel
    }
    var body: some View {
        let imageAspectRatio = handleModel.getAspectRatio()
        GeometryReader { geometry in
            if let uiItemImage = handleModel.croppedItem {
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
                        handleModel.cropItemFullSize()
                    })
            }
        }
    }
}
