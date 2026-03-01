//
//  ProgramRowView.swift
//  FitnessTracker
//
//  Created by Matt on 2/22/26.
//

import SwiftUI

struct ProgramRowView: View {
    @Environment(\.modelContext) var context
    @ObservedObject var theme = ThemeManager.shared
    @State var program: WorkoutProgram
    
    var body: some View {
        HStack {
            Button(action: {
                // Toggle the starred state
                program.starred.toggle()
                // Save the context if needed
                try? context.save()
            }) {
                Image(systemName: program.starred ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
            .buttonStyle(PlainButtonStyle()) // Prevents the button from changing appearance
            
            Spacer()
            
            NavigationLink(destination: SessionsView(program: program)) {
                Text(program.title)
                    .foregroundColor(.white) // Optional: Set text color for better visibility
            }
            .buttonStyle(PlainButtonStyle()) // Prevents the link from changing appearance
        
        }
        .listRowBackground(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1)) // Subtle glass effect
                    .padding(.vertical, 4)
            )
        .padding()
    }
}
