//
//  EditPreviewView.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 11/15/23.
//

import SwiftUI

struct EditCaptureView: View {
    @StateObject var cropModel: ItemCroppingModel
    @Binding var displayImage: Image?
    
    init(displayImage: Binding<Image?>, photoData: PhotoData?) {
        _displayImage = displayImage
        _cropModel = StateObject(wrappedValue: ItemCroppingModel(photoData: photoData)!)
    }
    
    var body: some View {
        let imageAspectRatio = cropModel.getAspectRatio()
        GeometryReader { geometry in
            let tapGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded { value in
                if cropModel.fetchingMask { return }
                let tapPoint = value.location
                let geometryWidth = geometry.size.width
                cropModel.addTapToPoints(tapPoint: tapPoint, geometryWidth: geometryWidth)
            }
            let dragGesture = DragGesture(minimumDistance: 10, coordinateSpace: .local) .onEnded { value in
                if cropModel.fetchingMask { return }
                let startPoint = value.startLocation
                let endPoint = value.location
                let geometryWidth = geometry.size.width
                cropModel.addDragAsBox(startPoint: startPoint, endPoint: endPoint, geometryWidth: geometryWidth)
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
                    if let uiMaskImage = cropModel.maskImage {
                        let maskImage = Image(uiImage: uiMaskImage)
                        maskImage
                            .resizable()
                            .frame(width: geometry.size.width, height: geometry.size.width * CGFloat(imageAspectRatio))
                            .opacity(0.5)
                    }
                    
                }
                .overlay(SelectionOverlayView(cropModel: cropModel))
            }
            EditCaptureButtonsView(cropModel: cropModel, displayImage: $displayImage)
                .frame(height: geometry.size.height * 1.75)
            Toggle("Positive Point", isOn: $cropModel.isPositivePoint)
                .frame(height: geometry.size.height * 1.8)
                .padding()
                .disabled(cropModel.fetchingMask)
        }
    }
}
