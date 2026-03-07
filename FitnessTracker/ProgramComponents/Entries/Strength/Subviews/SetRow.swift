//
//  SwtRow.swift
//  FitnessTracker
//
//  Created by Matt on 2/19/26.
//

import SwiftUI

struct SetRow: View {
    @ObservedObject var theme = ThemeManager.shared
    @Binding var text: String
    // User defaults
    var defaults = UserDefaults.standard
    let title: String
    // Defualts keys
    let keyScope: DefaultsKeyScope
    let baseKey: String // e.g., "repsChest Press_set0"
    private var actualKey: String {
        return keyScope.scoped(baseKey)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline).padding(-4)
            TextField(text: $text, prompt: Text(title).foregroundColor(.white.opacity(0.5))) {
                Text(title) // This is the label for accessibility
            }
                .keyboardType(.numberPad)
                .padding(8)
                .submitLabel(.done)
                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(8))
                .onChange(of: text) { oldValue, newValue in
                    defaults.set(newValue, forKey: actualKey)
                }
                .onAppear {
                    loadData()
                }
                .frame(minWidth: 80)
        }
    }
    // MARK: - REMOVE
    private func debugUserDefaults() {
        print("--- 🔍 WORKOUT DATA AUDIT ---")
        let currentUserID = keyScope.userID
        let currentSessionID = keyScope.sessionID
        print("User: \(currentUserID) | Session: \(currentSessionID ?? "sessionID not set")")

        // List of exercises to check (example)
        let exercises = ["Chest Press", "Biceps Curl Machine", "Chest Fly"]
        
        for name in exercises {
            print("\nExercise: \(name)")
            for i in 0..<3 { // Checking first 3 sets
                let rKey = keyScope.scoped("reps\(name)_set\(i)")
                let wKey = keyScope.scoped("weight\(name)_set\(i)")
                let lKey = keyScope.scoped("left\(name)_set\(i)")
                let riKey = keyScope.scoped("right\(name)_set\(i)")
                
                let reps = UserDefaults.standard.string(forKey: rKey) ?? "N/A"
                let weight = UserDefaults.standard.string(forKey: wKey) ?? "N/A"
                let left = UserDefaults.standard.string(forKey: lKey) ?? "N/A"
                let right = UserDefaults.standard.string(forKey: riKey) ?? "N/A"
                
                print(" Set \(i): Reps[\(reps)] W[\(weight)] L[\(left)] R[\(right)]")
            }
        }
        print("--- 🏁 END AUDIT ---")
    }
    
    private func loadData() {
        // 4. Try the scoped key first
        if let savedString = defaults.string(forKey: actualKey) {
            text = savedString
        } else {
            // 5. EMERGENCY FALLBACK: Check for the "Ghost" key (un-scoped)
            // This is how you "catch" the old data and move it to the new scope!
            if let ghostValue = defaults.string(forKey: baseKey) {
                text = ghostValue
                defaults.set(ghostValue, forKey: actualKey) // Migrate it now!
            } else {
                let savedInt = defaults.integer(forKey: actualKey)
                text = savedInt > 0 ? "\(savedInt)" : ""
            }
        }
    }
}

