//
//  Notifications.swift
//  FitnessTracker
//
//  Created by Matt on 2/12/26.
//

import SwiftUI

struct NotificationBadge: View {
    var body: some View {
        Circle()
            .fill(.red)
            .frame(width: 10, height: 10)
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
    }
}

struct BadgeModifier: ViewModifier {
    var showBadge: Bool

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if showBadge {
                    NotificationBadge()
                        .offset(x: 3, y: -3) // Adjust based on your icon padding
                }
            }
    }
}

extension View {
    func notificationBadge(show: Bool) -> some View {
        self.modifier(BadgeModifier(showBadge: show))
    }
}

