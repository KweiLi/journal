//
//  AudioRecorderManager.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation
import FirebaseFirestore
import FirebaseStorage


struct Recording {
    let fileURL: URL
    let createdAt: Date
}

class AudioRecorder: NSObject, ObservableObject {
    
//    override init() {
//        super.init()
//        fetchRecording()
//    }
    
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    
    var audioRecorder: AVAudioRecorder!
    
    var recordings = [Recording]()
    
    var recording = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY 'at' HH:mm:ss")).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()

            recording = true
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording(completion: @escaping (Bool) -> Void) {
        audioRecorder.stop()
        recording = false

        let storageRef = Storage.storage().reference().child("audioFiles/\(UUID().uuidString).m4a")
        
        if let audioData = try? Data(contentsOf: audioRecorder.url) {
            storageRef.putData(audioData, metadata: nil) { _, error in
                if let error = error {
                    print("Failed to upload: \(error)")
                    completion(false)
                } else {
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("Failed to fetch URL: \(error)")
                            completion(false)
                        } else {
                            
                            // Successfully uploaded to Firebase, now add the recording to the recordings array.
                            let newRecording = Recording(fileURL: url!, createdAt: Date())
                            self.recordings.append(newRecording)
                            // Trigger UI update.
                            self.objectWillChange.send(self)
                            completion(true)

                        }
                    }
                }
            }
        } else {
            print("Failed to fetch audio data")
            completion(false)
        }
    }
        
    func deleteRecording(urlsToDelete: [URL]) {
        let storage = Storage.storage()
        
        for url in urlsToDelete {
            // Extract the audio file's name from the URL
            // You might want to adjust this if your Firebase Storage structure is different
            guard let audioFileName = url.lastPathComponent.components(separatedBy: "?").first else {
                print("Failed to parse audio file name from URL: \(url)")
                continue
            }
            
            // Reference to the audio file in Firebase Storage
            let audioRef = storage.reference().child("audioFiles/\(audioFileName)")
            
            // Delete the audio file from Firebase Storage
            audioRef.delete { error in
                if let error = error {
                    print("Failed to delete \(audioFileName) from Firebase: \(error)")
                } else {
                    print("\(audioFileName) deleted successfully from Firebase.")
                }
            }
        }
    }

}
