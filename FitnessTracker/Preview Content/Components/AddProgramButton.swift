//
//  ProgramButton.swift
//  FitnessTracker
//
//  Created by Matt on 2/22/26.
//

import SwiftUI

struct AddProgramButton: View {
    @ObservedObject var theme = ThemeManager.shared
    @State private var isHovering = false
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 0 : 6) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(Color.white)
            if !compact {
                Text("Add Program")
                    .font(.headline)
            }
        }
        .padding(compact ? 0 : 8)
        .foregroundColor(theme.currentTheme.accent)
        .animation(.easeInOut(duration: 0.12), value: isHovering)
        .cornerRadius(8)
        .contentShape(Rectangle()) // helps hit-testing
        .accessibilityLabel("Add Program")
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
