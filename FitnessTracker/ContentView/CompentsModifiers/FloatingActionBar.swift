//
//  FloatingActionBar.swift
//  FitnessTracker
//
//  Created by Matt on 2/22/26.
//
import SwiftUI

struct FloatingActionBar<Content: View>: View {
    @ObservedObject var theme = ThemeManager.shared
    @ViewBuilder let content: Content

    var body: some View {
        HStack {
            content
        }
        // Everything in the bar sits on the accent color, so it stays white in both modes.
        .foregroundColor(.onAccent)
        .frame(width: UIScreen.main.bounds.width - 40, height: 60)
        .background(theme.currentTheme.accent)
        .cornerRadius(30)
        .shadow(color: .shadowColor, radius: 10, y: 5)
    }
}

