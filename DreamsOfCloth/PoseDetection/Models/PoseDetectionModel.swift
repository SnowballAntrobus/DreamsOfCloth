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
                try? observation.recognizedPoints(.all) else { return }
        
        let torsoJointNames: [VNHumanBodyPoseObservation.JointName] = [
            .nose,
            .leftEye,
            .rightEye,
            .leftEar,
            .rightEar,
            .leftShoulder,
            .rightShoulder,
            .neck,
            .leftElbow,
            .rightElbow,
            .leftWrist,
            .rightWrist,
            .leftHip,
            .rightHip,
            .root,
            .leftKnee,
            .rightKnee,
            .leftAnkle,
            .rightAnkle
        ]
        
        if imageWidth == nil || imageHeight == nil {
            logger.debug("Pose detection image width or height is null in processing")
        }
        
        var newPosePoints = PosePoints()
        
        for joint in torsoJointNames {
            guard let point = recognizedPoints[joint], point.confidence > 0 else { continue }
            //TODO: Figure out why this is
            // Returns points with y in format height - y so we fix
            var imagePoint = VNImagePointForNormalizedPoint(point.location, Int(imageWidth!), Int(imageHeight!))
            imagePoint.y = CGFloat(imageHeight!) - imagePoint.y
            
            switch joint {
            case .nose:
                newPosePoints.nose = (imagePoint, point.confidence)
            case .leftEye:
                newPosePoints.leftEye = (imagePoint, point.confidence)
            case .rightEye:
                newPosePoints.rightEye = (imagePoint, point.confidence)
            case .leftEar:
                newPosePoints.leftEar = (imagePoint, point.confidence)
            case .rightEar:
                newPosePoints.rightEar = (imagePoint, point.confidence)
            case .leftShoulder:
                newPosePoints.leftShoulder = (imagePoint, point.confidence)
            case .rightShoulder:
                newPosePoints.rightShoulder = (imagePoint, point.confidence)
            case .neck:
                newPosePoints.neck = (imagePoint, point.confidence)
            case .leftElbow:
                newPosePoints.leftElbow = (imagePoint, point.confidence)
            case .rightElbow:
                newPosePoints.rightElbow = (imagePoint, point.confidence)
            case .leftWrist:
                newPosePoints.leftWrist = (imagePoint, point.confidence)
            case .rightWrist:
                newPosePoints.rightWrist = (imagePoint, point.confidence)
            case .leftHip:
                newPosePoints.leftHip = (imagePoint, point.confidence)
            case .rightHip:
                newPosePoints.rightHip = (imagePoint, point.confidence)
            case .root:
                newPosePoints.root = (imagePoint, point.confidence)
            case .leftKnee:
                newPosePoints.leftKnee = (imagePoint, point.confidence)
            case .rightKnee:
                newPosePoints.rightKnee = (imagePoint, point.confidence)
            case .leftAnkle:
                newPosePoints.leftAnkle = (imagePoint, point.confidence)
            case .rightAnkle:
                newPosePoints.rightAnkle = (imagePoint, point.confidence)
            default:
                break
            }
        }
        posePoints = newPosePoints
    }
}

struct PosePoints {
    var nose: (CGPoint, Float)?
    var leftEye: (CGPoint, Float)?
    var rightEye: (CGPoint, Float)?
    var leftEar: (CGPoint, Float)?
    var rightEar: (CGPoint, Float)?
    var leftShoulder: (CGPoint, Float)?
    var rightShoulder: (CGPoint, Float)?
    var neck: (CGPoint, Float)?
    var leftElbow: (CGPoint, Float)?
    var rightElbow: (CGPoint, Float)?
    var leftWrist: (CGPoint, Float)?
    var rightWrist: (CGPoint, Float)?
    var leftHip: (CGPoint, Float)?
    var rightHip: (CGPoint, Float)?
    var root: (CGPoint, Float)?
    var leftKnee: (CGPoint, Float)?
    var rightKnee: (CGPoint, Float)?
    var leftAnkle: (CGPoint, Float)?
    var rightAnkle: (CGPoint, Float)?
    
    var allPoints: [(String, CGPoint?)] {
        return [
            ("no", nose?.0),
            ("Ley", leftEye?.0),
            ("Rey", rightEye?.0),
            ("Lea", leftEar?.0),
            ("Rea", rightEar?.0),
            ("Ls", leftShoulder?.0),
            ("Rs", rightShoulder?.0),
            ("ne", neck?.0),
            ("Lel", leftElbow?.0),
            ("Rel", rightElbow?.0),
            ("Lw", leftWrist?.0),
            ("Rw", rightWrist?.0),
            ("Lh", leftHip?.0),
            ("Rh", rightHip?.0),
            ("r", root?.0),
            ("Lk", leftKnee?.0),
            ("Rk", rightKnee?.0),
            ("La", leftAnkle?.0),
            ("Ra", rightAnkle?.0)
        ]
    }
}

fileprivate let logger = Logger(subsystem: "com.musa.DreamsOfCloth.posedetection", category: "PoseDetectionModel")
