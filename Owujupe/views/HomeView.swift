//
//  HomeView.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-11-19.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct HomeView: View {
    @ObservedObject private var fireDBHelper = FireDBHelper.getInstance() // FireDBHelper instance
    @Binding var rootScreen: RootView
    @State private var showProfileUpdateView: Bool = false
    @State private var searchText: String = ""
    @EnvironmentObject var fireAuthHelper: FireAuthHelper
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var userName: String = ""

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Welcome header
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Welcome,")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text(userName)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            Spacer()
                            
                            // Notification button
                            Button(action: {
                                // Handle notifications
                            }) {
                                Image(systemName: "bell")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Search bar
                        HStack {
                            TextField("Search for vendors, management...", text: $searchText)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 10)
                        
                        
                        // Top activity section
                        Text("Top activity")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        
                        // Activity options
                        VStack(spacing: 15) {
                            NavigationLink(destination: SendMessageView()) {
                                ActivityRow(icon: "message", title: "Send management a message")
                            }
                            NavigationLink(destination: SignAgreementView()) {
                                ActivityRow(icon: "pencil", title: "Sign your agreement")
                            }
                            NavigationLink(destination: FundWalletView()) {
                                ActivityRow(icon: "dollarsign.square", title: "Fund wallet")
                            }
                            NavigationLink(destination: ContactVendorView()) {
                                ActivityRow(icon: "phone", title: "Contact vendor")
                            }
                            NavigationLink(destination: SubmitComplaintView()) {
                                ActivityRow(icon: "doc.text", title: "Submit & track complaint")
                            }
                        }
                        
                       
                            .padding()
                             Spacer()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                }
            }
          
        }
        .onAppear {
                   fetchUserName() // Fetch username on view load
               }
    }
    
    private func fetchUserName() {
        guard let userId = fireAuthHelper.user?.uid else {
            print("User not logged in.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user name: \(error.localizedDescription)")
                self.alertMessage = "Failed to fetch user name."
                self.showAlert = true
            } else if let document = document, document.exists {
                if let fetchedName = document.get("name") as? String {
                    self.userName = fetchedName
                }
            }
        }
    }

    
}

// Reusable row component for activity options
struct ActivityRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 32, height: 32)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .foregroundColor(.black)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}



struct SignAgreementView: View {
    var body: some View {
        Text("Sign your agreement")
            .font(.title)
    }
}

struct FundWalletView: View {
    var body: some View {
        Text("Fund your wallet")
            .font(.title)
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        return HomeView(rootScreen: .constant(.Login))
            .environmentObject(FireDBHelper.getInstance()) // Use the singleton instance
            .environmentObject(FireAuthHelper.getInstance())
    }
}
