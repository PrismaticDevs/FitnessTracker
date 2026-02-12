//
//  SocialEntry.swift
//  FitnessTracker
//
//  Created by Matt on 2/12/26.
//

import SwiftUI
import FirebaseAuth

struct SocialEntry: View {
    @ObservedObject var theme = ThemeManager.shared
    @EnvironmentObject var auth: AuthManager
    var body: some View {
        ScrollView {
            HStack {
                Image(systemName: "bubble.left.and.bubble.right")
                    .foregroundColor(theme.currentTheme.accent)
                Text("FiT Social")
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.accent)
            }
            .padding()
            .foregroundColor(.white.opacity(0.1))
            .cornerRadius(8)
        }
        .onAppear {
            Task {
                await auth.clearNotification(for: .social)
            }
        }
    }
}
