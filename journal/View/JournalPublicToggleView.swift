//
//  JournalPublicToggleView.swift
//  journal
//
//  Created by Kun Chen on 2023-10-13.
//

import SwiftUI

struct JournalPublicToggleView: View {
    
    @Binding var toggle: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Toggle("", isOn: $toggle)
                .scaleEffect(0.7)
            if toggle {
                Text("Public")
                    .font(.caption)
                    .foregroundColor(.black)
            } else {
                Text("Private")
                    .font(.caption)
                    .foregroundColor(.black)
            }
        }
    }
}

