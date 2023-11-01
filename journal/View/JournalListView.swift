//
//  JournalListView.swift
//  journal
//
//  Created by Kun Chen on 2023-10-30.
//

import SwiftUI
import Firebase

struct JournalListView: View {
    @EnvironmentObject var journalManager: JournalManager
    
    @State private var personalJournals = [Journal]()
    @State private var publicJournals = [Journal]()
    @State private var lastDocumentSnapshotforSelf: DocumentSnapshot? = nil
    @State private var lastDocumentSnapshotforPublic: DocumentSnapshot? = nil

    @State private var isLoading = false
    @State private var error: Error?
    @State private var selectedTab = 0

    var body: some View {
        ZStack{
            Color.white
                .ignoresSafeArea()
            
            VStack {
                Picker("Journals", selection: $selectedTab) {
                    Text("My Journals").tag(0)
                    Text("Public Journals").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedTab == 0 {
                    ScrollView {
                        VStack {
                            ForEach(personalJournals.indices, id: \.self) { index in
                                JournalListCardView(journal: $personalJournals[index])
                                    .onAppear {
                                        if index == personalJournals.count - 1 && !isLoading {
                                            fetchSelfJournals()
                                        }
                                    }
                            }
                            
                            if isLoading {
                                ProgressView()
                            }
                        }
                        .padding()
                    }
                    .onAppear {
                        if personalJournals.isEmpty {
                            fetchSelfJournals()
                        }
                    }
                } else {
                    ScrollView {
                        VStack {
                            ForEach(publicJournals.indices, id: \.self) { index in
                                JournalListCardView(journal: $publicJournals[index])
                                    .onAppear {
                                        if index == publicJournals.count - 1 && !isLoading {
                                            fetchPublicJournals()
                                        }
                                    }
                                    .environmentObject(journalManager)
                            }
                            
                            if isLoading {
                                ProgressView()
                            }
                        }
                        .padding()
                    }
                    .onAppear {
                        if publicJournals.isEmpty {
                            fetchPublicJournals()
                        }
                    }
                    
                }
            }
        }
    }
    
    func fetchSelfJournals() {
        isLoading = true
        
        journalManager.fetchSelfJournals(startingAfter: lastDocumentSnapshotforSelf) { result in
            isLoading = false

            switch result {
            case .success((let journals, let lastDocumentSnapshot)):
                self.personalJournals.append(contentsOf: journals)
                self.lastDocumentSnapshotforSelf = lastDocumentSnapshot
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchPublicJournals() {
        isLoading = true
        
        journalManager.fetchPublicJournals(startingAfter: lastDocumentSnapshotforPublic) { result in
            isLoading = false

            switch result {
            case .success((let journals, let lastDocumentSnapshot)):
                self.publicJournals.append(contentsOf: journals)
                self.lastDocumentSnapshotforPublic = lastDocumentSnapshot
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}


struct JournalListCardView: View {
    @EnvironmentObject var journalManager: JournalManager

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
                
                VStack(alignment: .leading, spacing: 15) {
                    // MARK: journal category and journal date
                    HStack{
                        Text(journal.category.capitalized)
                            .font(.caption)
                            .foregroundColor(.black)
                            .bold()
                        Spacer()
                        Text(dateFormatter.string(from: journal.date))
                            .font(.caption)
                            .foregroundColor(.black)
                            .foregroundColor(.gray)
                    }
                    
                    
                    // MARK: indicators to show the image or voice
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
                    
                    // MARK: journal content
                    VStack(alignment: .leading, spacing: 10) {
                        Text(journal.text)
                            .font(.caption)
                            .foregroundColor(.black)
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
                    
                    HStack {
                        Spacer()
                        HStack{
                            Image(systemName: journal.likedIndicator ? "heart.fill" : "heart")
                                .foregroundColor(journal.likedIndicator ? .purple : .gray)
                                .font(.footnote)
                                .onTapGesture {
                                    journal.likedIndicator = !journal.likedIndicator
                                    if journal.likedIndicator {
                                        journal.liked += 1
                                    } else {
                                        journal.liked -= 1
                                    }
                                    
                                    journalManager.updateJournalLikedStatus(journalId: journal.id!, isLiked: journal.likedIndicator, likeCount: journal.liked)

                                }
                            Text(String(journal.liked))
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
    }
}

struct CustomPicker: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack {
            Button(action: {
                self.selectedTab = 0
            }) {
                Text("My Journals")
                    .foregroundColor(self.selectedTab == 0 ? .white : .black)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(self.selectedTab == 0 ? Color.purple : Color.white)
                    .cornerRadius(5)
            }
            .frame(maxWidth: .infinity)

            Button(action: {
                self.selectedTab = 1
            }) {
                Text("Public Journals")
                    .foregroundColor(self.selectedTab == 1 ? .white : .black)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(self.selectedTab == 1 ? Color.purple : Color.white)
                    .cornerRadius(5)
            }
            .frame(maxWidth: .infinity)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.purple, lineWidth: 2)
        )
    }
}

struct JournalListView_Previews: PreviewProvider {
    static var previews: some View {
            ForEach(ColorScheme.allCases, id: \.self) {
                JournalHomeView().preferredColorScheme($0)
                    .environmentObject(JournalManager())
            }
        }
}
