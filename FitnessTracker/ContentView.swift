//
//  ProgramMenu.swift
//  FitnessTracker
//
//  Created by Matt on 10/26/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var aiManager = AIContextManager()
    @Environment(\.modelContext) var context
    @ObservedObject var theme = ThemeManager.shared
    @EnvironmentObject var authManager: AuthManager
    @State private var globalWorkoutContext: String = "User is browsing the main menu"
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationStack {
                ProgramMenuView()
                    .applyAppBranding()
            }
            .id(theme.currentTheme.id)
            FloatingChatView(workoutContext: globalWorkoutContext)
                .padding(.trailing, 20)
                .padding(.bottom, 100)
        }
        .environment(aiManager)
        .environmentObject(authManager)
        // Migration starts here
        .task(id: authManager.user?.uid) {
            if let uid = authManager.user?.uid {
                DataMigration.runAll(context: context, userId: uid)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UpdateAIContext"))) { note in
            if let newContext = note.object as? String {
                globalWorkoutContext = newContext
            }
        }
    }

    private func migrateAllUserOwnedData(to uid: String) {
        // Migrate each root type
        migrate(WorkoutProgram.self, to: uid)
        migrate(Exercise.self, to: uid)
        migrate(ExerciseCategory.self, to: uid)
        migrate(WorkoutHistory.self, to: uid)
        
        // Save the changes
        try? context.save()
    }

    private func migrate<T>(_ type: T.Type, to uid: String) where T: PersistentModel & UserOwned {
        // Ensure UserOwned exposes a mutable String `userID` property.
        // Fetch all items whose userID is empty and assign the current uid.
        let descriptor = FetchDescriptor<T>(predicate: #Predicate { item in
            item.userId == ""
        })

        do {
            let itemsToMigrate = try context.fetch(descriptor)
            for item in itemsToMigrate {
                item.userId = uid
            }
            print("Migrated \(itemsToMigrate.count) items of type \(type) to user \(uid)")
        } catch {
            print("Migration error for \(type): \(error)")
        }
    }
}

struct ProgramMenuView: View {
    @Query(
        sort: \WorkoutProgram.title,
        order: .forward,
        animation: .default
        ) private var programs: [WorkoutProgram]
    @EnvironmentObject var auth: AuthManager
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.modelContext) var context
    @State private var showSocialPortal = false
    @State private var showSignoutAlert = false
    @State private var navigateToSettings = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HeaderView()
                Text("Select a Program")
                    .font(.system(size: 24, weight: .bold))
                    .padding(0)
                    .foregroundColor(.white)
                if let uid = auth.user?.uid {
                    ProgramListView(userId: uid)
                } else {
                    ProgressView("Loading your programs...")
                        .tint(.white)
                }
                customBottomBar
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .id(theme.currentTheme.id)
        .overlay {
            if programs.isEmpty {
                EmptyStateView()
            }
        }
        .toolbarBackground(.hidden, for: .bottomBar)
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
    }
    
    private var customBottomBar: some View {
            HStack {
                Spacer()
                NavigationLink(destination: SocialEntry()) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .foregroundColor(.white)
                        .notificationBadge(show: auth.profile?.preferences.hasSocialUpdate ?? false)
                }
                Spacer()
                NavigationLink(destination: AddWorkoutProgramView()) {
                    AddProgramButton(compact: true)
                        .foregroundColor(.white) // Ensure the "+" is white on the accent
                }
                Spacer()
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.white)
                        .notificationBadge(show: auth.profile?.preferences.hasSettingsUpdate ?? false)
                }
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 50)
            .background(theme.currentTheme.accent)
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
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
    }
}

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
    @ObservedObject var theme = ThemeManager.shared
    @State private var isHovering = false
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 0 : 6) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(Color.white)
            if !compact {
                Text("Add Program")
                    .font(.headline)
            }
        }
        .padding(compact ? 0 : 8)
        .foregroundColor(theme.currentTheme.accent)
        .animation(.easeInOut(duration: 0.12), value: isHovering)
        .cornerRadius(8)
        .contentShape(Rectangle()) // helps hit-testing
        .accessibilityLabel("Add Program")
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}

