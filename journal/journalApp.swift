//
//  journalApp.swift
//  journal
//
//  Created by Kun Chen on 2023-10-02.
//

import SwiftUI
import Firebase

@main
struct journalApp: App {
    init(){
        FirebaseApp.configure()
    }
    
    @StateObject var journalManager = JournalManager()
    
    var body: some Scene {
        WindowGroup {
            JournalHomeView()
                .environmentObject(journalManager)
        }
    }
}
