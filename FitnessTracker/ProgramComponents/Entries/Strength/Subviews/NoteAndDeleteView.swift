//
//  NoteAndDeleteView.swift
//  FitnessTracker
//
//  Created by Matt on 2/19/26.
//

import SwiftUI

struct NoteAndDeleteView: View {
    @ObservedObject var theme = ThemeManager.shared
    let exercise: String
    @Binding var note: String
    @Binding var showDeleteConfirmation: Bool // This binding is now correctly used
    var keyScope: DefaultsKeyScope
    var isFocused: FocusState<Bool?>.Binding
    var deleteExercise: (String) -> Void
    var defaults = UserDefaults.standard
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Note").font(.subheadline).padding(-4)
                HStack(alignment: .center, spacing: 8) {
                    ZStack(alignment: .topLeading) {
                        if note.isEmpty {
                            Text("Note")
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                        }
                        TextEditor(text: $note)
                            .focused(isFocused, equals: true)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 6)
                            .padding(.top, 6)
                            .frame(minHeight: 36, maxHeight: 96)
                    }
                    if !note.isEmpty {
                        Button(action: { note = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .contentShape(Rectangle())
                        }
                        .padding(.trailing, 6)
                        .padding(.vertical, 2)
                    }
                }
                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                .onAppear {
                    note = defaults.string(forKey: keyScope.scoped("note\(exercise)")) ?? ""
                }
                .onChange(of: note) {
                    defaults.set(note, forKey: keyScope.scoped("note\(exercise)"))
                }
            }
            Button(action: {
                isFocused.wrappedValue = nil
                showDeleteConfirmation = true // Now sets the binding, which will trigger the alert in the parent StrengthEntryView
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(12)
            }
            .accessibilityLabel("Delete exercise")
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    struct PreviewContainer: View {
        @State var note: String = "Test note"
        @State var showDelete: Bool = false
        @FocusState var focus: Bool?
        
        var body: some View {
            NoteAndDeleteView(
                exercise: "Bench Press",
                note: $note,
                showDeleteConfirmation: $showDelete,
                keyScope: .from(previewUserID: "dev_user", liveUserID: nil, programID: "preview_program_id", sessionID: "preview_session_id"), // Updated for consistency
                isFocused: $focus,
                deleteExercise: { name in print("Deleted \(name)") }
            )
            .padding()
            .background(Color.black.opacity(0.9))
        }
    }
    
    return PreviewContainer()
}

