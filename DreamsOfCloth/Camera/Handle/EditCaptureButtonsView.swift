//
//  EditCaptureButtonsView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 11/15/23.
//

import SwiftUI

struct EditCaptureButtonsView: View {
    @StateObject var handleModel: ImageHandlingModel
    @Binding var thumbnailImage: Image?
    
    init(thumbnailImage: Binding<Image?>, photoData: Binding<PhotoData?>) {
        _thumbnailImage = thumbnailImage
        _handleModel = StateObject(wrappedValue: ImageHandlingModel(photoData: photoData))
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                thumbnailImage = nil
            } label: {
                Label("Reject Photo", systemImage: "x.circle.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Button {
                handleModel.getMask()
            } label: {
                Label("Accept Photo", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.green)
            }
            Spacer()
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
    }
}
