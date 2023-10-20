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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var journalText: String = ""
    @State var journalType: String = ""
    @State var journalPublishIndicator: Bool = false
    
    var body: some View {
        
        ZStack{
            Color.white
                .ignoresSafeArea()
                .onTapGesture {
                    self.endEditing()
                }

            
            VStack {
                JournalHeaderView(journalType: "One-Liner Journal", journalTypeDescription: "Capture the essence of your day in one sentence.")
                
                OneLinerJounalContentView(journalText: $journalText, journalType: $journalType, journalPublishIndicator: $journalPublishIndicator)
            }
        }
        .navigationBarTitle("One-Liner Journal", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            
            journalManager.resetJournal()
            
            journalManager.currentJournal.title = "My One-Liner Journal"
            journalManager.currentJournal.category = "oneliner"
            journalManager.currentJournal.text = journalText
            journalManager.currentJournal.publishIndicator = journalPublishIndicator

            if !journalText.isEmpty {
                journalManager.saveJournal(journal: journalManager.currentJournal)
            } else {
                print("Text is empty.")
            }
            
        }) {
            Image(systemName: "arrowshape.turn.up.backward")
        })
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
