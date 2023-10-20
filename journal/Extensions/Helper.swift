//
//  Helper.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import Foundation


func getFileDate(for file: URL) -> Date {
    if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
        let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
        return creationDate
    } else {
        return Date()
    }
}


struct Caption: Decodable {
    let generated_text: String
}

func extractCaption(from jsonString: String) -> String? {
    let data = Data(jsonString.utf8)
    
    do {
        let captions = try JSONDecoder().decode([Caption].self, from: data)
        return captions.first?.generated_text
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}


