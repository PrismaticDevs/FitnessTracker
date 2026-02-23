//
//  EmptyStateView.swift
//  FitnessTracker
//
//  Created by Matt on 2/22/26.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        ContentUnavailableView(label: {
            Label("No programs to list", systemImage: "list.bullet.rectangle.portrait")
                .foregroundColor(.white)
        }, description: {
            Text("Start by creating a program")
                .foregroundColor(.white)
        }, actions: {
            NavigationLink(destination: AddWorkoutProgramView()) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Program")
                        .font(.headline)
                }
                .padding()
                .cornerRadius(8)
            }
            .padding()
        })
    }
}
