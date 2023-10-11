//
//  JournalHeaderView.swift
//  AppJournal
//
//  Created by Kun Chen on 2023-08-31.
//

import SwiftUI

struct JournalHeaderView: View {
    
    var journalType: String
    var journalTypeDescription: String
    
    var body: some View {
        VStack{
            HStack{
                Text(journalType)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .padding(.bottom, 5)
            
            HStack{
                Spacer()
                Text(journalTypeDescription)
                    .font(.caption)
                    .foregroundColor(.black)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
