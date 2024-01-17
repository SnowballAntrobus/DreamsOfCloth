//
//  PoseDetectionModel.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 1/16/24.
//

import SwiftUI
import Vision

final class PoseDetectionModel: ObservableObject {
    @Published var posePoints: [CGPoint]
    
    init() {
        posePoints = []
    }
    
    // perform the request
    func performBodyPoseRequest(_ image: CGImage) {
        
    }
    
    // handle the completion
    func bodyPoseHandler(request: VNRequest, error: Error?) {
        
    }
    
    // process the observation and update the posePoints
    func processObservation(_ observation: VNHumanBodyPoseObservation) {
    }
    
}
