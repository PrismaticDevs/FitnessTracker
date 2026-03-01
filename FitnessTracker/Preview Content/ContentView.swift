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
            guard let uid = authManager.user?.uid else { return }
            
            // 1. Run local migrations
            DataMigration.runAll(context: context, userId: uid)
            
            // 2. Fetch cloud data
            // Create the keyScope for UserDefaults
            let keyScope = DefaultsKeyScope.from(previewUserID: nil, liveUserID: uid)
            
            // Pull Blueprints (UserDefaults) and History (SwiftData)
            SyncManager.shared.fetchHistoryFromCloud(userId: uid, context: context)
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

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}

