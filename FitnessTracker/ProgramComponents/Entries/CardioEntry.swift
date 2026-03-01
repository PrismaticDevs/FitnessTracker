//
//  CardioEntry.swift
//  FitnessTracker
//
//  Created by Matt on 3/29/25.
//

import SwiftUI
import SwiftData

struct CardioEntryView: View {
    @ObservedObject var theme = ThemeManager.shared
    var defaults = UserDefaults.standard
    @Environment(\.modelContext) var context
    
    let exercise: Exercise // Pass the whole exercise object
    let keyScope: DefaultsKeyScope // To keep your UserDefaults organized
    
    // Use State connected to UserDefaults for persistence during the session
    @State private var duration: String = ""
    @State private var elevation: String = ""
    @State private var heartRate: String = ""
    @State private var note: String = ""
    @State private var caloriesBurned: Double = 0.0
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                // Completion Toggle (Same as Strength)
                Toggle("", isOn: Binding(
                    get: { exercise.isCompleted },
                    set: { exercise.isCompleted = $0 }
                ))
                .labelsHidden()
            }
            
            VStack(spacing: 15) {
                HStack(spacing: 10) {
                    metricField(title: "Min", text: $duration, icon: "timer")
                    metricField(title: "Elev (m)", text: $elevation, icon: "mountain.2")
                    metricField(title: "BPM", text: $heartRate, icon: "heart.fill")
                }
                
                VStack(alignment: .leading) {
                    Text("Notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("How did it feel?", text: $note)
                        .padding(10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .opacity(exercise.isCompleted ? 0.5 : 1.0)
            .disabled(exercise.isCompleted)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
        .onAppear(perform: loadData)
        .onChange(of: duration) { saveToDefaults() }
        .onChange(of: elevation) { saveToDefaults() }
        .onChange(of: heartRate) { saveToDefaults() }
        .onChange(of: note) { saveToDefaults() }
    }
    
    // MARK: - Persistence Helpers

    private func saveToDefaults() {
        let base = exercise.name
        defaults.set(duration, forKey: keyScope.scoped("duration\(base)"))
        defaults.set(elevation, forKey: keyScope.scoped("elev\(base)"))
        defaults.set(heartRate, forKey: keyScope.scoped("hr\(base)"))
        defaults.set(note, forKey: keyScope.scoped("note\(base)"))
        
        // Automatically update calories whenever inputs change
        calculateCaloriesBurned()
    }

    private func loadData() {
        let base = exercise.name
        duration = defaults.string(forKey: keyScope.scoped("duration\(base)")) ?? ""
        elevation = defaults.string(forKey: keyScope.scoped("elev\(base)")) ?? ""
        heartRate = defaults.string(forKey: keyScope.scoped("hr\(base)")) ?? ""
        note = defaults.string(forKey: keyScope.scoped("note\(base)")) ?? ""
        
        calculateCaloriesBurned()
    }

    private func calculateCaloriesBurned() {
        let mins = Double(duration) ?? 0
        let hr = Double(heartRate) ?? 0
        let userWeightKg = 70.0
        let age = 30.0 // You could pull this from UserDefaults too
        
        // Key: We are now using 'hr' in the calculation
        let calories = ((age * 0.2017) + (userWeightKg * 0.1988) + (hr * 0.6309) - 55.0969) * mins / 4.184
        
        self.caloriesBurned = max(0, calories)
    }
    
    // Helper for consistent UI
    private func metricField(title: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(title, systemImage: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .padding(10)
                .background(theme.currentTheme.accent.opacity(0.2))
                .cornerRadius(8)
        }
    }
}

#Preview {
    // 1. Create a mock exercise
    let mockExercise = Exercise(name: "Morning Run", type: .cardio)
    
    // 2. Setup mock key scope (matching your Auth logic)
    let mockScope = DefaultsKeyScope.from(previewUserID: "preview_user", liveUserID: nil)
    
    // 3. Setup a mock SwiftData container for the Environment
    let schema = Schema([CompletedSession.self, CardioEntry.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: config)

    return CardioEntryView(
        exercise: mockExercise,
        keyScope: mockScope
    )
    .modelContainer(container) // Provides the context
    .preferredColorScheme(.dark)
    .background(Color.black)
}
