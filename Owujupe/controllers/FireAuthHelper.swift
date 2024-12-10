//
//  FireAuthHelper.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-11-26.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

class FireAuthHelper: ObservableObject {
    @Published var user: User? {
        didSet {
            objectWillChange.send()
        }
    }

    private static var shared: FireAuthHelper?
    private let db = Firestore.firestore()
    
    static func getInstance() -> FireAuthHelper {
        if shared == nil {
            shared = FireAuthHelper()
            shared?.listenToAuthState() // Start listening to auth state changes
        }
        return shared!
    }
    
    private init() {
        self.user = Auth.auth().currentUser
    }
    
    func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.user = user
        }
    }
    
    func signUp(name: String, email: String, password: String, contactNumber: String, photo: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let result = authResult else {
                print("Error creating account: \(error?.localizedDescription ?? "No error description")")
                DispatchQueue.main.async { completion(false, error) }
                return
            }
            self.user = result.user
            UserDefaults.standard.set(self.user?.email, forKey: "KEY_EMAIL")
            self.saveUserProfile(name: name, email: email, contactNumber: contactNumber, photo: photo) { success, error in
                DispatchQueue.main.async { completion(success, error) }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard let result = authResult else {
                print("Error signing in: \(error?.localizedDescription ?? "No error description")")
                DispatchQueue.main.async { completion(false, error) }
                return
            }
            self.user = result.user
            UserDefaults.standard.set(self.user?.email, forKey: "KEY_EMAIL")
            DispatchQueue.main.async { completion(true, nil) }
        }
    }
    
    func signOut(completion: @escaping (Bool, Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            self.user = nil // Clear user data
            DispatchQueue.main.async { completion(true, nil) }
        } catch let error {
            DispatchQueue.main.async { completion(false, error) }
        }
    }
    
    private func saveUserProfile(name: String, email: String, contactNumber: String, photo: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let user = user else {
            DispatchQueue.main.async {
                completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"]))
            }
            return
        }
        
        let userProfile = [
            "name": name,
            "email": email,
            "contactNumber": contactNumber,
            "photo": photo
        ]
        
        db.collection("users").document(user.uid).setData(userProfile) { error in
            DispatchQueue.main.async {
                completion(error == nil, error)
            }
        }
    }
}
