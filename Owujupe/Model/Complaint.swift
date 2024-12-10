//
//  Complaint.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-11-30.
//
import Foundation
import FirebaseFirestore

struct Complaint: Identifiable, Hashable, Codable {
    @DocumentID var id: String? // Firestore document ID
    let subject: String
    let message: String
    let userId: String
    
    // Default initializer
    init(subject: String, message: String, userId: String) {
        self.subject = subject
        self.message = message
        self.userId = userId
    }
}


