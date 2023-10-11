//
//  RecordListView.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import SwiftUI

struct RecordingsList: View {
    
    @EnvironmentObject var audioRecorderManager: AudioRecorder
    
    var body: some View {
        List {
            ForEach(audioRecorderManager.recordings, id: \.createdAt) { recording in
                RecordingRow(audioURL: recording.fileURL)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple.opacity(0.3), lineWidth: 2)  // Purple border
                    )
                    .listRowBackground(Color.white)
            }
            .onDelete(perform: delete)
        }
        .listStyle(PlainListStyle())  // This will ensure a plain list style
        .padding()
    }
    
    func delete(at offsets: IndexSet) {
        var urlsToDelete = [URL]()
        for index in offsets {
            urlsToDelete.append(audioRecorderManager.recordings[index].fileURL)
        }
        audioRecorderManager.deleteRecording(urlsToDelete: urlsToDelete)
    }
}

struct RecordingRow: View {
    
    var audioURL: URL
    
    @ObservedObject var audioPlayer = AudioPlayer()
    
    
    var body: some View {
        HStack {
            Text("\(audioURL.lastPathComponent)")
                .foregroundColor(.black)
            Spacer()
            if audioPlayer.isPlaying == false {
                Button(action: {
                    self.audioPlayer.startPlayback(audio: self.audioURL)
                }) {
                    Image(systemName: "play.circle")
                        .imageScale(.large)
                        .foregroundColor(.red)
                }
            } else {
                Button(action: {
                    self.audioPlayer.stopPlayback()
                }) {
                    Image(systemName: "stop.fill")
                        .imageScale(.large)
                        .foregroundColor(.green)
                }
            }
        }
    }
}

struct RecordingsList_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            JournalHomeView().preferredColorScheme($0)
                .environmentObject(JournalManager())
        }
    }
}
