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
    @Binding var showDeleteConfirmation: Bool
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
                showDeleteConfirmation = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .accessibilityLabel("Delete exercise")
            .confirmationDialog("Delete Exercise",
                                isPresented: $showDeleteConfirmation,
                                titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    print("🚨 Delete confirmed for exercise: \(exercise)")
                    deleteExercise(exercise)
                }
                Button("Cancel", role: .cancel) {
                    print("🚫 Delete cancelled for exercise: \(exercise)")
                }
            } message: {
                Text("Are you sure you want to remove \(exercise) from this session?")
            }
        }
    }
}

#Preview {
    // We use a container to manage the @FocusState and @State
    struct PreviewContainer: View {
        @State var note: String = "Test note"
        @State var showDelete: Bool = false
        @FocusState var focus: Bool? // This matches your Bool? type
        
        var body: some View {
            NoteAndDeleteView(
                exercise: "Bench Press",
                note: $note,
                showDeleteConfirmation: $showDelete,
                // Assuming DefaultsKeyScope has this initializer
                keyScope: .from(previewUserID: "dev_user", liveUserID: nil),
                isFocused: $focus,
                deleteExercise: { name in print("Deleted \(name)") }
            )
            .padding()
            .background(Color.black.opacity(0.9)) // So you can see the white text
        }
    }
    
    return PreviewContainer()
}
