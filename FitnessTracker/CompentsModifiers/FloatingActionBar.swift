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
        .frame(width: UIScreen.main.bounds.width - 40, height: 60)
        .background(theme.currentTheme.accent)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
    }
}

