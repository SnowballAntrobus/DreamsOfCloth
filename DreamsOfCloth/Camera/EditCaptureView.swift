//
//  EditPreviewView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 11/15/23.
//

import SwiftUI

struct EditCaptureView: View {
    @Binding var thumbnailImage: Image?
    
    var body: some View {
        GeometryReader { geometry in
            if let image = thumbnailImage {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct EditCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        EditCaptureView(thumbnailImage: .constant(Image(systemName: "pencil")))
    }
}
