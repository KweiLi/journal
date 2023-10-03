//
//  Journal.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import Foundation
import SwiftUI

struct AudioClip: Identifiable, Equatable, Hashable {
    let id = UUID()
    let url: URL
    var transcript = ""
    var isPlaying = false
    var playbackProgress: Double = 0.0
}

enum JournalType: String {
    case oneLiner
    case voice
    case writter
    
    var shadowColor: Color {
        switch self {
        case .oneLiner:
            return .green
        case .voice:
            return .blue
        case .writter:
            return .orange
        }
    }
}

struct Journal: Identifiable, Hashable {
    let id = UUID()
    var title: String = ""
    var text: String = ""
    var date: Date = Date()
    var type: JournalType = .oneLiner
    var audioClips: [AudioClip] = []
    var images: [UIImage] = []
    var publishIndicator: Bool = false
    var liked: Int = 0
}
