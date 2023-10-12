//
//  OneLinerJournalView.swift
//  AppJournal
//
//  Created by Kun Chen on 2023-08-17.
//

import SwiftUI

extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct OneLinerJournalView: View {
    
    @EnvironmentObject var journalManager: JournalManager
    
    var body: some View {
        
        ZStack{
            Color.white
                .ignoresSafeArea()
            
            ScrollView{
                VStack {
                    // Welcome Section
                    JournalHeaderView(journalType: "One-Liner Journal", journalTypeDescription: "Capture the essence of your day in one sentence.")
                    
                    OneLinerJounalContentView(
                        journalText: $journalManager.currentJournal.text, journalSubject: $journalManager.currentJournal.title,
                        journalPublishIndicator: $journalManager.currentJournal.publishIndicator)

                    JournalSubmissionButtonView()
                }
            }
            .onTapGesture {
                self.endEditing()
            }
        }
    }
}

struct OneLinerJournalView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            JournalHomeView().preferredColorScheme($0)
                .environmentObject(JournalManager())

        }
    }
}
