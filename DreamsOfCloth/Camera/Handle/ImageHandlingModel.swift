//
//  ImageHandlingModel.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 11/21/23.
//

import SwiftUI
import AVFoundation
import os.log

final class ImageHandlingModel: ObservableObject {
    
    private var photoData: Binding<PhotoData?>
    private var thumbnailImage: Binding<Image?>
    private var networkModel: ImageNetworkModel
    private var inputPointsforUpload: InputPointsForUpload
    
    init(photoData: Binding<PhotoData?>, thumbnailImage: Binding<Image?>) {
        self.photoData = photoData
        self.thumbnailImage = thumbnailImage
        self.networkModel = ImageNetworkModel()
        self.inputPointsforUpload = InputPointsForUpload(pos_points: [Point(x: 350, y: 450)], neg_points: [])
    }
    
    func getMask() async {
        guard let thumbnailCGIImage = self.photoData.wrappedValue?.thumbnailCGImage else {
            logger.debug("Thumbnail preview image photo data was null")
            return
        }
        guard let cgImageOrientation = self.photoData.wrappedValue?.imageOrientation else {
            logger.debug("Image orientation photo data was null")
            return
        }
        
        let uiImageOrientation = UIImage.Orientation(cgImageOrientation)
        
        let uiImage = await UIImage(cgImage: thumbnailCGIImage, scale: UIScreen.main.scale, orientation: uiImageOrientation)
        
        let maskImage = await self.networkModel.uploadImageForMask(image: uiImage, points: self.inputPointsforUpload)
        
        logger.debug("Aquired mask from server updating UI next")
        
        DispatchQueue.main.async { [weak self] in
            self?.thumbnailImage.wrappedValue = maskImage
        }
        
    }
    
}



struct PhotoData {
    var thumbnailImage: Image
    var thumbnailCGImage: CGImage
    var thumbnailSize: (width: Int, height: Int)
    var imageOrientation: CGImagePropertyOrientation
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

struct Point {
    var x: Int
    var y: Int
}

struct InputPointsForUpload {
    var pos_points: [Point]
    var neg_points: [Point]
    
    var dictionary: [String: [[String: Int]]] {
        let posPointsDict = pos_points.map { ["x": $0.x, "y": $0.y] }
        let negPointsDict = neg_points.map { ["x": $0.x, "y": $0.y] }
        return ["pos_points": posPointsDict, "neg_points": negPointsDict]
    }
}

fileprivate extension UIImage.Orientation {

    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

fileprivate let logger = Logger(subsystem: "com.musa.DreamsOfCloth.handlingphotos", category: "ImageHandlingModel")
