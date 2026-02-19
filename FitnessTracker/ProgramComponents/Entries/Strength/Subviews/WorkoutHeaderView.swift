//
//  WorkloutHeaderView.swift
//  FitnessTracker
//
//  Created by Matt on 2/19/26.
//
import SwiftUI

struct WorkoutHeaderView: View {
    @ObservedObject var theme = ThemeManager.shared
    let exercise: Exercise
    @Binding var isCompleted: Bool // New Binding passed from StrengthEntryView
    @Binding var setsCountInput: String
    @Binding var selectedSetIndex: Int
    var adjustPerSetArrays: (Int) -> Void
    var keyScope: DefaultsKeyScope
    @EnvironmentObject var auth: AuthManager
    var defaults = UserDefaults.standard
    var isFocused: FocusState<Bool?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Left Side: Exercise Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .foregroundColor(.white)
                        .font(.title2.bold()) // Slightly smaller than .title for better fit
                    Text("\(exercise.type?.rawValue ?? "Strength") exercise")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Right Side: Completion Toggle
                Button(action: {
                    withAnimation(.spring()) {
                        isCompleted.toggle()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("Exercise Complete")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                    }
                    .foregroundColor(isCompleted ? .green : .white.opacity(0.6))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(isCompleted ? Color.green.opacity(0.15) : Color.white.opacity(0.05))
                    .cornerRadius(10)
                }
            }
            
            Divider().background(Color.white.opacity(0.2))
            
            // Bottom Row: Sets Input
            HStack {
                Text("Total Sets")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                TextField("Sets", text: $setsCountInput)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 50, height: 35)
                    .background(theme.currentTheme.accent.opacity(0.3))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(theme.currentTheme.accent, lineWidth: 1))
                    .focused(isFocused, equals: true)
                    .onChange(of: setsCountInput) { oldValue, newValue in
                        let n = Int(newValue) ?? 1
                        
                        // 1. Persist the set count to UserDefaults immediately
                        defaults.set(n, forKey: keyScope.scoped("setsCount\(exercise.name)"))
                        
                        // 2. Adjust the arrays in the parent view
                        adjustPerSetArrays(n)
                    }
                    .onAppear {
                        // 3. Ensure the text field loads the saved value when it appears
                        let savedSets = defaults.integer(forKey: keyScope.scoped("sets\(exercise.name)"))
                        if savedSets > 0 {
                            setsCountInput = "\(savedSets)"
                        }
                    }
            }
        }
        .padding(.vertical, 10)
    }
}
