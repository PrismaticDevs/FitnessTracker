//
//  ProgramListView.swift
//  FitnessTracker
//
//  Created by Matt on 2/22/26.
//

import SwiftUI
import SwiftData

struct ProgramListView: View {
    @ObservedObject var theme = ThemeManager.shared
    @Query private var programs: [WorkoutProgram]
    @Environment(\.modelContext) private var context
    @State private var showDeleteConfirmation = false
    @State private var programToDelete: WorkoutProgram?
    
    init(userId: String) {
            // This predicate tells SwiftData: "Only fetch programs where userId matches the logged-in user"
            let filter = #Predicate<WorkoutProgram> { program in
                program.userId == userId
            }
            _programs = Query(filter: filter, sort: \.title)
        }

    var body: some View {
        List {
            ForEach(programs.sorted { $0.starred && !$1.starred }) { program in
                ProgramRowView(program: program)
                    .swipeActions {
                        Button(role: .destructive) {
                            programToDelete = program
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .padding(.horizontal, 12)
        .alert("Delete Program",
               isPresented: $showDeleteConfirmation,
               presenting: programToDelete) { program in
            Button("Delete", role: .destructive) {
                deleteProgram(program)
            }
            Button("Cancel", role: .cancel) {}
        } message: { program in
            Text("Are you sure you want to delete \(program.title)?")
        }
    }
    
    private func deleteProgram(_ program: WorkoutProgram) {
        withAnimation {
            context.delete(program)
            do {
                try context.save()
                print("Program Successfully Deleted")
            } catch {
                print("Error deleting program: \(error)")
            }
        }
    }
}
