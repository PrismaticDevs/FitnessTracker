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
                    if let value = Int(newValue) {
                        defaults.set(value, forKey: exerciseKey)
                    } else {
                        defaults.set(0, forKey: exerciseKey)
                    }
                }
                .onAppear {
                    text = "\(defaults.integer(forKey: exerciseKey))"
                }
                .frame(minWidth: 80)
        }
    }
}
