//
//  JournalManager.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class JournalManager: ObservableObject {
    private var db = Firestore.firestore()
    private var storage = Storage.storage().reference()

    @Published var currentJournal: Journal = Journal(id: nil)

    // Save a journal without any attached files
    func saveJournal(journal: Journal) {
        do {
            let jsonData = try JSONEncoder().encode(journal)
            guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                print("Failed to serialize Journal to JSON dictionary")
                return
            }
            
            db.collection("journals").addDocument(data: json) { error in
                if let error = error {
                    print("Error writing journal to Firestore: \(error.localizedDescription)")
                } else {
                    print("Successfully added journal to Firestore!")
                }
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }


    // Upload multiple audio recordings to Firebase Storage
    private func uploadRecordings(_ fileURLs: [URL], completion: @escaping ([AudioClip]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var audioClips: [AudioClip] = []

        for fileURL in fileURLs {
            dispatchGroup.enter()
            uploadRecording(fileURL) { audioURL in
                if let audioURL = audioURL {
                    let audioClip = AudioClip(id: UUID().uuidString, url: audioURL)
                    audioClips.append(audioClip)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(audioClips)
        }
    }

    private func uploadRecording(_ fileURL: URL, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference().child("audioFiles/\(UUID().uuidString).m4a")

        if let audioData = try? Data(contentsOf: fileURL) {
            storageRef.putData(audioData, metadata: nil) { _, error in
                if let error = error {
                    print("Failed to upload: \(error)")
                    completion(nil)
                } else {
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("Failed to fetch URL: \(error)")
                            completion(nil)
                        } else if let urlString = url?.absoluteString {
                            completion(urlString)
                        }
                    }
                }
            }
        } else {
            print("Failed to fetch audio data")
            completion(nil)
        }
    }

    // Save a new journal with multiple attached audio clips
    func saveJournalWithAudioClips(title: String, text: String, audioFileURLs: [URL], completion: @escaping (Bool) -> Void) {
        uploadRecordings(audioFileURLs) { audioClips in
            if audioClips.count != audioFileURLs.count {
                completion(false)
                return
            }

            let newJournal = Journal(id: UUID().uuidString, title: title, text: text, audioClips: audioClips)
            
            self.saveJournal(journal: newJournal)
            completion(true)
        }
    }
    
}
