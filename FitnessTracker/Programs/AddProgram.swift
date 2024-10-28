//
//  AddProgram.swift
//  FitnessTracker
//
//  Created by Matt on 10/26/24.
//

import SwiftUI

struct Program: Identifiable {
    var id: UUID = UUID()
    var name: String
    var exercises: [String]
}

struct AddProgram: View {
    var id: UUID = UUID()
    var gradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)
    var body: some View {
        NavigationView {
            ZStack {
                gradient.edgesIgnoringSafeArea(.all)
                List {
                    Text("Program Name")
                        .listRowBackground(Color.clear)
                        .font(.title)
                    TextField("Enter Program Name", text: .constant(""))
                        .padding(10)
                        .background(Color.blue.opacity(0.8).cornerRadius(10))
                        .padding(-3)
                        .foregroundColor(Color.white)
                        .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .toolbar {
                    ExerciseToolbar()
                }
            }
            .navigationTitle("Add Program")
        }
    }
}

#Preview {
    AddProgram()
}
