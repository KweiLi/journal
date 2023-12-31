//
//  JournalHomeView.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import SwiftUI

struct JournalHomeView: View {
    var body: some View {
        NavigationView {
            ZStack{
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    JournalCard(
                            title: "One Liner",
                            description: "quick daily reflections and build mindfulness",
                            image: "one-liner"){
                                OneLinerJournalView()
                            }

                    JournalCard(
                            title: "Quick Voice",
                            description: "effortless and expressive capture of thoughts and emotions",
                            image: "voice-record"){
                                VoiceJournalView()
                            }
                    
                    JournalCard(
                            title: "Self Reflection",
                            description: "introspection, self-awareness, and self-discovery",
                            image: "traditional-journal"){
                                JournalWriterView()
                            }
                }
                .padding()
            }
            .navigationTitle("Select Jounal Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Select Jounal Type")
                        .foregroundColor(.black)
                        .bold()
                }
            }
            .navigationBarItems(
                trailing:
                    NavigationLink(destination: {
                        JournalListView()
                    }, label: {
                        Image(systemName: "doc.append")
                            .foregroundColor(.purple)
                    }))
        }
    }
}



struct JournalHomeView_Preview: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            JournalHomeView().preferredColorScheme($0)
                .environmentObject(JournalManager())

        }
        
    }
}

