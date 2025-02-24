//
//  SessionView.swift
//  FitnessTracker
//
//  Created by Matt on 2/11/25.
//

import SwiftUI

struct SessionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var program: WorkoutProgram
    @EnvironmentObject var workoutHistory: WorkoutHistory
    @EnvironmentObject var workoutProgramsData: WorkoutProgramsData
    @State private var showDeleteConfirmation: Bool = false
    @State private var confirmDeletion: Bool = false
    
    var body: some View {
        VStack {
            Text(program.title)
                .font(.title)
            
            List {
                ForEach(program.sessions) { session in
                    NavigationLink(destination: SessionDetailView(session: session)) {
                        Text(session.name)
                    }
                    .background(Color.clear)
                    .padding()
                    .listStyle(PlainListStyle())
                }
                .listRowBackground(Color.blue)
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .bold()
            .font(.system(size: 24))
            .padding()
            .foregroundColor(.white)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Sessions")
        .applyGradientBackground() // Apply the gradient background
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            if let index = workoutProgramsData.workoutPrograms.firstIndex(where: { $0.id == program.id }) {
                                let updatedProgram = workoutProgramsData.workoutPrograms[index]
                                updatedProgram.isStarred.toggle()
                                print(updatedProgram.isStarred, 50)
                            }
                            workoutProgramsData.updateStarredPrograms()
                        } label: {
                            Image(systemName: program.isStarred ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        Button(role: .destructive) {
                            showDeleteConfirmation.toggle()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
        }
        .confirmationDialog("Delete Program", isPresented: $showDeleteConfirmation) {
            Button(role: .destructive) {
                confirmDeletion = true
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                showDeleteConfirmation = false
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete this program?")
        }
        .onChange(of: confirmDeletion) {
            if confirmDeletion {
                workoutProgramsData.deleteProgram(program: program)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#Preview {
    SessionsView(program: WorkoutProgram(title: "test", sessions: [Session(name: "test", exercises: [Exercise(name: "test")]), Session(name: "test 2", exercises: [Exercise(name: "test")])]))
        .environmentObject(WorkoutHistory())
}
