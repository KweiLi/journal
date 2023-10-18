//
//  VoiceJournalContentView.swift
//  journal
//
//  Created by Kun Chen on 2023-10-13.
//

import SwiftUI

struct VoiceJournalContentView: View {
    
    @EnvironmentObject var audioRecorderManager: AudioRecorder
    
    var body: some View {
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
                        .environmentObject(audioRecorderManager)
                    }
                }
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
                        .padding(20) 
                        .background(Color.red)
                        .clipShape(Circle())
                        .padding([.top,.bottom], 20)
                }
            }
        }
    }
}

struct VoiceJournalContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            JournalHomeView().preferredColorScheme($0)
                .environmentObject(JournalManager())

        }
    }
}
