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
    var title: String = ""
    var text: String = ""
    var date: Date = Date()
    var type: String = ""
    var audioClips: [AudioClip] = []
    var imageUrls: [String] = []
    var publishIndicator: Bool = false
    var liked: Int = 0
}

struct AudioClip: Identifiable, Equatable, Hashable, Codable {
    let id: String
    let url: String
    var transcript = ""
}
