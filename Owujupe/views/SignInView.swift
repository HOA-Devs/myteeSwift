//
//  SignInView.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-11-19.
//
import SwiftUI
import FirebaseAuth

struct SignInView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var showSignUp: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showForgotPassword: Bool = false
    
    @Binding var rootScreen: RootView
    @EnvironmentObject var fireAuthHelper: FireAuthHelper
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                HStack(spacing: 10) {
                    Text("MyTenancyPlus")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding(.top, 150)
                
                Group {
                    CustomTextField(
                        icon: "envelope",
                        placeholder: "Enter an Email",
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
                }
                
                // Remember Me Toggle
                               Toggle(isOn: $rememberMe) {
                                   Text("Remember Me")
                                       .font(.headline)
                                       .foregroundColor(.blue)
                               }
                               .padding(.horizontal)
                               .onChange(of: rememberMe) { newValue in
                                   if newValue {
                                       saveLoginCredentials(email: email, password: password)
                                   } else {
                                       clearLoginCredentials()
                                   }
                                   UserDefaults.standard.set(newValue, forKey: "RememberMe")
                               }
                .padding(.top, 10)
                
                Button(action: {
                    if !self.email.isEmpty && !self.password.isEmpty {
                        self.fireAuthHelper.signIn(email: self.email, password: self.password) { success, error in
                            if success {
                                self.rootScreen = .Home
                                if self.rememberMe {
                                    saveLoginCredentials(email: self.email, password: self.password)
                                } else {
                                    clearLoginCredentials()
                                }
                            } else {
                                self.alertMessage = error?.localizedDescription ?? "Sign in failed"
                                self.showAlert = true
                            }
                        }
                    } else {
                        self.alertMessage = "Email and password cannot be empty"
                        self.showAlert = true
                    }
                }) {
                    Text("Sign In")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.top, 20)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
                
                Button(action: {
                    self.showForgotPassword = true
                }) {
                    Text("Forgot Password?")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
                .sheet(isPresented: $showForgotPassword) {
                    ForgotPasswordView()
                }
                
                NavigationLink(destination: SignUpView(rootScreen: $rootScreen).environmentObject(fireAuthHelper), isActive: $showSignUp) {
                    EmptyView()
                }
                
                Button(action: {
                    self.showSignUp = true
                }) {
                    Text("Don't have an account? Sign Up")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 20)
            }
            .padding(30)
            .background(Color(UIColor.systemGroupedBackground))
            .onAppear {
                if let savedEmail = UserDefaults.standard.string(forKey: "savedEmail"),
                   let savedPassword = UserDefaults.standard.string(forKey: "savedPassword") {
                    self.email = savedEmail
                    self.password = savedPassword
                    self.rememberMe = true
                }
            }
        }
    }
    
    private func saveLoginCredentials(email: String, password: String) {
        UserDefaults.standard.set(email, forKey: "savedEmail")
        UserDefaults.standard.set(password, forKey: "savedPassword")
    }
    
    private func clearLoginCredentials() {
        UserDefaults.standard.removeObject(forKey: "savedEmail")
        UserDefaults.standard.removeObject(forKey: "savedPassword")
    }
}

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack {
            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                sendPasswordReset()
            }) {
                Text("Reset Password")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func sendPasswordReset() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                alertMessage = error.localizedDescription
            } else {
                alertMessage = "Password reset email sent successfully."
            }
            showAlert = true
        }
    }
}
