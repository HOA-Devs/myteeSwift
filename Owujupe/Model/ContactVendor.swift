//
//  ContactVendor.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-12-04.
//

import Foundation
import FirebaseFirestore
struct Vendor: Identifiable {
    let id: String
    let name: String
    let role: String
    let phone: String
    
    init(name: String, id: String, role: String, phone: String) {
        self.name = name
        self.id = id
        self.role = role
        self.phone = phone
    }
}

