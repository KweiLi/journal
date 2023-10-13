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
import Speech


class AudioRecorder: NSObject, ObservableObject {
    
    @Published var recordings = [Recording]()
    @Published var recording = false
        
    override init() {
        super.init()
        requestTranscriptionPermission()
    }
    
    private func requestTranscriptionPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == .authorized {
                print("Speech recognition authorization granted")
            } else {
                print("Speech recognition authorization denied")
            }
        }
    }
    
    func transcribeAudio(_ url: URL, completion: @escaping (String?) -> Void) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            print("File exists!")
        } else {
            print("File doesn't exist.")
            completion(nil) // if the file doesn't exist, exit early
            return
        }
        
        guard let recognizer = SFSpeechRecognizer() else {
            print("Speech recognition not initialized.")
            completion(nil)
            return
        }

        // Check if speech recognition is available
        if !recognizer.isAvailable {
            print("Speech recognition is not available.")
            completion(nil)
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        
        recognizer.recognitionTask(with: request) { result, error in
            if let result = result, result.isFinal {
                completion(result.bestTranscription.formattedString)
            } else {
                print("Transcription failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }

    
    var audioRecorder: AVAudioRecorder!
    

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
                            let localPath = self.audioRecorder.url
                            let audioAsset = AVURLAsset(url: localPath)
                            let duration = CMTimeGetSeconds(audioAsset.duration)

                            let newRecording = Recording(fileURL: url!, localURL: localPath, createdAt: Date(), duration: duration)
                            self.recordings.append(newRecording)
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
