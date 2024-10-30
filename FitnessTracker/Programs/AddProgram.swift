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
    init() {
     // Large Navigation Title
     UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
     // Inline Navigation Title
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        ProgramName = ""
   }
    var id: UUID = UUID()
    var gradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)
    @State var ProgramName: String
    var body: some View {
        NavigationStack {
            ZStack {
                gradient.edgesIgnoringSafeArea(.all)
                List {
                    Text("Program Name")
                        .listRowBackground(Color.clear)
                        .font(.title)
                        .foregroundColor(Color.white)
                    TextField("Name", text: $ProgramName, prompt: Text("Enter Program Name").foregroundColor(Color.white.opacity(0.3)), axis: .vertical)
                        .lineLimit(1...4)
                        .padding(10)
                        .background(Color.blue.opacity(0.8).cornerRadius(10))
                        .padding(-3)
                        .foregroundColor(Color.white)
                        .overlay(
                                    Button(action: {
                                        ProgramName = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .opacity(ProgramName.isEmpty ? 0 : 1).padding()
                                        }
                                            .foregroundColor(Color.white)
                                            .padding(),
                                            alignment: .trailing
                                )
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
