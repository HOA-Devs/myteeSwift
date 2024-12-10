//
//  FireDBHelper.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-11-19.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

class FireDBHelper: ObservableObject {
    // Published properties for SwiftUI to observe
    @Published var complaintList = [Complaint]() // List of complaints
    @Published var userProfile: UserProfile?     // User profile details

    // Firestore collection constants
    private let COLLECTION_USER = "users"
    private let COLLECTION_NAME = "TenancyComplaints"

    // Firestore database instance
    private let db: Firestore

    // Singleton instance
    private static var shared: FireDBHelper?

    // Initialize the helper with a Firestore instance
    private init(db: Firestore) {
        self.db = db
    }

    // Singleton accessor
    static func getInstance() -> FireDBHelper {
        if shared == nil {
            shared = FireDBHelper(db: Firestore.firestore())
        }
        return shared!
    }

    // Check if a user is logged in
    var isUserLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }

    //  Insert Complaint
    func insertComplaint(newComplaint: Complaint) {
        do {
            try self.db.collection(COLLECTION_NAME).addDocument(from: newComplaint) { error in
                if let error = error {
                    print("Error adding complaint: \(error.localizedDescription)")
                } else {
                    print("Complaint added successfully")
                }
            }
        } catch let error {
            print("Unable to insert the document to Firestore: \(error)")
        }
    }

    // Get All Complaints for the Logged-in User
    func getUserComplaints() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        db.collection(COLLECTION_NAME)
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching complaints: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = querySnapshot else {
                    print("No complaints available")
                    return
                }

                DispatchQueue.main.async {
                    self.complaintList = snapshot.documents.compactMap { document in
                        do {
                            return try document.data(as: Complaint.self)
                        } catch {
                            print("Error decoding complaint: \(error)")
                            return nil
                        }
                    }
                    print("Fetched \(self.complaintList.count) complaints")
                }
            }
    }

    //  Get User Profile
    func getUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection(COLLECTION_USER).document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                do {
                    self.userProfile = try document.data(as: UserProfile.self)
                    print("User profile fetched successfully")
                } catch let error {
                    print("Error decoding user profile: \(error)")
                }
            } else {
                print("User profile does not exist")
            }
        }
    }

    //  Update User Profile
    func updateUserProfile(profileToUpdate: UserProfile) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: Invalid user ID")
            return
        }

        do {
            try db.collection(COLLECTION_USER).document(userId).setData(from: profileToUpdate) { error in
                if let error = error {
                    print("Error updating user profile: \(error)")
                } else {
                    print("User profile successfully updated")
                }
            }
        } catch let error {
            print("Error updating user profile: \(error)")
        }
    }

    // Get All Complaints (For Admin or All-User View)
    func getAllComplaints() {
        db.collection(COLLECTION_NAME).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching all complaints: \(error.localizedDescription)")
                return
            }

            guard let snapshot = querySnapshot else {
                print("No complaints available")
                return
            }

            DispatchQueue.main.async {
                self.complaintList = snapshot.documents.compactMap { document in
                    do {
                        return try document.data(as: Complaint.self)
                    } catch {
                        print("Error decoding complaint: \(error)")
                        return nil
                    }
                }
                print("Fetched \(self.complaintList.count) complaints for all users")
            }
        }
    }
}

