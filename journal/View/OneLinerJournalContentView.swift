//
//  JournalTagSelectionView.swift
//  AppJournal
//
//  Created by Kun Chen on 2023-08-31.
//

import SwiftUI

struct OneLinerJounalContentView: View {
    
    @EnvironmentObject var journalManager: JournalManager
    
    let journalTags = ["Poetry", "Fitness", "Dream", "Accomplishment", "Gratitude"]
    let journalImages = ["poetryimage", "fitnessimage", "dreamimage", "accomplishmentimage", "gratitudeimage"]
    let journalExamplebyType: [String: String] = [
        "Poetry": """
        Example: "Like a butterfly's wings, life is fragile yet beautiful."
        """,
        "Fitness": """
        Example: "Ran 5 miles today and felt amazing!"
        """,
        "Dream": """
        Example: "In my dream, I found a hidden treasure in an enchanted forest."
        """,
        "Accomplishment": """
        Example: "Reached my savings goal for this month."
        """,
        "Gratitude": """
        Example: "Grateful for a loving family that always supports me."
        """,
    ]
    
    @State private var selectedTag: Int = 0
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack{
            Text(Date(), style: .date)
                .font(.title3)
                .fontWeight(.bold)
            
            VStack {
                
                Text("Pick journal type: \(journalTags[selectedTag])")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                HStack {
                    Button(action: {
                        if selectedTag > 0 {
                            selectedTag -= 1
                            journalManager.currentJournal.type = journalTags[selectedTag]
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(8)
                            .foregroundColor(selectedTag > 0 ? .white : .gray)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.purple)
                                    .frame(width: 36, height: 100)
                                    .shadow(color: .gray, radius: 4, x: 0, y: 0)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedTag == 0)
                    
                    Spacer()
                    
                    Image(journalImages[selectedTag])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 230, height: 230, alignment: .center)
                        .cornerRadius(30)
                        .clipped()
                        .gesture(
                            DragGesture(minimumDistance: 100)
                                .onEnded { value in
                                    withAnimation(.easeInOut(duration: 0.5)){
                                        if value.predictedEndTranslation.width > 0 {
                                            // Swipe right
                                            if selectedTag > 0 {
                                                selectedTag -= 1
                                                journalManager.currentJournal.type = journalTags[selectedTag]
                                            }
                                        } else {
                                            // Swipe left
                                            if selectedTag < journalImages.count - 1 {
                                                selectedTag += 1
                                                journalManager.currentJournal.type = journalTags[selectedTag]
                                            }
                                        }
                                    }
                                }
                        )
                    
                    Spacer()
                    
                    Button(action: {
                        if selectedTag < journalImages.count - 1 {
                            selectedTag += 1
                            journalManager.currentJournal.type = journalTags[selectedTag]
                        }
                    }) {
                        Image(systemName: "arrow.right")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(8)
                            .foregroundColor(selectedTag < journalImages.count - 1 ? .white : .gray)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.purple)
                                    .frame(width: 36, height: 100)
                                    .shadow(color: .gray, radius: 4, x: 0, y: 0)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedTag == journalImages.count - 1)
                }
                
                JournalPublicToggleView(toggle: $journalManager.currentJournal.publishIndicator)
                    .padding(.horizontal)
                
                ZStack(alignment: .leading) {
                    // The placeholder
                    if journalManager.currentJournal.text.isEmpty && !isTextFieldFocused {
                        Text("\(journalExamplebyType[journalTags[selectedTag]] ?? "")")
                            .font(.footnote)
                            .foregroundColor(.gray) // Adjust this to the color you want
                            .padding(.all, 20)
                    }

                    // The actual TextField
                    TextField("", text: $journalManager.currentJournal.text, axis: .vertical)
                        .focused($isTextFieldFocused)
                        .font(.footnote)
                        .foregroundColor(.black)
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                        .cornerRadius(10)
                        .lineLimit(5...)
                        .padding()
                }

            }
            .padding()
        }
    }
}
