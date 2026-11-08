//
//  FitnessTrackerTests.swift
//  FitnessTrackerTests
//

import Testing
import Foundation
import SwiftData
@testable import FitnessTracker

// MARK: - DefaultsKeyScope

@Suite("DefaultsKeyScope")
struct DefaultsKeyScopeTests {

    @Test("scoped key with no program or session")
    func scopedBasic() {
        let scope = DefaultsKeyScope(userID: "abc", programID: nil, sessionID: nil)
        #expect(scope.scoped("weight") == "user_abc.weight")
    }

    @Test("scoped key includes program and session when both set")
    func scopedWithProgramAndSession() {
        let scope = DefaultsKeyScope(userID: "abc", programID: "p1", sessionID: "s1")
        #expect(scope.scoped("reps") == "user_abc.p1.s1.reps")
    }

    @Test("scoped falls back to basic when only programID set")
    func scopedProgramOnlyFallsBack() {
        // sessionID nil → both nil branch → basic scoping
        let scope = DefaultsKeyScope(userID: "abc", programID: "p1", sessionID: nil)
        #expect(scope.scoped("weight") == "user_abc.weight")
    }

    @Test("legacyScoped always ignores program and session")
    func legacyScoped() {
        let scope = DefaultsKeyScope(userID: "abc", programID: "p1", sessionID: "s1")
        #expect(scope.legacyScoped("note") == "user_abc.note")
    }

    @Test("from() prefers previewUserID over liveUserID")
    func fromPrefersPreview() {
        let scope = DefaultsKeyScope.from(previewUserID: "preview", liveUserID: "live")
        #expect(scope.userID == "preview")
    }

    @Test("from() falls back to liveUserID when no preview")
    func fromFallsToLive() {
        let scope = DefaultsKeyScope.from(previewUserID: nil, liveUserID: "live")
        #expect(scope.userID == "live")
    }

    @Test("from() uses 'guest' when both nil")
    func fromFallsToGuest() {
        let scope = DefaultsKeyScope.from(previewUserID: nil, liveUserID: nil)
        #expect(scope.userID == "guest")
    }

    @Test("from() propagates programID and sessionID")
    func fromPropagatesIDs() {
        let scope = DefaultsKeyScope.from(previewUserID: nil, liveUserID: "u", programID: "p", sessionID: "s")
        #expect(scope.scoped("x") == "user_u.p.s.x")
    }

    @Test("exerciseScoped without set index")
    func exerciseScopedNoIndex() {
        let scope = DefaultsKeyScope(userID: "u", programID: nil, sessionID: nil)
        let uuid = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let key = scope.exerciseScoped(base: "weight", exerciseId: uuid)
        #expect(key == "user_u.weightAAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")
    }

    @Test("exerciseScoped appends set index")
    func exerciseScopedWithIndex() {
        let scope = DefaultsKeyScope(userID: "u", programID: nil, sessionID: nil)
        let uuid = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let key = scope.exerciseScoped(base: "reps", exerciseId: uuid, setIndex: 3)
        #expect(key == "user_u.repsAAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE_set3")
    }

    // Regression test: StrengthEntryView used to build a user-only scope while
    // finishWorkoutSession() read with the full program+session scope, so
    // setsCount was always 0 and nothing was saved. Both sides must use the
    // same full scope for the round-trip to work.
    @Test("write key matches read key when both use full scope")
    func saveReadKeySymmetry() {
        let uid = "user1"
        let programID = "prog1"
        let sessionID = "sess1"
        let exerciseName = "Bench Press"

        let writeScope = DefaultsKeyScope.from(
            previewUserID: nil,
            liveUserID: uid,
            programID: programID,
            sessionID: sessionID
        )
        let readScope = DefaultsKeyScope.from(
            previewUserID: nil,
            liveUserID: uid,
            programID: programID,
            sessionID: sessionID
        )

        let writeKey = writeScope.scoped("setsCount\(exerciseName)")
        let readKey  = readScope.scoped("setsCount\(exerciseName)")
        #expect(writeKey == readKey)
        #expect(writeKey == "user_user1.prog1.sess1.setsCountBench Press")

        // Demonstrate what the old short scope produced — a different key
        let oldShortScope = DefaultsKeyScope.from(previewUserID: nil, liveUserID: uid)
        let oldWriteKey = oldShortScope.scoped("setsCount\(exerciseName)")
        #expect(oldWriteKey != readKey, "Short scope must NOT match full scope — this was the bug")
    }
}

// MARK: - ExerciseType Enum

@Suite("ExerciseType")
struct ExerciseTypeTests {

    @Test("raw values match expected strings")
    func rawValues() {
        #expect(ExerciseType.cardio.rawValue == "cardio")
        #expect(ExerciseType.strength.rawValue == "strength")
        #expect(ExerciseType.mobility.rawValue == "mobility")
    }

    @Test("round-trips through Codable")
    func codableRoundTrip() throws {
        for type_ in [ExerciseType.cardio, .strength, .mobility] {
            let data = try JSONEncoder().encode(type_)
            let decoded = try JSONDecoder().decode(ExerciseType.self, from: data)
            #expect(decoded == type_)
        }
    }

    @Test("initialises from raw value string")
    func fromRawValue() {
        #expect(ExerciseType(rawValue: "cardio") == .cardio)
        #expect(ExerciseType(rawValue: "strength") == .strength)
        #expect(ExerciseType(rawValue: "mobility") == .mobility)
        #expect(ExerciseType(rawValue: "unknown") == nil)
    }
}

// MARK: - SetRecord Model

@Suite("SetRecord")
struct SetRecordTests {

    @Test("defaults every field to zero")
    func defaultInit() {
        let s = SetRecord()
        #expect(s.combined == 0)
        #expect(s.left == 0)
        #expect(s.right == 0)
        #expect(s.reps == 0)
        #expect(s.rest == 0)
    }

    @Test("stores supplied values")
    func customInit() {
        let s = SetRecord(combined: 120, left: 60, right: 60, reps: 10, rest: 90)
        #expect(s.combined == 120)
        #expect(s.left == 60)
        #expect(s.right == 60)
        #expect(s.reps == 10)
        #expect(s.rest == 90)
    }

    @Test("each instance gets a unique ID")
    func uniqueIDs() {
        let s1 = SetRecord()
        let s2 = SetRecord()
        #expect(s1.id != s2.id)
    }

    @Test("custom UUID is preserved")
    func customUUID() {
        let uuid = UUID()
        let s = SetRecord(id: uuid, combined: 50)
        #expect(s.id == uuid)
    }
}

// MARK: - StrengthEntry Model

@Suite("StrengthEntry")
struct StrengthEntryTests {

    @Test("stores exercise name, date, and sets")
    func basicInit() {
        let date = Date()
        let sets = [SetRecord(combined: 100, reps: 8, rest: 60)]
        let entry = StrengthEntry(exercise: "Squat", date: date, sets: sets)
        #expect(entry.exercise == "Squat")
        #expect(entry.date == date)
        #expect(entry.sets.count == 1)
        #expect(entry.note == nil)
        #expect(entry.iso == false)
    }

    @Test("stores optional note")
    func withNote() {
        let entry = StrengthEntry(exercise: "Deadlift", date: Date(), sets: [], note: "PR attempt")
        #expect(entry.note == "PR attempt")
    }

    @Test("iso flag stored correctly")
    func isoFlag() {
        let entry = StrengthEntry(exercise: "Single-Leg Press", date: Date(), sets: [], iso: true)
        #expect(entry.iso == true)
    }

    @Test("entries get unique IDs")
    func uniqueIDs() {
        let e1 = StrengthEntry(exercise: "A", date: Date(), sets: [])
        let e2 = StrengthEntry(exercise: "B", date: Date(), sets: [])
        #expect(e1.id != e2.id)
    }
}

// MARK: - CardioEntry Model

@Suite("CardioEntry")
struct CardioEntryTests {

    @Test("optional fields default to nil")
    func defaultOptionals() {
        let entry = CardioEntry(exercise: "Running", duration: 1800)
        #expect(entry.distance == nil)
        #expect(entry.calories == nil)
        #expect(entry.note == nil)
        #expect(entry.session == nil)
    }

    @Test("stores all supplied fields")
    func fullInit() {
        let entry = CardioEntry(exercise: "Cycling", duration: 3600, distance: 20.5, calories: 450, note: "Easy ride")
        #expect(entry.exercise == "Cycling")
        #expect(entry.duration == 3600)
        #expect(entry.distance == 20.5)
        #expect(entry.calories == 450)
        #expect(entry.note == "Easy ride")
    }
}

// MARK: - MobilityEntry Model

@Suite("MobilityEntry")
struct MobilityEntryTests {

    @Test("defaults to zero hold time and rounds")
    func defaults() {
        let entry = MobilityEntry(exercise: "Hip Flexor Stretch")
        #expect(entry.holdTime == 0)
        #expect(entry.rounds == 0)
        #expect(entry.note == nil)
    }

    @Test("stores supplied values")
    func customInit() {
        let entry = MobilityEntry(exercise: "Pigeon Pose", holdTime: 60, rounds: 3, note: "Both sides")
        #expect(entry.holdTime == 60)
        #expect(entry.rounds == 3)
        #expect(entry.note == "Both sides")
    }
}

// MARK: - CompletedSession Model

@Suite("CompletedSession")
struct CompletedSessionTests {

    @Test("initialises with empty entry arrays")
    func emptyEntries() {
        let session = CompletedSession(programTitle: "PPL", sessionName: "Push Day")
        #expect(session.strengthEntries.isEmpty)
        #expect(session.cardioEntries.isEmpty)
        #expect(session.mobilityEntries.isEmpty)
    }

    @Test("stores program and session title")
    func titleStorage() {
        let session = CompletedSession(programTitle: "Big & Strong", sessionName: "Leg Day")
        #expect(session.programTitle == "Big & Strong")
        #expect(session.sessionName == "Leg Day")
    }

    @Test("note defaults to empty string")
    func defaultNote() {
        let session = CompletedSession(programTitle: "X", sessionName: "Y")
        #expect(session.note == "")
    }

    @Test("custom note stored")
    func customNote() {
        let session = CompletedSession(programTitle: "X", sessionName: "Y", note: "Felt great")
        #expect(session.note == "Felt great")
    }

    @Test("userId defaults to empty string")
    func defaultUserId() {
        let session = CompletedSession(programTitle: "X", sessionName: "Y")
        #expect(session.userId == "")
    }
}

// MARK: - WorkoutProgram & Session Models

@Suite("WorkoutProgram and Session")
struct WorkoutProgramTests {

    @Test("WorkoutProgram stores title and sessions")
    func programBasicInit() {
        let program = WorkoutProgram(userId: "u1", title: "My Program", sessions: [])
        #expect(program.title == "My Program")
        #expect(program.userId == "u1")
        #expect(program.sessions.isEmpty)
        #expect(program.starred == false)
    }

    @Test("WorkoutProgram each instance has unique ID")
    func uniqueIDs() {
        let p1 = WorkoutProgram(title: "A", sessions: [])
        let p2 = WorkoutProgram(title: "B", sessions: [])
        #expect(p1.id != p2.id)
    }

    @Test("Session stores name and exercises")
    func sessionInit() {
        let exercises = [Exercise(name: "Squat"), Exercise(name: "Lunge")]
        let session = Session(name: "Leg Day", exercises: exercises)
        #expect(session.name == "Leg Day")
        #expect(session.exercises.count == 2)
    }
}

// MARK: - Exercise Model

@Suite("Exercise")
struct ExerciseTests {

    @Test("defaults to strength type")
    func defaultType() {
        let ex = Exercise(name: "Bench Press")
        #expect(ex.type == .strength)
        #expect(ex.isCompleted == false)
    }

    @Test("stores specified type")
    func customType() {
        let ex = Exercise(name: "Bike Sprint", type: .cardio)
        #expect(ex.type == .cardio)
    }

    @Test("unique IDs per instance")
    func uniqueIDs() {
        let e1 = Exercise(name: "X")
        let e2 = Exercise(name: "X")
        #expect(e1.id != e2.id)
    }
}

// MARK: - ExerciseCategory Model

@Suite("ExerciseCategory")
struct ExerciseCategoryTests {

    @Test("initialises with empty exercises list")
    func defaultExercises() {
        let cat = ExerciseCategory(userId: "u1", name: "Chest")
        #expect(cat.name == "Chest")
        #expect(cat.exercises.isEmpty)
    }

    @Test("stores supplied exercises")
    func withExercises() {
        let exercises = [Exercise(name: "Bench Press"), Exercise(name: "Fly")]
        let cat = ExerciseCategory(name: "Chest", exercises: exercises)
        #expect(cat.exercises.count == 2)
    }
}

// MARK: - UserProfile Codable

@Suite("UserProfile Codable")
struct UserProfileTests {

    @Test("decodes full profile from JSON")
    func fullDecode() throws {
        let json = """
        {
            "display_name": "Matt",
            "biometrics": {
                "age": 30,
                "gender": "Male",
                "height": 180,
                "weight": 80
            },
            "preferences": {
                "home_gym": "My Gym",
                "theme": "Dark",
                "units": "kg"
            }
        }
        """.data(using: .utf8)!

        let profile = try JSONDecoder().decode(UserProfile.self, from: json)
        #expect(profile.display_name == "Matt")
        #expect(profile.biometrics.age == 30)
        #expect(profile.biometrics.gender == "Male")
        #expect(profile.biometrics.height == 180)
        #expect(profile.biometrics.weight == 80)
        #expect(profile.preferences.units == "kg")
        #expect(profile.preferences.theme == "Dark")
        #expect(profile.preferences.home_gym == "My Gym")
    }

    @Test("biometrics optional fields handle missing keys")
    func partialBiometrics() throws {
        let json = """
        {
            "display_name": "Guest",
            "biometrics": {},
            "preferences": { "home_gym": "Home", "theme": "Light", "units": "lbs" }
        }
        """.data(using: .utf8)!

        let profile = try JSONDecoder().decode(UserProfile.self, from: json)
        #expect(profile.biometrics.age == nil)
        #expect(profile.biometrics.gender == nil)
        #expect(profile.biometrics.height == nil)
        #expect(profile.biometrics.weight == nil)
    }

    @Test("notification flag fields decode correctly")
    func notificationFlags() throws {
        let json = """
        {
            "display_name": "Matt",
            "biometrics": {},
            "preferences": {
                "home_gym": "Home",
                "theme": "Dark",
                "units": "kg",
                "hasSettingsUpdate": true,
                "hasSocialUpdate": false
            }
        }
        """.data(using: .utf8)!

        let profile = try JSONDecoder().decode(UserProfile.self, from: json)
        #expect(profile.preferences.hasSettingsUpdate == true)
        #expect(profile.preferences.hasSocialUpdate == false)
    }

    @Test("notification flags default to nil when absent")
    func notificationFlagsAbsent() throws {
        let json = """
        {
            "display_name": "Matt",
            "biometrics": {},
            "preferences": { "home_gym": "Home", "theme": "Dark", "units": "kg" }
        }
        """.data(using: .utf8)!

        let profile = try JSONDecoder().decode(UserProfile.self, from: json)
        #expect(profile.preferences.hasSettingsUpdate == nil)
        #expect(profile.preferences.hasSocialUpdate == nil)
    }

    @Test("round-trips through encode then decode")
    func roundTrip() throws {
        let json = """
        {
            "display_name": "Test User",
            "biometrics": { "age": 25, "gender": "Female", "height": 165, "weight": 60 },
            "preferences": { "home_gym": "YMCA", "theme": "Light", "units": "lbs" }
        }
        """.data(using: .utf8)!

        let original = try JSONDecoder().decode(UserProfile.self, from: json)
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: encoded)

        #expect(decoded.display_name == original.display_name)
        #expect(decoded.biometrics.age == original.biometrics.age)
        #expect(decoded.preferences.units == original.preferences.units)
    }
}

// MARK: - Prebuilt Programs

@Suite("Prebuilt Programs")
struct PrebuiltProgramsTests {

    @Test("creates exactly 3 programs")
    func programCount() {
        #expect(createPrebuiltWorkoutPrograms().count == 3)
    }

    @Test("every program has at least one session")
    func programsHaveSessions() {
        for program in createPrebuiltWorkoutPrograms() {
            #expect(!program.sessions.isEmpty, "'\(program.title)' has no sessions")
        }
    }

    @Test("every session has at least one exercise")
    func sessionsHaveExercises() {
        for program in createPrebuiltWorkoutPrograms() {
            for session in program.sessions {
                #expect(!session.exercises.isEmpty, "'\(session.name)' has no exercises")
            }
        }
    }

    @Test("program titles are unique")
    func uniqueTitles() {
        let programs = createPrebuiltWorkoutPrograms()
        let titles = programs.map(\.title)
        #expect(titles.count == Set(titles).count)
    }

    @Test("'Big and Strong Advanced' has 5 sessions")
    func bigAndStrongSessionCount() {
        let programs = createPrebuiltWorkoutPrograms()
        let found = programs.first { $0.title == "Big and Strong Advanced" }
        #expect(found != nil)
        #expect(found?.sessions.count == 5)
    }

    @Test("'4 Day Maximum Mass Workout' has 4 sessions")
    func fourDaySessionCount() {
        let programs = createPrebuiltWorkoutPrograms()
        let found = programs.first { $0.title == "4 Day Maximum Mass Workout" }
        #expect(found != nil)
        #expect(found?.sessions.count == 4)
    }

    @Test("deep copy clones sessions and exercises independently")
    func deepCopyIndependence() {
        let programs = createPrebuiltWorkoutPrograms()
        let first = programs[0]
        let firstExercise = first.sessions[0].exercises[0]

        // Mutate the name on the template — a deep copy should not reflect this
        firstExercise.name = "MUTATED"

        // The other prebuilt program instances were created fresh, so their
        // exercises should still have their original names (not "MUTATED")
        let fresh = createPrebuiltWorkoutPrograms()[0].sessions[0].exercises[0]
        #expect(fresh.name != "MUTATED")
    }
}

// MARK: - AIContextManager

@Suite("AIContextManager")
struct AIContextManagerTests {

    @Test("default context describes main menu")
    func defaultContext() {
        let manager = AIContextManager()
        #expect(manager.currentContext == "User is browsing the main menu.")
    }

    @Test("updateContext formats screen and details")
    func updateContextFormat() {
        let manager = AIContextManager()
        manager.updateContext(screen: "SessionDetail", details: "Push Day - 3 exercises", preferences: "")
        #expect(manager.currentContext == "Location: SessionDetail. Context: Push Day - 3 exercises")
    }

    @Test("updateContext stores non-empty preferences")
    func updatesPreferences() {
        let manager = AIContextManager()
        manager.updateContext(screen: "X", details: "Y", preferences: "Units: kg")
        #expect(manager.userPreferences == "Units: kg")
    }

    @Test("updateContext does not overwrite preferences with empty string")
    func preservesPreferences() {
        let manager = AIContextManager()
        manager.updateContext(screen: "A", details: "a", preferences: "pref1")
        manager.updateContext(screen: "B", details: "b", preferences: "")
        #expect(manager.userPreferences == "pref1")
    }

    @Test("subsequent context calls replace currentContext")
    func contextReplaced() {
        let manager = AIContextManager()
        manager.updateContext(screen: "Screen1", details: "detail1", preferences: "")
        manager.updateContext(screen: "Screen2", details: "detail2", preferences: "")
        #expect(manager.currentContext.contains("Screen2"))
        #expect(!manager.currentContext.contains("Screen1"))
    }
}

// MARK: - ChatViewModel (message grouping — no network)

@Suite("ChatViewModel message grouping", .serialized)
@MainActor
struct ChatViewModelTests {

    @Test("selectedDate defaults to start of today")
    func defaultSelectedDate() {
        let vm = ChatViewModel()
        let today = Calendar.current.startOfDay(for: Date())
        #expect(vm.selectedDate == today)
    }

    @Test("isLoading defaults to false")
    func defaultIsLoading() {
        #expect(ChatViewModel().isLoading == false)
    }

    @Test("currentDisplayMessages returns empty when no messages for selected date")
    func emptyForUnknownDate() {
        let vm = ChatViewModel()
        vm.selectedDate = Calendar.current.startOfDay(for: Date.distantPast)
        #expect(vm.currentDisplayMessages.isEmpty)
    }

    @Test("currentDisplayMessages returns messages for selected date")
    func messagesForDate() {
        let vm = ChatViewModel()
        let today = Calendar.current.startOfDay(for: Date())
        vm.groupedMessages[today] = [
            (text: "Hello", isUser: true),
            (text: "Hi there!", isUser: false)
        ]
        #expect(vm.currentDisplayMessages.count == 2)
        #expect(vm.currentDisplayMessages[0].text == "Hello")
        #expect(vm.currentDisplayMessages[0].isUser == true)
        #expect(vm.currentDisplayMessages[1].isUser == false)
    }

    @Test("availableDates orders newest first")
    func datesNewestFirst() {
        let vm = ChatViewModel()
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.startOfDay(for: Date().addingTimeInterval(-86400))
        let twoDaysAgo = Calendar.current.startOfDay(for: Date().addingTimeInterval(-172800))

        vm.groupedMessages[twoDaysAgo] = [(text: "Old", isUser: true)]
        vm.groupedMessages[yesterday] = [(text: "Less old", isUser: true)]
        vm.groupedMessages[today] = [(text: "New", isUser: true)]

        let dates = vm.availableDates
        #expect(dates.count == 3)
        #expect(dates[0] == today)
        #expect(dates[1] == yesterday)
        #expect(dates[2] == twoDaysAgo)
    }

    @Test("multiple messages accumulate in the same day bucket")
    func multipleMessagesPerDay() {
        let vm = ChatViewModel()
        let today = Calendar.current.startOfDay(for: Date())
        vm.groupedMessages[today] = [
            (text: "Q1", isUser: true),
            (text: "A1", isUser: false),
            (text: "Q2", isUser: true),
            (text: "A2", isUser: false)
        ]
        #expect(vm.currentDisplayMessages.count == 4)
    }

    @Test("switching selectedDate shows correct messages")
    func dateSwitch() {
        let vm = ChatViewModel()
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.startOfDay(for: Date().addingTimeInterval(-86400))

        vm.groupedMessages[today] = [(text: "Today msg", isUser: true)]
        vm.groupedMessages[yesterday] = [(text: "Yesterday msg", isUser: false)]

        vm.selectedDate = yesterday
        #expect(vm.currentDisplayMessages[0].text == "Yesterday msg")

        vm.selectedDate = today
        #expect(vm.currentDisplayMessages[0].text == "Today msg")
    }
}
