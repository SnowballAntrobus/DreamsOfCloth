//
//  ItemCropUtil.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 12/27/23.
//

import UIKit
import os.log

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
    guard let ciImage = CIImage(image: image) else {
        logger.debug("Failed to get ciImage in resize")
        return nil
    }
    
    let scale = targetSize.height / ciImage.extent.height
    let aspectRatio = targetSize.width / (ciImage.extent.width * scale)
    
    let filter = CIFilter(name: "CILanczosScaleTransform")!
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(scale, forKey: kCIInputScaleKey)
    filter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
    
    let context = CIContext(options: nil)
    guard let outputCIImage = filter.outputImage,
          let resizedImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
        logger.debug("Failed to get mask filter output in crop")
        return nil
    }
    
    return UIImage(cgImage: resizedImage)
}

func imageWithOrientationUp(image: UIImage) -> UIImage? {
    if image.imageOrientation == .up {
        return image
    }

    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    image.draw(in: CGRect(origin: .zero, size: image.size))
    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return normalizedImage
}

func useMaskToFilterImage(image: UIImage, maskImage: UIImage) -> UIImage? {
    guard let captureCIImage = CIImage(image: image),
          let maskCIImage = CIImage(image: maskImage) else {
        logger.debug("Failed to convert to ciImage in crop")
        return nil
    }
    
    let maskFilter = CIFilter(name: "CIBlendWithMask")!
        maskFilter.setValue(captureCIImage, forKey: kCIInputImageKey)
        maskFilter.setValue(maskCIImage, forKey: kCIInputMaskImageKey)
    
    guard let outputCIImage = maskFilter.outputImage, let newImage = CIContext().createCGImage(outputCIImage, from: outputCIImage.extent) else {
        logger.debug("Failed to get mask filter output in crop")
        return nil
    }
    
    return UIImage(cgImage: newImage)
}

fileprivate let logger = Logger(subsystem: "com.musa.DreamsOfCloth.cropitem", category: "ItemCropUtils")
