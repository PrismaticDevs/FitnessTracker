//
//  WorkoutsMenu.swift
//  FitnessTracker
//
//  Created by Matt on 10/20/24.
//

import SwiftUI

struct WorkoutsMenu: View {
    var body: some View {
        NavigationView {
            Button {
                print("Add Workout")
            } label: {
                Label("Add Exercise", systemImage: "plus.circle.fill")
            }
        }
        .navigationTitle("Workouts")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    print("Add Workout")
                } label: {
                    Label("Add Exercise", systemImage: "plus.circle.fill")
                }
            }
        }
    }
}

//#Preview {
//    WorkoutsMenu()
//}

struct MenuView: View {
    var body: some View {
        ZStack {
            Menu {
                Text("Hello, World!")
            } label: {
                
            }
        }
    }
}

#Preview {
    MenuView()
}
