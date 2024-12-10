//
//  ContactVendorView.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-12-04.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct ContactVendorView: View {
    @State private var errorMessage: String?
    @State private var vendors = [
        Vendor(name: "Clement Joseph", id: "1", role: "Painter", phone: "1234567890"),
    ]
    @EnvironmentObject var fireAuthHelper: FireAuthHelper
    @State private var isAddingVendor = false
    @State private var newVendorName = ""
    @State private var newVendorRole = ""
    @State private var newVendorPhone = ""

    var body: some View {
        NavigationView {
            VStack {
                List(vendors) { vendor in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(vendor.name).font(.headline)
                            Text(vendor.role).font(.subheadline)
                        }
                        Spacer()
                        HStack {
                            Button(action: {
                                callVendor(phone: vendor.phone)
                            }) {
                                Image(systemName: "phone.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                // Button to open the Add Vendor Form
                Button(action: {
                    isAddingVendor.toggle()
                }) {
                    Text("Add New Vendor")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
            .sheet(isPresented: $isAddingVendor) {
                AddVendorForm(
                    isPresented: $isAddingVendor,
                    onAddVendor: addNewVendor
                )
            }
            .navigationTitle("Contact Vendor")
            .onAppear(perform: fetchVendors)
        }
    }
    
    func callVendor(phone: String) {
        if let phoneURL = URL(string: "tel://\(phone)") {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
    
    func saveVendorToFirestore(vendor: Vendor) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        db.collection("vendors").document(vendor.id).setData([
            "name": vendor.name,
            "role": vendor.role,
            "phone": vendor.phone,
            "userId": userId // Associate the vendor with the logged-in user
        ]) { error in
            if let error = error {
                print("Error saving vendor: \(error.localizedDescription)")
            } else {
                print("Vendor saved successfully.")
            }
        }
    }


    func fetchVendors() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "You are not signed in."
            return
        }
        
        db.collection("vendors")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    errorMessage = "Failed to load contacts: \(error.localizedDescription)"
                } else {
                    vendors = snapshot?.documents.compactMap { doc -> Vendor? in
                        guard let name = doc["name"] as? String,
                              let role = doc["role"] as? String,
                              let phone = doc["phone"] as? String else {
                            return nil
                        }
                        return Vendor(name: name, id: doc.documentID, role: role, phone: phone)
                    } ?? []
                    errorMessage = nil
                }
            }
    }

    
    func addNewVendor(name: String, role: String, phone: String) {
        let newVendor = Vendor(name: name, id: UUID().uuidString, role: role, phone: phone)
        vendors.append(newVendor)
        saveVendorToFirestore(vendor: newVendor)
    }
}

struct AddVendorForm: View {
    @Binding var isPresented: Bool
    var onAddVendor: (String, String, String) -> Void

    @State private var name = ""
    @State private var role = ""
    @State private var phone = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Vendor Details")) {
                    TextField("Name", text: $name)
                    TextField("Role", text: $role)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("Add Vendor")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !name.isEmpty && !role.isEmpty && !phone.isEmpty {
                            onAddVendor(name, role, phone)
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}
