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
    @StateObject var audioRecorderManager = AudioRecorder()
    private let journalManager = JournalManager()

    @State var journalTitle: String = "My Voice Journal"
    @State var journalText: String = "Today's thoughts."
    @State var toggleOn: Bool = false
    
    @State var transcribedText: String = ""
    
    var body: some View {
            VStack {
                VStack{
                    HStack{
                        Text("Voice Journal")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.bottom, 5)
                    
                    Text("Captures thoughts and emotions effortlessly.")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                                                
                Text(Date(), style: .date)
                    .font(.title3)
                    .fontWeight(.bold)
                                
                Image("voicejournalimage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .center)
                    .clipShape(Circle())
                    .padding()
                                
                HStack(spacing: 10){
                    Toggle("", isOn: $toggleOn)
                    
                    if toggleOn {
                        Text("Public")
                            .font(.subheadline)
                    } else {
                        Text("Private")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                                
                VStack {
                    RecordingsList()
                        .environmentObject(audioRecorderManager)
                    
                    if audioRecorderManager.recording == false {
                        Button(action: {self.audioRecorderManager.startRecording()}) {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipped()
                                .foregroundColor(.red)
                                .padding(.bottom, 40)
                        }
                    } else {
                        Button(action: {
                            self.audioRecorderManager.stopRecording() { success in
                                if success {
                                    let allRecordingURLs = audioRecorderManager.recordings.map { $0.fileURL }
                                    journalManager.saveJournalWithAudioClips(title: journalTitle, text: journalText, audioFileURLs: allRecordingURLs) { success in
                                        if success {
                                            print("Successfully saved journal with audio clips!")
                                        } else {
                                            print("Failed to save journal.")
                                        }
                                    }
                                } else {
                                    print("Failed to stop recording.")
                                }
                            }
                        }) {
                            Image(systemName: "stop.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipped()
                                .foregroundColor(.red)
                                .padding(.bottom, 40)
                        }
                    }
                }
                
        }
    }
}

struct VoiceJournalView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceJournalView()
    }
}

