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
    @EnvironmentObject var authManager: AuthManager
    @Query(sort: \WorkoutProgram.title) var programs: [WorkoutProgram] = []
    
    var body: some View {
        NavigationStack {
            ProgramMenuView(programs: programs, context: _context, auth: authManager)
        }
    }
}

struct ProgramMenuView: View {
    var programs: [WorkoutProgram]
    @Environment(\.modelContext) var context
    @StateObject var auth: AuthManager
    @State private var showSocialPortal = false
    @State private var showSignoutAlert = false
    
    var body: some View {
        ZStack {
            VStack {
                HeaderView()
                Text("Select a Program")
                    .font(.system(size: 24, weight: .bold))
                    .padding(0)
                    .foregroundColor(ColorPalette.primary)
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
            // Trailing: Add Program
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: AddWorkoutProgramView()) {
                    AddProgramButton(compact: true)
                        .help("Create workout program")
                }
            }

            // Trailing: Logout
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showSignoutAlert = true
                } label: {
                    Image(systemName: "arrow.right.square")
                        .font(.system(size: 18, weight: .semibold))
                        .accessibilityLabel("Log out")
                        .foregroundColor(Color.red)
                }
                .help("Lof out of FiT")
            }
            // Bottom bar (or move to leading if you prefer): Social entry
            ToolbarItem(placement: .bottomBar) {
                NavigationLink(destination: SocialEntry()) {
                    SocialEntry()
                }
            }
        }
        .alert(isPresented: $showSignoutAlert) {
            Alert(
                title: Text("Log Out Confirmation"),
                message: Text("Are you sure you want to log out of FiT?"),
                primaryButton: .destructive(Text("Log Out")) {
                    auth.signOut()
                },
                secondaryButton: .cancel()
            )
        }
        #if canImport(UIKit)
        .toolbarColorScheme(.dark, for: .navigationBar)      // or .light depending on your background
        .toolbarBackground(.visible, for: .navigationBar)
        #endif
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            Text("FitnessTracker")
                .font(.title)
            Text("1.0")
                .font(.system(size: 18))
            Image("white-outline")
                .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(8)
                    .padding(0)
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
        .listRowBackground(ColorPalette.accent) // Apply blue background to the entire row
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
    @State private var isHovering = false
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 0 : 6) {
            Image(systemName: "plus.circle.fill")
            if !compact {
                Text("Add Program")
                    .font(.headline)
                    .foregroundColor(ColorPalette.accent)
            }
        }
        .padding(compact ? 0 : 8)
        .foregroundColor(ColorPalette.primary)
        .animation(.easeInOut(duration: 0.12), value: isHovering)
        .cornerRadius(8)
        .contentShape(Rectangle()) // helps hit-testing
        .accessibilityLabel("Add Program")
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

struct SocialEntry: View {
    var body: some View {
        HStack {
            Image(systemName: "bubble.left.and.bubble.right")
                .foregroundColor(ColorPalette.accent)
            Text("FiT Social")
                .font(.headline)
                .foregroundColor(ColorPalette.accent)
        }
        .padding()
        .foregroundColor(ColorPalette.primary)
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
