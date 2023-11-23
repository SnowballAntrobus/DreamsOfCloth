//
//  ImageNetworkModel.swift
//  DreamsOfCloth
//
//  Created by Dante Gil-Marin on 11/22/23.
//

import Foundation
import os.log

final class ImageNetworkModel: ObservableObject {
    let pingUrlString = "http://192.168.4.22:8000/server/print-message/"
    
    func pingServer() {
        guard let pingUrl = URL(string: self.pingUrlString) else {
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
}


fileprivate let logger = Logger(subsystem: "com.musa.DreamsOfCloth.networkingphotos", category: "ImageNetworkModel")
