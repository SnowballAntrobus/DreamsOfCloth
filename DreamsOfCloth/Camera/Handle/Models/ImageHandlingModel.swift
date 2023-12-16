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
    
    private var photoData: PhotoData
    private var networkModel: ImageNetworkModel
    
    @Published var inputPointsforUpload: InputPointsForUpload
    
    init?(photoData: PhotoData?) {
        guard let photoData = photoData else {
            logger.debug("Photo data was null")
            return nil
        }
        self.photoData = photoData
        self.networkModel = ImageNetworkModel()
        self.inputPointsforUpload = InputPointsForUpload(pos_points: [], neg_points: [])
    }
    
    func getImageWidth() -> Float {
        return Float(photoData.thumbnailSize.width)
    }
    
    func getImageHeight() -> Float {
        return Float(photoData.thumbnailSize.height)
    }
    
    func getAspectRatio() -> Float {
        return Float(photoData.thumbnailSize.height) / Float(photoData.thumbnailSize.width)
    }
    
    func rejectImage(displayImage: Binding<Image?>) {
        displayImage.wrappedValue = nil
    }
    
    func getMask() async -> Image? {
        let uiImageOrientation = UIImage.Orientation(self.photoData.imageOrientation)
        
        let uiImage = await UIImage(cgImage: self.photoData.thumbnailCGImage, scale: UIScreen.main.scale, orientation: uiImageOrientation)
        
        logger.debug("Sending points: \(self.inputPointsforUpload.string)")
        
        let maskImage = await self.networkModel.uploadImageForMask(image: uiImage, points: self.inputPointsforUpload)
        
        guard let maskImage = maskImage else {
            logger.debug("Aquired null mask from server")
            return nil
        }
        
        return maskImage
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
    
    var string: String {
        return self.dictionary.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
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
