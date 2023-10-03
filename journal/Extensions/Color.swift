//
//  Color.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import Foundation
import SwiftUI

extension Color {
    
    static let theme = ColorTheme()
    
}

struct ColorTheme {
    let accentColor = Color("AccentColor")
    let backgroundColor = Color("BackgroundColor")
    let cardBackgroundColor = Color("CardBackgroundColor")
    let textColor = Color("TextColor")
}
