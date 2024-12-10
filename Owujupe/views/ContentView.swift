//
//  ContentView.swift
//  Owujupe
//
//  Created by Aathi Abhishek T on 2024-11-19.
//

import SwiftUI

struct ContentView: View {
    
    // Shared instances of helpers
    var firedbHelper: FireDBHelper = FireDBHelper.getInstance()
    var fireAuthHelper: FireAuthHelper = FireAuthHelper.getInstance()
    
    // Current root screen state
    @State private var root: RootView = .Login
    
    var body: some View {
        NavigationStack {
            // Conditional view based on root state (Login, Home, etc.)
            switch root {
            case .Login:
                SignInView(rootScreen: self.$root)
                    .environmentObject(firedbHelper)
                    .environmentObject(fireAuthHelper)
                
            case .SignUp:
                SignUpView(rootScreen: self.$root)
                    .environmentObject(firedbHelper)
                    .environmentObject(fireAuthHelper)
                
            case .Home:
                TabView {
                    // Home Tab
                    HomeView(rootScreen: self.$root)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .environmentObject(firedbHelper)
                        .environmentObject(fireAuthHelper)
                    
                    // Profile Tab
                    ProfileView(rootScreen: self.$root)
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                        .environmentObject(firedbHelper)
                        .environmentObject(fireAuthHelper)
                }
                
            case .Profile:
                // Profile View outside of TabView
                ProfileView(rootScreen: self.$root)
                    .environmentObject(firedbHelper)
                    .environmentObject(fireAuthHelper)
            }
        }
    }
}
