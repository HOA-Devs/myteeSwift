//
//  SignUpView.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-11-19.
//
import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var contactNumber: String = ""
    @State private var photo: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var rootScreen: RootView
    
    @EnvironmentObject var fireAuthHelper: FireAuthHelper
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Text("Sign-Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 150)
                
                Group {
                    CustomTextField(
                        icon: "person.circle",
                        placeholder: "Enter Name",
                        text: $name,
                        keyboardType: .default,
                        isSecure: false
                    )
                    
                    CustomTextField(
                        icon: "envelope",
                        placeholder: "Enter Email",
                        text: $email,
                        keyboardType: .emailAddress,
                        isSecure: false
                    )
                    
                    CustomTextField(
                        icon: "lock",
                        placeholder: "Enter Password",
                        text: $password,
                        keyboardType: .default,
                        isSecure: true
                    )
                    
                    CustomTextField(
                        icon: "phone",
                        placeholder: "Contact Number",
                        text: $contactNumber,
                        keyboardType: .phonePad,
                        isSecure: false
                    )
                }
                
                Button(action: {
                    if validateInputs() {
                        isLoading = true
                        fireAuthHelper.signUp(
                            name: name,
                            email: email,
                            password: password,
                            contactNumber: contactNumber,
                            photo: photo
                        ) { success, error in
                            isLoading = false
                            if success {
                                rootScreen = .Login
                            } else {
                                alertMessage = error?.localizedDescription ?? "Sign up failed"
                                showAlert = true
                            }
                        }
                    } else {
                        showAlert = true
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    } else {
                        Text("Create Account")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
                .disabled(isLoading || name.isEmpty || email.isEmpty || password.isEmpty || contactNumber.isEmpty)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
                
            }
            .padding(20)
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    // MARK: - Validation
    private func validateInputs() -> Bool {
        if name.isEmpty {
            alertMessage = "Name cannot be empty."
            return false
        }
        
        if email.isEmpty {
            alertMessage = "Email cannot be empty."
            return false
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        if !NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email) {
            alertMessage = "Invalid email format."
            return false
        }
        
        if password.isEmpty {
            alertMessage = "Password cannot be empty."
            return false
        }
        
        if password.count < 6 {
            alertMessage = "Password must be at least 6 characters long."
            return false
        }
        
        if contactNumber.isEmpty {
            alertMessage = "Contact number cannot be empty."
            return false
        }
        
        return true
    }
}

struct CustomTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType
    var isSecure: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 5)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(rootScreen: .constant(.Login))
            .environmentObject(FireAuthHelper.getInstance())
    }
}
