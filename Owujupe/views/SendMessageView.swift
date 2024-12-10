//
//  SendMessageView.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-12-04.
//


import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
struct SendMessageView: View {
    @State private var recipient = ""
    @State private var message = ""
    @EnvironmentObject var fireAuthHelper: FireAuthHelper
    var body: some View {
        NavigationView {
            VStack {
                TextField("Select recipient(s)", text: $recipient)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                TextEditor(text: $message)
                    .frame(height: 200)
                    .border(Color.gray, width: 1)
                    .padding(.horizontal)
                Button(action: {
                    sendMessage()
                }) {
                    Text("Send Message")
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Send a Message")
        }
    }
    
    func sendMessage() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        db.collection("messages").addDocument(data: [
            "recipient": recipient,
            "message": message,
            "timestamp": Timestamp(),
            "sender": userId // Store the sender's userId
        ]) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully.")
                recipient = ""
                message = ""
            }
        }
    }

}


#Preview {
    SendMessageView()
}
