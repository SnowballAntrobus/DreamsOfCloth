//
//  EditCaptureButtonsView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 11/15/23.
//

import SwiftUI

struct EditCaptureButtonsView: View {
    @ObservedObject var handleModel: ImageHandlingModel
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
            }.disabled(handleModel.fetchingMask)
            
            Spacer()
            	
            Button {
                Task {
                    do {
                        try await handleModel.getMask()
                    }
                    catch {
                        //TODO: display errors to user in some way
                        handleModel.fetchingMask = false
                    }
                }
            } label: {
                Label("Process Photo", systemImage: "play.circle")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.green)
            }.disabled(handleModel.fetchingMask)
            
            Spacer()
            
            let acceptImage = Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 36, height: 36)
                .foregroundColor(.green)
            if !handleModel.fetchingMask && handleModel.maskImage != nil {
                NavigationLink(destination: SubmitItemView(handleModel: handleModel)) {
                    acceptImage
                }
            } else {
                acceptImage
                    .opacity(0.5)
            }
            
            Spacer()
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
    }
}
