//
//  VoiceJournalView.swift
//  AppJournal
//
//  Created by Kun Chen on 2023-08-18.
//

import SwiftUI
import Combine
import AVFoundation
import Speech

struct VoiceJournalView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var journalManager: JournalManager
    
    @StateObject var audioRecorderManager = AudioRecorder()
    @StateObject var audioPlayerManager = AudioPlayer()

    @State var toggleOn: Bool = false
    
    @State var transcribedText: String = ""
    @State private var isTranscribing: Bool = false

    
    var body: some View {
        
        ZStack{
            Color.white
                .ignoresSafeArea()

            VStack {
                
                JournalHeaderView(journalType: "Voice Journal", journalTypeDescription: "Captures thoughts and emotions effortlessly.")

                                                
                Text(Date(), style: .date)
                    .font(.title3)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                                
                Image("voicejournalimage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180, alignment: .center)
                    .clipShape(Circle())
                    .padding()
                
                JournalPublicToggleView(toggle: $toggleOn)
                    .padding(.horizontal)
                                
                VoiceJournalContentView()
                    .environmentObject(audioRecorderManager)
            }
        }
        .navigationBarTitle("Voice Journal", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            
            journalManager.currentJournal.title = "My Voice Journal"
            journalManager.currentJournal.category = "voice"
            journalManager.currentJournal.recordings = audioRecorderManager.recordings
            
            journalManager.saveJournal(journal: journalManager.currentJournal)
        }) {
            Image(systemName: "arrowshape.turn.up.backward")
        })
    }
}

struct VoiceJournalView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            JournalHomeView().preferredColorScheme($0)
                .environmentObject(JournalManager())

        }
    }
}

