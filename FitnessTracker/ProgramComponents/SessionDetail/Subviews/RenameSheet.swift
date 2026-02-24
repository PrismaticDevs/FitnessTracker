//
//  RenameSheet.swift
//  FitnessTracker
//
//  Created by Matt on 2/23/26.
//
import SwiftUI

struct RenameSheet: View {
    @Binding var newName: String
    @Environment(\.dismiss) var dismiss
    @ObservedObject var theme = ThemeManager.shared
    var onRename: () -> Void

    var body: some View {
        VStack {
            Text("Rename Session")
                .font(.headline)
                .padding()

            TextField("New Session Name", text: $newName, prompt: Text("New Session Name").foregroundColor(.white.opacity(0.5)))
                .padding()
                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))

            Button("Rename") {
                onRename()
                dismiss()
            }
            .padding()
        }
        .padding()
    }
}
