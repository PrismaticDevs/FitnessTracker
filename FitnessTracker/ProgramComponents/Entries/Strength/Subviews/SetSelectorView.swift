//
//  SetSelectorView.swift
//  FitnessTracker
//
//  Created by Matt on 2/19/26.
//
import SwiftUI

struct SetSelectorView: View {
    @ObservedObject var theme = ThemeManager.shared
    let setsCount: Int
    @Binding var selectedSetIndex: Int
    var onSelect: () -> Void
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<setsCount, id: \.self) { idx in
                    Button(action: {
                        selectedSetIndex = idx
                        onSelect()
                    }) {
                        Text("Set \(idx + 1)")
                            .padding(8)
                            .background(selectedSetIndex == idx ? theme.currentTheme.accent.opacity(0.8) : .white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }.padding(.vertical, 6)
        }
    }
}

#Preview {
    SetSelectorView(setsCount: 3, selectedSetIndex: .constant(0)) {}
}
