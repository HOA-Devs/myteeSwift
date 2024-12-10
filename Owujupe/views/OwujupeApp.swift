//
//  OwujupeApp.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-11-19.
//

import SwiftUI
import Firebase
import FirebaseFirestore

@main
struct OwujupeApp: App {
    // Initialize FireDBHelper as an environment object
    @StateObject var fireDBHelper = FireDBHelper.getInstance()

    init() {
        FirebaseApp.configure()
        // You can initialize Firestore inside FireDBHelper.getInstance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(fireDBHelper)
                .environmentObject(FireAuthHelper.getInstance())
        }
    }
}
