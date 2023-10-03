//
//  JournalManager.swift
//  journal
//
//  Created by Kun Chen on 2023-10-03.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


class JournalManager: ObservableObject{

    init(){
        db = Firestore.firestore()
    }
    
    private var db: Firestore
    var currentJournal: Journal = Journal()

}
