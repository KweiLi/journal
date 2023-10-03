//
//  JournalSubmissionButtonView.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import SwiftUI

struct JournalSubmissionButtonView: View {
    
    @EnvironmentObject var journalManager: JournalManager
    
    var body: some View {
        HStack(spacing: 30) {
            Button("Cancel") {
                // Example Usage:
                
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Button("Submit") {
                print(journalManager.currentJournal)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

struct JournalSubmissionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        JournalSubmissionButtonView()
    }
}
