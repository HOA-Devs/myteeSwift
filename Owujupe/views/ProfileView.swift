//
//  ProfileView.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-11-20.
//
import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var animateButton = false
    @ObservedObject var fireDBHelper = FireDBHelper.getInstance()
    @Binding var rootScreen: RootView
    @EnvironmentObject var fireAuthHelper: FireAuthHelper
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                // User Info Section
                VStack(alignment: .leading, spacing: 8) {
                    if let user = fireAuthHelper.user {
                        Text("Name:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(viewModel.name) // Assuming first name is stored in viewModel
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("Email:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(user.email ?? "No email available")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("Phone:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(viewModel.contact) // Assuming phone number is stored in viewModel
                            .font(.body)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No user logged in.")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
                
                // Logout Button
                Button(action: {
                    withAnimation {
                        signOut()
                    }
                }) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.black) // Change text color to black for contrast
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white) // White background for the logout button
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.white, Color(UIColor.systemGroupedBackground)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Sign-out functionality
    private func signOut() {
        fireAuthHelper.signOut { success, error in
            if success {
                self.rootScreen = .Login
            } else if let error = error {
                self.alertMessage = "Sign-out error: \(error.localizedDescription)"
                self.showAlert = true
            }
        }
    }
}

