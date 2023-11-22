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
    
    init(photoData: Binding<PhotoData?>) {
        self.photoData = photoData
    }
    
}



struct PhotoData {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

fileprivate let logger = Logger(subsystem: "com.musa.DreamsOfCloth.handlingphotos", category: "ImageHandlingModel")
