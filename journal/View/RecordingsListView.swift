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
                RecordingRow(audioURL: recording.fileURL, createdAt: recording.createdAt)
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
    var createdAt: Date
    
    @ObservedObject var audioPlayer = AudioPlayer()
    
    var body: some View {
        HStack {
            Text(createdAt.toCustomString())
                .font(.headline)
                .foregroundColor(.black)
                
            Spacer()
            if audioPlayer.isPlaying == false {
                Button(action: {
                    self.audioPlayer.startPlayback(audio: self.audioURL)
                }) {
                    Image(systemName: "play.fill")
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

extension Date {
    func toCustomString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy HH:mm:ss"
        let baseString = formatter.string(from: self)
        let day = Calendar.current.component(.day, from: self)
        let suffix = daySuffix(from: day)
        let finalString = baseString.replacingOccurrences(of: "d", with: "\(day)\(suffix)")
        return finalString
    }
    
    func daySuffix(from day: Int) -> String {
        switch day {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
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
