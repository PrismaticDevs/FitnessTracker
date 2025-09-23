//
//  ProgramMenu.swift
//  FitnessTracker
//
//  Created by Matt on 10/26/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var context
    @Query(sort: \WorkoutProgram.title) var programs: [WorkoutProgram] = []
    
    var body: some View {
        NavigationStack {
            ProgramMenuView(programs: programs, context: _context)
        }
        .accentColor(Color.white)
    }
}

struct ProgramMenuView: View {
    var programs: [WorkoutProgram]
    @Environment(\.modelContext) var context
    
    var body: some View {
        ZStack {
            VStack {
                HeaderView()
                Text("Select a Program")
                    .font(.system(size: 24, weight: .bold))
                    .padding(0)
                    .foregroundColor(Color.white)
                ProgramListView(programs: programs, context: _context)
            }
        }
        .navigationTitle("Your Programs")
        .navigationBarTitleTextColor(ColorPalette.primary)
        .applyGradientBackground()
        .overlay {
            if programs.isEmpty {
                EmptyStateView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    PrebuiltProgramsView()
                } label: {
                    HStack {
                        Text("Prebuilt Programs")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                            .bold()
                    }
                }
            }
            if !programs.isEmpty {
                ToolbarItem {
                    NavigationLink(destination: AddWorkoutProgramView()) {
                        AddProgramButton()
                    }
                }
            }
        }
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            Text("FitnessTracker")
                .font(.title)
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 36))
            Text("1.0")
                .font(.system(size: 18))
        }
        .padding(5)
        .padding(.top, 10)
    }
}

struct ProgramListView: View {
    var programs: [WorkoutProgram]
    @Environment(\.modelContext) var context
    @State private var showAlert = false
    @State private var programToDeleteIndex: Int? = nil

    var body: some View {
        Button("programs") {
            print(programs)
        }
        List {
            ForEach(programs.sorted { $0.starred && !$1.starred }) { program in
                ProgramRowView(program: program)
                    .swipeActions {
                        Button(role: .destructive) {
                            // Find the index of the program to delete
                            if let index = programs.firstIndex(where: { $0.id == program.id }) {
                                programToDeleteIndex = index
                                showAlert = true
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .scrollContentBackground(.hidden)
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete Program"),
                message: Text("Are you sure you want to delete \(programs[programToDeleteIndex ?? 0].title)?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let index = programToDeleteIndex {
                        deleteProgram(at: index)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func deleteProgram(at index: Int) {
        let programToDelete = programs[index]
        context.delete(programToDelete)
        do {
            try context.save()
        } catch {
            print("Error deleting program: \(error)")
        }
    }
}

struct ProgramRowView: View {
    @Environment(\.modelContext) var context
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
        .listRowBackground(Color.blue) // Apply blue background to the entire row
        .padding()
    }
}

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

struct AddProgramButton: View {
    var body: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
            Text("Add Program")
                .font(.headline)
        }
        .padding()
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
}
