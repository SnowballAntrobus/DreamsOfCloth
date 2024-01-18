//
//  PoseDetectionModel.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 1/16/24.
//

import SwiftUI
import Vision
import os.log

final class PoseDetectionModel: ObservableObject {
    @Published var posePoints: PosePoints
    var imageWidth: Int?
    var imageHeight: Int?
    
    init() {
        posePoints = PosePoints()
    }
    
    func performBodyPoseRequest(_ image: CGImage) {
        imageWidth = image.width
        imageHeight = image.height
        
        let requestHandler = VNImageRequestHandler(cgImage: image)
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)
        
        do {
            try requestHandler.perform([request])
        } catch {
            logger.debug("Unable to perform the request: \(error)")
        }
    }
    
    func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else {
            return
        }
        
        if observations.isEmpty {
            posePoints = PosePoints()
            return
        }
        
        processObservation(observations[0])
    }
    
    func processObservation(_ observation: VNHumanBodyPoseObservation) {
        guard let recognizedPoints =
                    try? observation.recognizedPoints(.torso) else { return }
        
        let torsoJointNames: [VNHumanBodyPoseObservation.JointName] = [
                .neck,
                .rightShoulder,
                .rightHip,
                .root,
                .leftHip,
                .leftShoulder
        ]
        
        if imageWidth == nil || imageHeight == nil {
            logger.debug("Pose detection image width or height is null in processing")
        }
        
        var newPosePoints = PosePoints()
        
        for joint in torsoJointNames {
            guard let point = recognizedPoints[joint], point.confidence > 0 else { continue }
            let imagePoint = VNImagePointForNormalizedPoint(point.location, Int(imageWidth!), Int(imageHeight!))
            
            switch joint {
                case .neck:
                    newPosePoints.neck = (imagePoint, point.confidence)
                case .rightShoulder:
                    newPosePoints.rightShoulder = (imagePoint, point.confidence)
                case .rightHip:
                    newPosePoints.rightHip = (imagePoint, point.confidence)
                case .root:
                    newPosePoints.root = (imagePoint, point.confidence)
                case .leftHip:
                    newPosePoints.leftHip = (imagePoint, point.confidence)
                case .leftShoulder:
                    newPosePoints.leftShoulder = (imagePoint, point.confidence)
                default:
                    break
            }
        }
        posePoints = newPosePoints
    }
}

struct PosePoints {
    var neck: (CGPoint, Float)?
    var rightShoulder: (CGPoint, Float)?
    var rightHip: (CGPoint, Float)?
    var root: (CGPoint, Float)?
    var leftHip: (CGPoint, Float)?
    var leftShoulder: (CGPoint, Float)?
    
    var dictionary: [String: (CGPoint, Float)?] {
        return ["neck": neck, "rightShoulder": rightShoulder, "rightHip": rightHip, "root": root, "leftHip": leftHip, "leftShoulder": leftShoulder]
    }
    var string: String {
        return self.dictionary.map { "\($0.key): \(String(describing: $0.value)))" }.joined(separator: ", ")
    }
}

fileprivate let logger = Logger(subsystem: "com.musa.DreamsOfCloth.posedetection", category: "PoseDetectionModel")
