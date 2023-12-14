//
//  ImageNetworkModel.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 11/22/23.
//

import Foundation
import os.log
import UIKit

final class ImageNetworkModel: ObservableObject {
    
    func pingServer() {
        let pingUrlString = "http://cloth.gay:8000/server/print-message/"
        
        guard let pingUrl = URL(string: pingUrlString) else {
            logger.debug("Invalid URL string")
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: pingUrl) { data, response, error in
            
            guard error == nil else {
                logger.debug("Error: \(error!)")
                return
            }
                
            guard let data = data else {
                logger.debug("No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                //TODO: define json response format so we can log it instead of printing
                print("Response: \(json)")
            } catch {
                logger.debug("Error parsing JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func uploadImageForMask(image: UIImage, points: InputPointsForUpload) {
        let imageUploadURLString = "http://cloth.gay:8000/server/image-upload/"
        
        guard let imageUploadUrl = URL(string: imageUploadURLString) else {
            logger.debug("Invalid URL string")
            return
        }
        
        var jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: points.dictionary, options: [])
        } catch {
            logger.debug("Error encoding JSON: \(error)")
            return
        }
        guard let jsonData = jsonData else {
            logger.debug("Json data was null")
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            logger.debug("No image data was created")
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: imageUploadUrl)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        // JSON part of multipart
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"json\"; filename=\"json_data_from_ios_client.json\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
        body.append(jsonData)
        body.append("\r\n".data(using: .utf8)!)
        // Image part of multipart
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image_from_ios_client.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                logger.debug("Error: \(error!)")
                return
            }
            
            guard let data = data else {
                logger.debug("No data received from upload image for mask")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                //TODO: define json response format so we can log it instead of printing
                print("Response: \(json)")
            } catch {
                logger.debug("Error parsing JSON: \(error)")
            }
            
        }
        task.resume()
    }
    
    
}


fileprivate let logger = Logger(subsystem: "com.musa.DreamsOfCloth.networkingphotos", category: "ImageNetworkModel")
