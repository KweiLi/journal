//
//  HuggingFaceAPIManager.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import Foundation
import UIKit

class HuggingFaceAPIManager: ObservableObject{
    
    @Published var imageCaption: String = ""
    
    func sendImageToEndpoint(originalImage: UIImage, completion: @escaping (String?) -> Void) {
        var imageData: Data?
        var contentType: String
        
        if let image = resizeImageToMax2MB(image: originalImage) {
            // Attempt to convert to PNG
            if let pngData = image.pngData() {
                imageData = pngData
                contentType = "image/png"
            }
            // Attempt to convert to JPEG
            else if let jpegData = image.jpegData(compressionQuality: 1.0) {
                imageData = jpegData
                contentType = "image/jpeg"
            } else {
                print("Unsupported image format or failed to convert image to data.")
                return
            }
            
            // Prepare the URLRequest
            var request = URLRequest(url: URL(string: "https://api-inference.huggingface.co/models/Salesforce/blip-image-captioning-large")!)
            request.httpMethod = "POST"
            request.httpBody = imageData
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")

            // Send the request
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error occurred: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("HTTP Error: \(httpResponse.statusCode)")
                    completion(nil)
                    return
                }

                if let data = data, let resultString = String(data: data, encoding: .utf8) {
                    completion(resultString)  // Return the result
                } else {
                    print("Failed to decode response")
                    completion(nil)
                }
            }
            
            task.resume()
        }
        else {
            return
        }
    }
    
    func resizeImageToMax2MB(image: UIImage) -> UIImage? {
        let maxSize: CGFloat = 2 * 1024 * 1024  // 2MB in bytes
        
        // Determine the image format (PNG or JPG) based on its data representation
        var imageData = image.pngData()
        let isPNG = imageData != nil
        
        if !isPNG {
            imageData = image.jpegData(compressionQuality: 1.0)
        }
        
        if let data = imageData, data.count <= Int(maxSize) {
            return image
        }
        
        if isPNG {
            // PNG: Reduce image dimensions
            var scale: CGFloat = 1.0
            while let data = imageData, data.count > Int(maxSize) && scale > 0.1 {
                scale -= 0.1
                let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
                image.draw(in: CGRect(origin: .zero, size: newSize))
                let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                imageData = scaledImage?.pngData()
            }
        } else {
            // JPG: Reduce compression quality
            var compression: CGFloat = 1.0
            while let data = imageData, data.count > Int(maxSize) && compression > 0.0 {
                compression -= 0.1
                imageData = image.jpegData(compressionQuality: compression)
            }
        }
        
        if let finalData = imageData {
            return UIImage(data: finalData)
        }
        
        return nil
    }
    
}
