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
                    if !newValue.isEmpty {
                        print("📝 SetRow [\(title)] key='\(actualKey)' value='\(newValue)'")
                    }
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
        // 1. Try the full-scoped key (user.<program>.<session>.<base>)
        if let savedString = defaults.string(forKey: actualKey), !savedString.isEmpty {
            text = savedString
            return
        }
        // 2. Fallback: legacy-scoped key (user.<base>) — written before the program/session scope was added
        let legacyKey = keyScope.legacyScoped(baseKey)
        if let legacyValue = defaults.string(forKey: legacyKey), !legacyValue.isEmpty {
            text = legacyValue
            defaults.set(legacyValue, forKey: actualKey) // migrate to full scope
            return
        }
        // 3. Fallback: bare unscoped key — very old data
        if let ghostValue = defaults.string(forKey: baseKey), !ghostValue.isEmpty {
            text = ghostValue
            defaults.set(ghostValue, forKey: actualKey)
            return
        }
        // 4. Last resort: integer value at full-scoped key
        let savedInt = defaults.integer(forKey: actualKey)
        text = savedInt > 0 ? "\(savedInt)" : ""
    }
}

