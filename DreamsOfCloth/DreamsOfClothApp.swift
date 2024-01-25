//
//  DreamsOfClothApp.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 8/15/23.
//

import SwiftUI

@main
struct DreamsOfClothApp: App {
    var globalSettings = GlobalSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(globalSettings)
        }
    }
}
