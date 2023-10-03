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
    @ObservedObject var audioRecorder = AudioRecorder()
    @State var transcribedText: String = ""
    @State var toggleOn: Bool = false
    
    @State private var selectedTab = 0

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
            
            Spacer()
            
            Text(Date(), style: .date)
                .font(.title3)
                .fontWeight(.bold)
            
            Spacer()
            
            Image("voicejournalimage")
                .resizable()
                .scaledToFit()
                .frame(width: 230, height: 230, alignment: .center)
                .clipShape(Circle())
                .padding()
            
            Spacer()
            
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
                TabView(selection: $selectedTab) {
                    ForEach(audioRecorder.audioClips) { clip in
                        VStack {
                            HStack {
                                Button(action: {
                                    self.audioRecorder.togglePlayback(of: clip)
                                }) {
                                    Image(systemName: clip.isPlaying ? "stop.fill" : "play.fill")
                                        .foregroundColor(.purple)
                                }
                                ProgressBar(value: clip.playbackProgress)
                                    .frame(height: 20)
                                    .padding()
                                Button(action: {
                                    let index = audioRecorder.audioClips.firstIndex(where: { $0 == clip })!
                                    self.audioRecorder.delete(at: [index])
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                                                        
                            if clip.isPlaying {
                                Text(clip.transcript)
                                    .frame(maxWidth: .infinity)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .background(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                                    .cornerRadius(5)
                                    .multilineTextAlignment(.leading)
                                    .padding()
                            }
                        }
                        .tag(audioRecorder.audioClips.firstIndex(where: { $0 == clip })!)
                    }
                    .onDelete(perform: audioRecorder.delete)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .background(Color.gray.opacity(0.1))
                
                HStack {
                    ForEach(audioRecorder.audioClips) { clip in
                        let index = audioRecorder.audioClips.firstIndex(where: { $0 == clip })!
                        Circle()
                            .fill(selectedTab == index ? Color.blue : Color.gray)
                            .frame(width: 10, height: 10)
                            .padding(.horizontal, 2)
                    }
                }
            }

            Spacer()

            Button(action: audioRecorder.toggleRecording) {
                Circle()
                    .foregroundColor(.purple)
                    .overlay(
                        Image(systemName: audioRecorder.isRecording ? "stop.fill" : "record.circle.fill")
                            .foregroundColor(.white)
                    )
                    .frame(width: 70, height: 70)
                    .padding()
            }
        }
    }
}

struct ProgressBar: View {
    var value: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))

                Rectangle()
                    .frame(width: CGFloat(self.value) * geometry.size.width, height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemTeal))
            }
            .cornerRadius(45.0)
        }
    }
}

struct VoiceJournalView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceJournalView()
    }
}

