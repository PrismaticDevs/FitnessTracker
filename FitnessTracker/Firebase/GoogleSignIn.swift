//////
//////  GoogleSignIn.swift
//////  FitnessTracker
//////
//////  Created by Matt on 12/6/25.
//////
//
//import SwiftUI
//import GoogleSignIn
//import FirebaseCore
//import FirebaseAuth
//import UIKit
//
//func googleSignIn() {
//    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
//
//    let config = GIDConfiguration(clientID: clientID)
//
//    guard let presentingVC = UIApplication.shared.connectedScenes
//        .compactMap({ $0 as? UIWindowScene })
//        .flatMap({ $0.windows })
//        .first(where: { $0.isKeyWindow })?
//        .rootViewController else { return }
//
//    GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC, hint: nil) { result, error in
//        if let error = error {
//            print("Failed to sign in with Google: \(error.localizedDescription)")
//            return
//        }
//
//        guard
//            let authentication = user.authentication,
//            let idToken = authentication.idToken
//        else {
//            print("Missing auth tokens")
//            return
//        }
//
//        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
//                                                       accessToken: authentication.accessToken)
//
//        Auth.auth().signIn(with: credential) { authResult, error in
//            if let error = error {
//                print("Firebase sign-in error: \(error.localizedDescription)")
//                return
//            }
//            print("Signed in as: \(authResult?.user.uid ?? "unknown")")
//        }
//    }
//}
