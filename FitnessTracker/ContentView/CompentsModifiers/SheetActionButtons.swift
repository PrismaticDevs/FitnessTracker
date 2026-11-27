//
//  SheetActionButtons.swift
//  FitnessTracker
//
//  The Cancel + primary action button pair used at the bottom of sheets
//  (same style as the Rename Program sheet in SessionsView).
//

import SwiftUI

struct SheetActionButtons: View {
    @ObservedObject var theme = ThemeManager.shared

    let primaryTitle: String
    var isPrimaryEnabled = true
    var isWorking = false
    /// Leave nil to hide the Cancel button (e.g. first-run setup that can't be skipped).
    var onCancel: (() -> Void)?
    let onPrimary: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            if let onCancel {
                Button(role: .cancel, action: onCancel) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            }

            Button(action: onPrimary) {
                ZStack {
                    Text(primaryTitle)
                        .fontWeight(.semibold)
                        .opacity(isWorking ? 0 : 1)
                    if isWorking {
                        ProgressView().tint(.onAccent)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isPrimaryEnabled ? theme.currentTheme.accent : Color.gray.opacity(0.35))
                .foregroundColor(.onAccent)
                .cornerRadius(12)
            }
            .disabled(!isPrimaryEnabled || isWorking)
            .shadow(color: theme.currentTheme.accent.opacity(isPrimaryEnabled ? 0.3 : 0), radius: 5, y: 3)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SheetActionButtons(primaryTitle: "Save", onCancel: {}, onPrimary: {})
        SheetActionButtons(primaryTitle: "Post", isPrimaryEnabled: false, onCancel: {}, onPrimary: {})
        SheetActionButtons(primaryTitle: "Create Profile", isWorking: true, onPrimary: {})
    }
    .padding()
}
