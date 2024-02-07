//
//  SubmitItemModel.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 2/6/24.
//

import SwiftUI
import os.log

final class SubmitItemModel: ObservableObject {
    
    public var aspectRatio: Float
    
    private var croppedItem: UIImage
    private var posePoints: PosePoints
    private var realDistanceBetweenEyesInCm: Int
    
    @Published var standardizedItem: UIImage?
    
    init?(aspectRatio: Float, croppedItem: UIImage?, posePoints: PosePoints, realDistanceBetweenEyesInCm: Int) {
        guard let croppedItem = croppedItem else {
            logger.debug("Cropped item was null for submit item model")
            return nil
        }
        self.aspectRatio = aspectRatio
        self.croppedItem = croppedItem
        self.posePoints = posePoints
        self.realDistanceBetweenEyesInCm = realDistanceBetweenEyesInCm
    }
    
    func standardizeItem() {
        let resizeFactor = getResizeFactorFromDistanceBetweenEyes()
        let resizedHeight = croppedItem.size.height * resizeFactor
        let resizedWidth = croppedItem.size.width * resizeFactor
        
        let standadizedImage = resizeImage(image: croppedItem, targetSize: CGSize(width: resizedWidth, height: resizedHeight))
        
        self.standardizedItem = standadizedImage
    }
    
    // fucntion to get reszied factor based on eyes
    func getResizeFactorFromDistanceBetweenEyes() -> CGFloat {
        return 1
    }
}

fileprivate let logger = Logger(subsystem: "com.musa.DreamsOfCloth.submititem", category: "SubmitItemModel")
