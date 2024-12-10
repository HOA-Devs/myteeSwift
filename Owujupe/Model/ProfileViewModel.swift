//
//  ProfileViewModel.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-11-20.
//
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import PhotosUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userEmail = ""
    @Published var name = ""
    @Published var contact = ""
    @Published var profileImageUrl: URL?
    @Published var imageSelection: PhotosPickerItem? {
        didSet {
            Task {
                await uploadImage()
            }
        }
    }
    @Published var errorMessage: String? = nil
    private var db = Firestore.firestore()
    
    init() {
        if let user = Auth.auth().currentUser {
            userEmail = user.email ?? ""
            fetchUserData()
            if let photoURL = user.photoURL {
                profileImageUrl = photoURL
            }
        }
    }
    
    // Function to fetch user data (name and contact) from Firestore
    private func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Error fetching user data: \(error.localizedDescription)"
                return
            }
            
            guard let data = snapshot?.data() else { return }
            
            self.name = data["name"] as? String ?? "No name"
            self.contact = data["contactNumber"] as? String ?? "No phone number"
        }
    }
    
    // Function to update user profile data (name and contact) in Firestore
    func updateUserProfile(name: String, contact: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).updateData([
            "name": name,
            "contactNumber": contact
        ]) { error in
            if let error = error {
                self.errorMessage = "Error updating profile: \(error.localizedDescription)"
            } else {
                self.name = name
                self.contact = contact
            }
        }
    }
    
    // Function to handle user logout
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    // Function to upload image to Firebase Storage
    private func uploadImage() async {
        guard let item = imageSelection else { return }
        
        do {
            guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
            
            guard let user = Auth.auth().currentUser else { return }
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child("users/\(user.uid)/profile.jpg")
            
            _ = try await imageRef.putDataAsync(imageData, metadata: nil)
            let downloadURL = try await imageRef.downloadURL()
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.photoURL = downloadURL
            try await changeRequest.commitChanges()
            
            self.profileImageUrl = downloadURL
            updateProfileImageURLInFirestore(downloadURL)
        } catch {
            self.errorMessage = "Error uploading image: \(error.localizedDescription)"
        }
    }
    
    // Function to update profile image URL in Firestore
    private func updateProfileImageURLInFirestore(_ url: URL) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).updateData([
            "profileImagePath": url.absoluteString
        ]) { error in
            if let error = error {
                self.errorMessage = "Error updating profile image URL: \(error.localizedDescription)"
            }
        }
    }
}

