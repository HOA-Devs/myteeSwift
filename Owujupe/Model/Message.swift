//
//  Message.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-12-04.
//

import Foundation
import FirebaseFirestore
struct Message: Identifiable, Codable {
    @DocumentID var id: String? // Firestore Document ID
    var recipient: String
    var content: String
    var timestamp: Date
    
    init(recipient: String, content: String, timestamp: Date) {
        self.recipient = recipient
        self.content = content
        self.timestamp = timestamp
        
    }
}
