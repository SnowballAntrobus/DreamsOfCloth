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
    @State var isPositivePoint: Bool = true
    @State var displayPosPoints: [CGPoint] = []
    @State var displayNegPoints: [CGPoint] = []
    
    init(displayImage: Binding<Image?>, photoData: PhotoData?) {
        _displayImage = displayImage
        _handleModel = StateObject(wrappedValue: ImageHandlingModel(photoData: photoData)!)
    }
    
    var body: some View {
        let imageAspectRatio = handleModel.getAspectRatio()
        let imageWidth = handleModel.getImageWidth()
        let imageHeight = handleModel.getImageHeight()
        GeometryReader { geometry in
            if let image = displayImage {
                image
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.width * CGFloat(imageAspectRatio))
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded { value in
                            let tapPoint = value.location
                            let imageX = tapPoint.x * (CGFloat(imageWidth) / geometry.size.width)
                            let imageY = tapPoint.y * CGFloat(imageHeight) / (CGFloat(imageAspectRatio) * geometry.size.width)
                            let newPoint = Point(
                                x: Int(imageX > CGFloat(imageWidth) ? CGFloat(imageWidth) : imageX),
                                y: Int(imageY > CGFloat(imageHeight) ? CGFloat(imageHeight) : imageY)
                            )
                            if isPositivePoint {
                                self.displayPosPoints.append(tapPoint)
                                handleModel.inputPointsforUpload.pos_points.append(newPoint)
                            } else {
                                self.displayNegPoints.append(tapPoint)
                                handleModel.inputPointsforUpload.neg_points.append(newPoint)
                            }
                        }
                    )
                    .overlay(
                        PointsOverlayView(displayPosPoints: $displayPosPoints, displayNegPoints: $displayNegPoints, inputPointsforUpload: $handleModel.inputPointsforUpload)
                    )
            }
            EditCaptureButtonsView(handleModel: handleModel, displayImage: $displayImage)
                .frame(height: geometry.size.height * 1.75)
            Toggle("Positive Point", isOn: $isPositivePoint)
                .frame(height: geometry.size.height * 1.8)
                .padding()
        }
    }
}
