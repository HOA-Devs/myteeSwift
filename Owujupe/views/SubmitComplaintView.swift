//
//  SubmitComplaintView.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-12-02.
//

import SwiftUI
import FirebaseAuth

struct SubmitComplaintView: View {
    @State private var subject: String = ""
    @State private var message: String = ""
    @State private var isSubmitting: Bool = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    @ObservedObject private var dbHelper = FireDBHelper.getInstance()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Input fields for complaint
                TextField("Enter subject", text: $subject)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                TextEditor(text: $message)
                    .frame(height: 150)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // Submit button
                Button(action: {
                    submitComplaint()
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(isSubmitting)
                
                // New Track Complaints Button
                NavigationLink(destination: ComplaintListView()) {
                    Text("Track Complaints")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarTitle("Submit Complaint", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func submitComplaint() {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "You must be logged in to submit a complaint."
            showAlert = true
            return
        }

        isSubmitting = true
        let newComplaint = Complaint(
            subject: subject,
            message: message,
            userId: userId
        )
        
        dbHelper.insertComplaint(newComplaint: newComplaint)
        
        // Reset fields and notify user
        isSubmitting = false
        subject = ""
        message = ""
        alertMessage = "Complaint submitted successfully!"
        showAlert = true
    }
}

