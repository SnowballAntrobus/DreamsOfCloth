//
//  EditCaptureButtonsView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 11/15/23.
//

import SwiftUI

struct EditCaptureButtonsView: View {
    var handleModel: ImageHandlingModel
    var displayImage: Binding<Image?>
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                handleModel.rejectImage(displayImage: displayImage)
            } label: {
                Label("Reject Photo", systemImage: "x.circle.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.green)
            }
            
            Spacer()
            	
            Button {
                Task {
                    try await handleModel.getMask()
                    //TODO: handle mask image is null display error to user
                }
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
