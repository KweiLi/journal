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
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.trailing,.leading], 20)
            .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
            .background(Color.theme.cardBackgroundColor)
            .cornerRadius(20)
        }
    }
}

struct JournalCard_Previews: PreviewProvider {
    static var previews: some View {
        JournalHomeView()
    }
}
