//
//  JournalListView.swift
//  journal
//
//  Created by Kun Chen on 2023-10-30.
//

import SwiftUI

struct JournalListView: View {
    
    @EnvironmentObject var journalManager: JournalManager
    
    @State private var journals = [Journal]()
    @State private var error: Error?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack{
                    ForEach(journals.indices, id: \.self) { index in
                        JournalListCardView(journal: $journals[index])
                            .onAppear {
                                if self.journals.last == journals[index] {
                                    self.fetchJournals()
                                }
                            }
                    }
                }
            }
            .navigationTitle("Journals")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchJournals()
            }
        }
    }
    
    func fetchJournals() {
        let firebaseManager = JournalManager()
        firebaseManager.fetchJournals { result in
            switch result {
            case .success(let journals):
                self.journals = journals
            case .failure(let error):
                self.error = error
                print(error.localizedDescription)
            }
        }
    }
}

struct JournalListCardView: View {
    
    @Binding var journal: Journal

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        
        ZStack{
            
            Color.white
                .ignoresSafeArea()
            
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.theme.backgroundColor, lineWidth: 1))
                
                HStack {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack{
                            Text(journal.category.capitalized)
                                .font(.caption)
                                .bold()
                            Spacer()
                            Text(dateFormatter.string(from: journal.date))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack{
                            Spacer()
                            
                            if !journal.recordings.isEmpty {
                                Image(systemName: "waveform")
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 5)
                            }
                            
                            if !journal.imageUrls.isEmpty {
                                Image(systemName: "photo")
                                    .foregroundColor(.purple)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text(journal.text)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                            
                            if !journal.recordings.isEmpty{
                                ForEach(journal.recordings, id: \.id) { recording in
                                    RecordingRow(audioURL: recording.fileURL, createdAt: recording.createdAt, duration: recording.duration)
                                        .padding()
                                        .background(Color.purple.opacity(0.3).clipShape(RoundedRectangle(cornerRadius: 10)))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                    
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
                                    }
                                }
                            }
                            
                            if !journal.imageUrls.isEmpty {
                                ForEach(journal.imageUrls, id: \.absoluteString) { imageUrl in
                                    AsyncImage(url: imageUrl) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                            
                            
                            if !journal.imageCaptions.isEmpty {
                                ForEach(journal.imageCaptions, id: \.self) { caption in
                                    if let extractedCaption = extractCaption(from: caption) {
                                        HStack{
                                            Image(systemName: "eye")
                                                .imageScale(.small)
                                                .foregroundColor(.black)
                                            
                                             Text(extractedCaption)
                                                .font(.caption)
                                                .foregroundColor(.black)
                                                .padding()
                                                .background(Color.purple.opacity(0.2))
                                                .cornerRadius(10)
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .padding()
        }
        

    }
    
}

struct JournalListView_Previews: PreviewProvider {
    static var previews: some View {
        JournalListView()
    }
}
