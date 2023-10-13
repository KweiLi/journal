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
    
    @StateObject var audioRecorderManager = AudioRecorder()
    @StateObject var audioPlayerManager = AudioPlayer()

    private let journalManager = JournalManager()

    @State var journalTitle: String = "My Voice Journal"
    @State var journalText: String = "Today's thoughts."
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
                                
                HStack {
                    Spacer()
                    Toggle("", isOn: $toggleOn)
                        .scaleEffect(0.7)
                    if toggleOn {
                        Text("Public")
                            .font(.caption)
                            .foregroundColor(.black)
                    } else {
                        Text("Private")
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
                                
                VStack {
                    
                    if audioRecorderManager.recordings.count == 0 {
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.theme.backgroundColor, lineWidth: 1))
                            
                            HStack(spacing: 10) {
                                Image(systemName: "hand.point.down")
                                    .resizable()
                                    .foregroundColor(.purple)
                                    .frame(width: 20, height: 20)

                                Text("Add Recordings")
                                    .foregroundColor(.black)
                                    .font(.footnote)
                            }
                        }
                        .padding()

                    } else {
                        ScrollView {
                            VStack {
                                ForEach(audioRecorderManager.recordings, id: \.createdAt) { recording in
                                    VStack(alignment: .leading) {
                                        RecordingRow(audioURL: recording.fileURL, createdAt: recording.createdAt, duration: recording.duration)
                                            .padding()
                                            .background(Color.purple.opacity(0.3).clipShape(RoundedRectangle(cornerRadius: 10)))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.white, lineWidth: 2)
                                            )
                                            .padding(.top, 5)
                                            .padding(.bottom, 5)
                                            .padding(.leading, 20)
                                            .padding(.trailing, 20)
                                            .onTapGesture {
                                                if let localURL = recording.localURL {
                                                    audioRecorderManager.transcribeAudio(localURL) { transcription in
                                                        if let transcription = transcription,
                                                           let index = audioRecorderManager.recordings.firstIndex(where: { $0.createdAt == recording.createdAt }) {
                                                            audioRecorderManager.recordings[index].transcription = transcription
                                                            print(transcription)
                                                        }
                                                    }
                                                } else {
                                                    print("No local file found for transcription.")
                                                }
                                            }
                                        
                                        if let transcription = recording.transcription {
                                            HStack{
                                                Image(systemName: "pencil.and.outline")
                                                    .imageScale(.small)
                                                    .foregroundColor(.black)
                                                
                                                Text(transcription)
                                                    .font(.caption)
                                                    .foregroundColor(.black)
                                                    .padding()
                                                    .background(Color.purple.opacity(0.2))
                                                    .cornerRadius(10)
                                            }
                                            .padding(.top, 5)
                                            .padding(.bottom, 5)
                                            .padding(.leading, 30)
                                            .padding(.trailing, 30)

                                        }
                                    }
                                }
                            }
                        }
                        .environmentObject(audioRecorderManager)
                    }
                
                    Spacer()
                    
                    if audioRecorderManager.recording == false {
                        Button(action: {self.audioRecorderManager.startRecording()}) {
                            
                            Image(systemName: "mic.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color.purple)
                                .clipShape(Circle())
                                .padding([.top,.bottom], 20)
                            
                        }
                    } else {
                        Button(action: {
                            self.audioRecorderManager.stopRecording() { success in
                                if success {
                                    let allRecordingURLs = audioRecorderManager.recordings.map { $0.fileURL }
                                    print(allRecordingURLs.count)
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
                            Image(systemName: "record.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding(20)  // Adjust this value to increase or decrease the space
                                .background(Color.red)
                                .clipShape(Circle())
                                .padding([.top,.bottom], 20)
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Voice Journal", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            // Call your save function here.
            saveJournal()
            
            // This line pops the view.
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrowshape.turn.up.backward") // Custom back arrow image
        })
    }
    
    func saveJournal() {
            // Your save journal code here.
            print("Journal saved!")
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

