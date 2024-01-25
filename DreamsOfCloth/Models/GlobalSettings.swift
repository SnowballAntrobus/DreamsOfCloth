//
//  GlobalSettings.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 1/24/24.
//

import SwiftUI

class GlobalSettings: ObservableObject {
    @Published var distanceBetweenEyesInCm: Int {
        didSet {
            UserDefaults.standard.set(distanceBetweenEyesInCm, forKey: "DistanceBetweenEyesInCm")
        }
    }

    init() {
        self.distanceBetweenEyesInCm = UserDefaults.standard.integer(forKey: "DistanceBetweenEyesInCm")
        if self.distanceBetweenEyesInCm == 0 {
            //TODO: Get better default
            let defaultDistanceBetweenEyesInCm = 6
            self.distanceBetweenEyesInCm = defaultDistanceBetweenEyesInCm
        }
    }
}
