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
        let imageAspectRatio = handleModel.getAspectRatio()
        GeometryReader { geometry in
            let tapGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded { value in
                if handleModel.fetchingMask { return }
                let tapPoint = value.location
                let geometryWidth = geometry.size.width
                handleModel.addTapToPoints(tapPoint: tapPoint, geometryWidth: geometryWidth)
            }
            let dragGesture = DragGesture(minimumDistance: 10, coordinateSpace: .local) .onEnded { value in
                if handleModel.fetchingMask { return }
                let startPoint = value.startLocation
                let endPoint = value.location
                let geometryWidth = geometry.size.width
                handleModel.addDragAsBox(startPoint: startPoint, endPoint: endPoint, geometryWidth: geometryWidth)
            }
            let combinedGesture = dragGesture.exclusively(before: tapGesture)
            
            if let image = displayImage {
                let imageView = image
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.width * CGFloat(imageAspectRatio))
                    .contentShape(Rectangle())
                    .gesture(combinedGesture)
                
                ZStack {
                    imageView
                    if let uiMaskImage = handleModel.maskImage {
                        let maskImage = Image(uiImage: uiMaskImage)
                        maskImage
                            .resizable()
                            .frame(width: geometry.size.width, height: geometry.size.width * CGFloat(imageAspectRatio))
                            .opacity(0.5)
                    }
                    
                }
                .overlay(SelectionOverlayView(handleModel: handleModel))
            }
            EditCaptureButtonsView(handleModel: handleModel, displayImage: $displayImage)
                .frame(height: geometry.size.height * 1.75)
            Toggle("Positive Point", isOn: $handleModel.isPositivePoint)
                .frame(height: geometry.size.height * 1.8)
                .padding()
                .disabled(handleModel.fetchingMask)
        }
    }
}
