//
//  SwtRow.swift
//  FitnessTracker
//
//  Created by Matt on 2/19/26.
//

import SwiftUI

struct SetRow: View {
    @ObservedObject var theme = ThemeManager.shared
    var defaults = UserDefaults.standard
    let title: String
    @Binding var text: String
    let exerciseKey: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline).padding(-4)
            TextField(title, text: $text)
                .keyboardType(.numberPad)
                .padding(8)
                .submitLabel(.done)
                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(8))
                .onChange(of: text) { oldValue, newValue in
                    defaults.set(newValue, forKey: exerciseKey)
                    print("💾 SAVED: [\(newValue)] to KEY: \(exerciseKey)")
                }
                .onAppear {
//                    text = defaults.string(forKey: exerciseKey) ?? ""
                    loadData()
                }
                .frame(minWidth: 80)
        }
    }
    
    private func loadData() {
            // Attempt to fetch as string first
            if let savedString = defaults.string(forKey: exerciseKey) {
                text = savedString
            } else {
                // Fallback: If it was saved as an Int previously, convert it to String
                let savedInt = defaults.integer(forKey: exerciseKey)
                text = savedInt > 0 ? "\(savedInt)" : ""
            }
            print("🔍 FETCHED: [\(text)] from KEY: \(exerciseKey)")
        }
}

