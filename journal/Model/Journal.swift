//
//  Journal.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import Foundation
import SwiftUI


struct Journal: Identifiable, Hashable, Codable {
    let id: String?
    var category = ""
    var title: String = ""
    var text: String = ""
    var date: Date = Date()
    var type: String = ""
    var recordings: [Recording] = []
    var imageUrls: [String] = []
    var publishIndicator: Bool = false
    var liked: Int = 0
}


struct Recording: Identifiable, Equatable, Hashable, Codable {
    var id: String?
    var fileURL: URL
    var localURL: URL?
    var createdAt: Date
    var transcription: String?
    var duration: TimeInterval?
}
