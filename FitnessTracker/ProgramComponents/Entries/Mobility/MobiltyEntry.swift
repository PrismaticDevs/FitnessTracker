//
//  MobiltyEntryView.swift
//  FitnessTracker
//
//  Created by Matt on 12/31/25.
//

import SwiftUI
import SwiftData

struct MobilityEntryView: View {
    var defaults = UserDefaults.standard
    @Environment(\.modelContext) var context
    @Environment(AIContextManager.self) private var aiManager
    @EnvironmentObject var auth: AuthManager
    
    @Binding var isCompleted: Bool
    @State var exercise: Exercise // Assuming you use your Exercise model
    
    // Scoped keys helper
    private var keyScope: DefaultsKeyScope {
        DefaultsKeyScope.from(previewUserID: auth.previewUserID, liveUserID: auth.user?.uid)
    }
    
    // Local State for UI
    @State private var holdTimeInput: String = "30"
    @State private var roundsInput: String = "1"
    @State private var note: String = ""
    @State private var showHistory: Bool = false
    
    @FocusState private var isFocused: Bool?

    var body: some View {
        VStack(spacing: 16) {
            // Header Section
            HStack {
                Text(exercise.name)
                    .font(.headline)
                Spacer()
                Button(action: { isCompleted.toggle() }) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .green : .secondary)
                        .font(.title2)
                }
            }
            
            if !isCompleted {
                HStack(spacing: 20) {
                    // Hold Time Input
                    VStack(alignment: .leading) {
                        Text("Hold (sec)").font(.caption2).foregroundColor(.secondary)
                        TextField("Sec", text: $holdTimeInput)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .focused($isFocused, equals: true)
                    }
                    
                    // Rounds Input
                    VStack(alignment: .leading) {
                        Text("Rounds").font(.caption2).foregroundColor(.secondary)
                        TextField("Rounds", text: $roundsInput)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .focused($isFocused, equals: true)
                    }
                }
                
                // Note Input
                TextField("Add a note...", text: $note)
                    .font(.caption)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }

            // History Toggle (Using .plain button style as requested)
            Button {
                withAnimation { showHistory.toggle() }
            } label: {
                HStack {
                    Text(showHistory ? "Hide History" : "View History")
                    Image(systemName: showHistory ? "eye.slash" : "eye")
                }
                .font(.caption.bold())
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)

            if showHistory {
                MobilityHistorySection(exerciseName: exercise.name)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .onAppear(perform: loadFromDefaults)
        .onChange(of: holdTimeInput) { saveToDefaults() }
        .onChange(of: roundsInput) { saveToDefaults() }
        .onChange(of: note) { saveToDefaults() }
    }

    // MARK: - Persistence Logic
    
    private func loadFromDefaults() {
        let hold = defaults.integer(forKey: keyScope.scoped("holdTime\(exercise.name)"))
        let rounds = defaults.integer(forKey: keyScope.scoped("rounds\(exercise.name)"))
        let savedNote = defaults.string(forKey: keyScope.scoped("note\(exercise.name)")) ?? ""
        
        if hold > 0 { holdTimeInput = "\(hold)" }
        if rounds > 0 { roundsInput = "\(rounds)" }
        self.note = savedNote
        
        updateAIContext()
    }

    private func saveToDefaults() {
        defaults.set(Int(holdTimeInput) ?? 0, forKey: keyScope.scoped("holdTime\(exercise.name)"))
        defaults.set(Int(roundsInput) ?? 0, forKey: keyScope.scoped("rounds\(exercise.name)"))
        defaults.set(note, forKey: keyScope.scoped("note\(exercise.name)"))
        updateAIContext()
    }

    private func updateAIContext() {
        aiManager.updateContext(
            screen: "Mobility Entry",
            details: "Stretching: \(exercise.name)",
            preferences: "Hold: \(holdTimeInput)s, Rounds: \(roundsInput), Note: \(note)"
        )
    }
}

#Preview {
    // 1. Setup Mock Data
    let mockExercise = Exercise(name: "Couch Stretch")
    let mockAuth = AuthManager()
    
    // 2. Create an in-memory container for SwiftData so the preview doesn't crash
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MobilityEntry.self, configurations: config)
    
    // 3. (Optional) Add dummy history to see how the toggle looks
    let sampleEntry = MobilityEntry(
        exercise: "Couch Stretch",
        holdTime: 60,
        rounds: 2,
        note: "Felt tight in the left hip."
    )
    container.mainContext.insert(sampleEntry)

    return MobilityEntryView(
        isCompleted: .constant(false),
        exercise: mockExercise
    )
    .padding()
    .background(Color.black) // Helps see the white-opacity background components
    .environmentObject(mockAuth)
    .environment(AIContextManager())
    .modelContainer(container)
}
