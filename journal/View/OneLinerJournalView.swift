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

    var body: some View {
        
        ZStack{
            Color.white
                .ignoresSafeArea()
            
            VStack {
                JournalHeaderView(journalType: "One-Liner Journal", journalTypeDescription: "Capture the essence of your day in one sentence.")
                
                OneLinerJounalContentView()
                .environmentObject(journalManager)
            }
            .onTapGesture {
                self.endEditing()
            }
        }
        .navigationBarTitle("Voice Journal", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            
            journalManager.currentJournal.title = "My One-Liner Journal"
            journalManager.currentJournal.category = "oneliner"
            
            journalManager.saveJournal(journal: journalManager.currentJournal)
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
