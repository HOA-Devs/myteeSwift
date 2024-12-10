//
//  UserProfile.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-11-30.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Identifiable, Hashable, Codable {
    @DocumentID var id: String?
    var photo: String
    var name: String
    var email: String
    var contactNumber: String
    
    
    init(name: String, email: String, contactNumber: String, photo: String) {
        self.name = name
        self.photo = photo
        self.email = email
        self.contactNumber = contactNumber
       
    }
}
