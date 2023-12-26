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
    
    @Published var inputPointsForUpload: InputPointsForUpload
    @Published var inputBoxForUpload: InputBoxForUpload?
    @Published var maskImage: Image?
    
    @Published var isPositivePoint: Bool = true
    @Published var displayPosPoints: [CGPoint] = []
    @Published var displayNegPoints: [CGPoint] = []
    @Published var displayBoxPoints: (CGPoint, CGPoint)?
    
    init?(photoData: PhotoData?) {
        guard let photoData = photoData else {
            logger.debug("Photo data was null")
            return nil
        }
        self.photoData = photoData
        self.networkModel = ImageNetworkModel()
        self.inputPointsForUpload = InputPointsForUpload(pos_points: [], neg_points: [])
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
    
    func devicePointToImagePoint(devicePoint: CGPoint, deviceGeometryWidth: CGFloat) -> Point {
        let imageWidth = self.getImageWidth()
        let imageHeight = self.getImageHeight()
        let imageAspectRatio = self.getAspectRatio()
        
        let imageX = devicePoint.x * (CGFloat(imageWidth) / deviceGeometryWidth)
        let imageY = devicePoint.y * CGFloat(imageHeight) / (CGFloat(imageAspectRatio) * deviceGeometryWidth)
        let newPoint = Point(
            x: Int(imageX > CGFloat(imageWidth) ? CGFloat(imageWidth) : imageX),
            y: Int(imageY > CGFloat(imageHeight) ? CGFloat(imageHeight) : imageY)
        )
        
        return newPoint
    }
    
    func addTapToPoints(tapPoint: CGPoint, geometryWidth: CGFloat) {
        let imagePoint = devicePointToImagePoint(devicePoint: tapPoint, deviceGeometryWidth: geometryWidth)
        if self.isPositivePoint {
            self.displayPosPoints.append(tapPoint)
            self.inputPointsForUpload.pos_points.append(imagePoint)
        } else {
            self.displayNegPoints.append(tapPoint)
            self.inputPointsForUpload.neg_points.append(imagePoint)
        }
        logger.debug("Added image point: \(self.isPositivePoint ? "POS" : "NEG") \(imagePoint.dictionary)")
        logger.debug("Added display point: \(self.isPositivePoint ? "POS" : "NEG") \(tapPoint.dictionaryRepresentation)")
    }
    
    func removePoint(index: Int, isPositive: Bool) {
        var point: Point? = nil
        if (isPositive) {
            point = self.inputPointsForUpload.pos_points.remove(at: index)
            self.displayPosPoints.remove(at: index)
        } else {
            point = self.inputPointsForUpload.neg_points.remove(at: index)
            self.displayNegPoints.remove(at: index)
        }
        guard let point = point else {
            logger.debug("Removed point: no point found")
            return
        }
        logger.debug("Removed point: \(point.dictionary)")
    }
    
    func addDragAsBox(startPoint: CGPoint, endPoint: CGPoint, geometryWidth: CGFloat) {
        let imagePoint1 = devicePointToImagePoint(devicePoint: startPoint, deviceGeometryWidth: geometryWidth)
        let imagePoint2 = devicePointToImagePoint(devicePoint: endPoint, deviceGeometryWidth: geometryWidth)
        self.inputBoxForUpload = InputBoxForUpload(point1: imagePoint1, point2: imagePoint2)
        
        let imageAspectRatio = self.getAspectRatio()
        let maxImageY = CGFloat(imageAspectRatio) * geometryWidth
        var boundedEndPoint = endPoint
        if boundedEndPoint.y > maxImageY {
            boundedEndPoint.y = maxImageY
        }
        
        self.displayBoxPoints = (startPoint, boundedEndPoint)
        logger.debug("Added image box: \(imagePoint1.dictionary) \(imagePoint2.dictionary)")
        logger.debug("Added display box: \(self.displayBoxPoints?.0.dictionaryRepresentation) \(self.displayBoxPoints?.1.dictionaryRepresentation)")
    }
    
    func getMask() async throws {
        let uiImageOrientation = UIImage.Orientation(self.photoData.imageOrientation)
        
        let uiImage = await UIImage(cgImage: self.photoData.thumbnailCGImage, scale: UIScreen.main.scale, orientation: uiImageOrientation)
        
        logger.debug("Sending points: \(self.inputPointsForUpload.string)")
        logger.debug("Sending box: \(self.inputBoxForUpload?.string ?? "No box")")
        
        let inputData = InputDataForMaskUpload(points: self.inputPointsForUpload, box: nil)
        
        let maskImage = await self.networkModel.uploadDataForMask(image: uiImage, data: inputData)
        
        guard let maskImage = maskImage else {
            logger.debug("Aquired null mask from server")
            throw MaskError.nullMaskImage
        }
        
        await MainActor.run {
            self.maskImage = maskImage
        }
    }
    
}

enum MaskError: Error {
    case nullMaskImage
}

struct Point {
    var x: Int
    var y: Int
    
    var dictionary: [String: Int] {
        return ["x": x, "y": y]
    }
}

struct InputPointsForUpload {
    var pos_points: [Point]
    var neg_points: [Point]
    
    var dictionary: [String: [[String: Int]]] {
        let posPointsDict = pos_points.map { $0.dictionary }
        let negPointsDict = neg_points.map { $0.dictionary }
        return ["pos_points": posPointsDict, "neg_points": negPointsDict]
    }
    
    var string: String {
        return self.dictionary.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
    }
}

struct InputBoxForUpload {
    var point1: Point
    var point2: Point
    
    var dictionary: [String: [String: Int]] {
        return ["point1": point1.dictionary, "point2": point2.dictionary]
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
