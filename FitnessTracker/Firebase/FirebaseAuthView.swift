//
//  AuthView.swift
//  FitnessTracker
//
//  Created by Matt on 11/26/25.
//

import SwiftUI

struct FirebaseAuthView: View {
    @ObservedObject var viewModel = AuthManager()
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.isAuthenticated {
                    ContentView()
                } else {
                    TextField("Email", text: $email)
                        .padding(8)
                        .background(Color.blue.opacity(0.8).cornerRadius(8))
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    
                    SecureField("Password", text: $password)
                        .padding(8)
                        .background(Color.blue.opacity(0.8).cornerRadius(8))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    
                    HStack {
                        Button("Login") {
                            viewModel.signIn(email: email, password: password)
                        }
                        Button("Sign Up") {
                            viewModel.registerUser(email: email, password: password)
                        }
                    }
                }
            }
            .padding()
        }
        .applyGradientBackground()
    }
}

#Preview {
    FirebaseAuthView()
}
