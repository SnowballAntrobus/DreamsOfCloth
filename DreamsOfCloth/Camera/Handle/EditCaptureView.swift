//
//  EditPreviewView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 11/15/23.
//

import SwiftUI

struct EditCaptureView: View {
    @StateObject var handleModel: ImageHandlingModel
    @Binding var displayImage: Image?
    
    init(displayImage: Binding<Image?>, photoData: PhotoData?) {
        _displayImage = displayImage
        _handleModel = StateObject(wrappedValue: ImageHandlingModel(photoData: photoData)!)
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            if let image = displayImage {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            EditCaptureButtonsView(handleModel: handleModel, displayImage: $displayImage)
                .frame(height: geometry.size.height * 1.75)
        }
    }
}
