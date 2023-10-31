//
//  JournalManager.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class JournalManager: ObservableObject {
    private var db = Firestore.firestore()
    
    private var lastDocumentSnapshot: DocumentSnapshot?
    
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
    
    func resetJournal(){
        self.currentJournal = Journal(id: nil)
    }

    // Upload multiple audio recordings to Firebase Storage
    private func uploadRecordings(_ fileURLs: [URL], completion: @escaping ([Recording]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var recordings: [Recording] = []

        for fileURL in fileURLs {
            dispatchGroup.enter()
            uploadRecording(fileURL) { recording in
                if let recording = recording {
                    recordings.append(recording)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(recordings)
        }
    }

    private func uploadRecording(_ fileURL: URL, completion: @escaping (Recording?) -> Void) {
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
                        } else if let audioURL = url {
                            let recording = Recording(id: UUID().uuidString, fileURL: audioURL, localURL: fileURL, createdAt: Date())
                            completion(recording)
                        }
                    }
                }
            }
        } else {
            print("Failed to fetch audio data")
            completion(nil)
        }
    }

    // Save a new journal with multiple attached recordings
    func saveJournalWithRecordings(title: String, text: String, audioFileURLs: [URL], completion: @escaping (Bool) -> Void) {
        uploadRecordings(audioFileURLs) { recordings in
            if recordings.count != audioFileURLs.count {
                completion(false)
                return
            }

            let newJournal = Journal(id: UUID().uuidString, title: title, text: text, recordings: recordings)
            
            self.saveJournal(journal: newJournal)
            completion(true)
        }
    }
    
    func fetchJournals(completion: @escaping (Result<[Journal], Error>) -> Void) {
        
        var query: Query = db.collection("journals").order(by: "date", descending: true).limit(to: 10)
        if let lastDocument = lastDocumentSnapshot {
            query = query.start(afterDocument: lastDocument)
        }
        
        query.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(.failure(err))
            } else {
                var journals = [Journal]()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    let id = document.documentID
                    let category = data["category"] as? String ?? ""
                    let title = data["title"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    
                    // Convert Firestore timestamp to Date
                    let timestamp = data["date"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date()
                    
                    let type = data["type"] as? String ?? ""
                    let publishIndicator = data["publishIndicator"] as? Bool ?? false
                    let liked = data["liked"] as? Int ?? 0

                    // Decode recordings
                    var recordings: [Recording] = []
                    if let recordingData = data["recordings"] as? [[String: Any]] {
                        for recordingDict in recordingData {
                            if let fileURLString = recordingDict["fileURL"] as? String,
                               let fileURL = URL(string: fileURLString),
                               let createdAtTimestamp = recordingDict["createdAt"] as? Double {
                                let createdAt = Date(timeIntervalSince1970: createdAtTimestamp)
                                let transcription = recordingDict["transcription"] as? String
                                let duration = recordingDict["duration"] as? TimeInterval
                                let localURLString = recordingDict["localURL"] as? String
                                let localURL = URL(string: localURLString ?? "")
                                let recording = Recording(id: recordingDict["id"] as? String, fileURL: fileURL, localURL: localURL, createdAt: createdAt, transcription: transcription, duration: duration)
                                print(recording)
                                recordings.append(recording)
                            } else {
                                print("Failed to parse recording: \(recordingDict)")
                            }
                        }
                    }
                    
                    // Decode image URLs
                    let imageUrls: [URL] = (data["imageUrls"] as? [String])?.compactMap(URL.init) ?? []
                    let imageCaptions = data["imageCaptions"] as? [String] ?? []
                    
                    let journal = Journal(id: id, category: category, title: title, text: text, date: date, type: type, recordings: recordings, imageUrls: imageUrls, imageCaptions: imageCaptions, publishIndicator: publishIndicator, liked: liked)
                    
                    journals.append(journal)
                }
                
                if let lastDocument = querySnapshot?.documents.last {
                    self.lastDocumentSnapshot = lastDocument
                }

                completion(.success(journals))
            }
        }
    }


}
