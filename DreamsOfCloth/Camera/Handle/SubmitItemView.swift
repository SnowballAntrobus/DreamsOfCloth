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
                Image(systemName: "pencil.tip.crop.circle")
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.width * CGFloat(imageAspectRatio))
            }
            Button {
                handleModel.cropItemFullSize()
            } label: {
                Label("Crop", systemImage: "pencil.tip.crop.circle")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.green)
                    .frame(height: geometry.size.height * 1.8)
            }
        }
    }
}
