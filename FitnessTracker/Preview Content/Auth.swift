//
//  Auth.swift
//  FitnessTracker
//
//  Created by Brignola, Matthew on 10/11/24.
//

import LocalAuthentication
import SwiftUI

struct Auth: View {
    @State private var isUnlocked = false
    
    var body: some View {
        VStack {
            if isUnlocked {
                Hypertrophy()
            } else {
                Text("Must  Authenticate")
                Button("Retry", action: { authenticate() })
            }
        }
        .onAppear(perform: authenticate)
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authentication required"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                if success {
                    isUnlocked = true
                } else {
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                        success, error in
                        if success {
                            isUnlocked = true
                        } else {
                            
                        }
                    }
                }
                
            }
        } else {
            
        }
    }
}

#Preview {
    Auth()
}
