//
//  JournalCard.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import SwiftUI

import SwiftUI

struct JournalCard<Destination: View>: View {
    let title: String
    let description: String
    let image: String
    let destination: Destination

    init(title: String, description: String, image: String, @ViewBuilder destination: () -> Destination) {
        self.title = title
        self.description = description
        self.image = image
        self.destination = destination()
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.theme.backgroundColor, lineWidth: 1))
                
                VStack{
                    Spacer()
                    HStack(spacing: 20) {
                        Image(image)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .cornerRadius(20)
                        
                        VStack(alignment: .leading, spacing: 15){
                            Text(title)
                                .font(.headline)
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                            
                            Text(description)
                                .font(.footnote)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    Spacer()
                }
                .padding()
            }
        }
    }
}

struct JournalCard_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            JournalHomeView().preferredColorScheme($0)
                .environmentObject(JournalManager())

        }
    }
}
