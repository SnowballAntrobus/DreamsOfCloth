//
//  ViewfinderView.swift
//  DreamsOfCloth
//
//  Adapted by Dante Gil-Marin on 8/16/23 from:
//  https://developer.apple.com/tutorials/sample-apps/capturingphotos-camerapreview
//

import SwiftUI

struct ViewfinderView: View {
    @Binding var image: Image?
    
    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct ViewfinderView_Previews: PreviewProvider {
    static var previews: some View {
        ViewfinderView(image: .constant(Image(systemName: "pencil")))
    }
}
