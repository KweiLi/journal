//
//  ImageManager.swift
//  journal
//
//  Created by Kun Chen on 2023-10-13.
//

import SwiftUI
import FirebaseStorage

class ImageManager: ObservableObject {
    let storage = Storage.storage().reference()

    func submitImageToFirebase(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "com.myapp.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }

        let imageName = UUID().uuidString
        let imageRef = storage.child("journal_images/\(imageName).jpg")

        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                } else {
                    completion(.failure(NSError(domain: "com.myapp.error", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                }
            }
        }
    }
    
    func deleteImageFromFirebase(url: URL, completion: @escaping (Error?) -> Void) {
        let imageRef = storage.storage.reference(forURL: url.absoluteString)
        imageRef.delete { error in
            completion(error)
        }
    }
}
