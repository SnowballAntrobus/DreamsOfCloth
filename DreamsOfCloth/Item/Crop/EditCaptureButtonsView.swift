//
//  EditCaptureButtonsView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 11/15/23.
//

import SwiftUI

struct EditCaptureButtonsView: View {
    @ObservedObject var cropModel: ItemCroppingModel
    var displayImage: Binding<Image?>
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                cropModel.rejectImage(displayImage: displayImage)
            } label: {
                Label("Reject Photo", systemImage: "x.circle.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.green)
            }.disabled(cropModel.fetchingMask)
            
            Spacer()
            	
            Button {
                Task {
                    do {
                        try await cropModel.getMask()
                    }
                    catch {
                        //TODO: display errors to user in some way
                        cropModel.fetchingMask = false
                    }
                }
            } label: {
                Label("Process Photo", systemImage: "play.circle")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.green)
            }.disabled(cropModel.fetchingMask)
            
            Spacer()
            
            let acceptImage = Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 36, height: 36)
                .foregroundColor(.green)
            if !cropModel.fetchingMask && cropModel.maskImage != nil {
                NavigationLink(destination: SubmitItemView(cropModel: cropModel)) {
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
