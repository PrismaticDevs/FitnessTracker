//
//  SocialTests.swift
//  FitnessTrackerTests
//
//  Unit tests for FiT Social models (no network / Firestore calls).
//

import Testing
import Foundation
import SwiftData
import FirebaseFirestore
@testable import FitnessTracker

// MARK: - Helpers

@MainActor
private func makeContext() throws -> ModelContext {
    let schema = Schema([CompletedSession.self, StrengthEntry.self, SetRecord.self, CardioEntry.self, MobilityEntry.self])
    let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(isStoredInMemoryOnly: true)])
    return ModelContext(container)
}

private func makeProfile(username: String = "mattb", displayName: String) -> PublicProfile {
    PublicProfile(username: username, displayName: displayName, bio: "", homeGym: "")
}

// MARK: - UsernameRules

@Suite("UsernameRules")
struct UsernameRulesTests {

    @Test("normalize lowercases and strips disallowed characters")
    func normalizeStrips() {
        #expect(UsernameRules.normalize("Matt.B!") == "matt.b")
        #expect(UsernameRules.normalize("Gym Rat 99") == "gymrat99")
        #expect(UsernameRules.normalize("lift_heavy") == "lift_heavy")
        #expect(UsernameRules.normalize("émile") == "mile")
    }

    @Test("normalize of only symbols is empty")
    func normalizeAllSymbols() {
        #expect(UsernameRules.normalize("!@# $%") == "")
    }

    @Test("valid usernames pass", arguments: ["abc", "matt.b", "lift_heavy_2026", String(repeating: "a", count: 20)])
    func validUsernames(_ name: String) {
        #expect(UsernameRules.validationMessage(for: name) == nil)
    }

    @Test("too short is rejected")
    func tooShort() {
        #expect(UsernameRules.validationMessage(for: "ab") != nil)
        #expect(UsernameRules.validationMessage(for: "") != nil)
    }

    @Test("too long is rejected")
    func tooLong() {
        #expect(UsernameRules.validationMessage(for: String(repeating: "a", count: 21)) != nil)
    }

    @Test("uppercase or symbols are rejected without normalizing", arguments: ["Matt", "matt b", "matt!", "matt-b"])
    func invalidCharacters(_ name: String) {
        #expect(UsernameRules.validationMessage(for: name) != nil)
    }

    @Test("rules match the Firestore rules pattern ^[a-z0-9_.]{3,20}$")
    func matchesServerPattern() throws {
        let regex = try Regex("^[a-z0-9_.]{3,20}$")
        for raw in ["Matt.B!", "ok", "Gym Rat 99", "a_b.c", String(repeating: "Z", count: 25)] {
            let name = UsernameRules.normalize(raw)
            let clientValid = UsernameRules.validationMessage(for: name) == nil
            let serverValid = name.wholeMatch(of: regex) != nil
            #expect(clientValid == serverValid, "client and server disagree on \(name)")
        }
    }
}

// MARK: - PublicProfile

@Suite("PublicProfile")
struct PublicProfileTests {

    @Test("initials use first letters of first two words")
    func initialsTwoWords() {
        #expect(makeProfile(displayName: "Matthew Brignola").initials == "MB")
        #expect(makeProfile(displayName: "anna maria lopez").initials == "AM")
    }

    @Test("initials for a single name")
    func initialsOneWord() {
        #expect(makeProfile(displayName: "Matt").initials == "M")
    }

    @Test("initials fall back to username when display name is empty")
    func initialsFallback() {
        #expect(makeProfile(username: "zeke", displayName: "").initials == "Z")
    }

    @Test("counts default to zero")
    func defaultCounts() {
        let profile = makeProfile(displayName: "Matt")
        #expect(profile.followerCount == 0)
        #expect(profile.followingCount == 0)
        #expect(profile.postCount == 0)
    }
}

// MARK: - WorkoutSnapshot

@Suite("WorkoutSnapshot from CompletedSession", .serialized)
@MainActor
struct WorkoutSnapshotTests {

    @Test("copies session metadata")
    func metadata() throws {
        let context = try makeContext()
        let date = Date(timeIntervalSince1970: 1_800_000_000)
        let session = CompletedSession(date: date, programTitle: "PPL", sessionName: "Push Day")
        context.insert(session)

        let snapshot = WorkoutSnapshot(session: session)
        #expect(snapshot.programTitle == "PPL")
        #expect(snapshot.sessionName == "Push Day")
        #expect(snapshot.date == date)
    }

    @Test("empty session produces an empty snapshot")
    func emptySession() throws {
        let context = try makeContext()
        let session = CompletedSession(programTitle: "PPL", sessionName: "Rest")
        context.insert(session)

        let snapshot = WorkoutSnapshot(session: session)
        #expect(snapshot.isEmpty)
        #expect(snapshot.totalSets == 0)
        #expect(snapshot.totalMiles == 0)
    }

    @Test("strength: counts sets, sums reps, takes heaviest set")
    func strengthSummary() throws {
        let context = try makeContext()
        let session = CompletedSession(programTitle: "PPL", sessionName: "Push Day")
        context.insert(session)
        let bench = StrengthEntry(exercise: "Bench Press", date: .now, sets: [
            SetRecord(combined: 135, reps: 10),
            SetRecord(combined: 185, reps: 8),
            SetRecord(combined: 165, reps: 6)
        ])
        session.strengthEntries.append(bench)

        let snapshot = WorkoutSnapshot(session: session)
        let summary = try #require(snapshot.strength.first)
        #expect(snapshot.strength.count == 1)
        #expect(summary.exercise == "Bench Press")
        #expect(summary.sets == 3)
        #expect(summary.totalReps == 24)
        #expect(summary.topWeight == 185)
        #expect(snapshot.totalSets == 3)
        #expect(!snapshot.isEmpty)
    }

    @Test("strength: single-arm sets use the heavier side")
    func strengthIsoTopWeight() throws {
        let context = try makeContext()
        let session = CompletedSession(programTitle: "PPL", sessionName: "Pull Day")
        context.insert(session)
        let row = StrengthEntry(exercise: "Single-Arm Row", date: .now, sets: [
            SetRecord(left: 60, right: 65, reps: 10),
            SetRecord(left: 70, right: 55, reps: 8)
        ], iso: true)
        session.strengthEntries.append(row)

        let summary = try #require(WorkoutSnapshot(session: session).strength.first)
        #expect(summary.topWeight == 70)
        #expect(summary.totalReps == 18)
    }

    @Test("strength: entry with no sets has zero top weight")
    func strengthNoSets() throws {
        let context = try makeContext()
        let session = CompletedSession(programTitle: "PPL", sessionName: "Push Day")
        context.insert(session)
        session.strengthEntries.append(StrengthEntry(exercise: "Dips", date: .now, sets: []))

        let summary = try #require(WorkoutSnapshot(session: session).strength.first)
        #expect(summary.sets == 0)
        #expect(summary.totalReps == 0)
        #expect(summary.topWeight == 0)
    }

    @Test("cardio: keeps seconds and miles, totals across entries")
    func cardioSummary() throws {
        let context = try makeContext()
        let session = CompletedSession(programTitle: "Conditioning", sessionName: "Run")
        context.insert(session)
        session.cardioEntries.append(CardioEntry(exercise: "Treadmill", duration: 1_800, distance: 3.1))
        session.cardioEntries.append(CardioEntry(exercise: "Bike", duration: 900, distance: nil))

        let snapshot = WorkoutSnapshot(session: session)
        #expect(snapshot.cardio.count == 2)
        let treadmill = try #require(snapshot.cardio.first { $0.exercise == "Treadmill" })
        #expect(treadmill.durationSeconds == 1_800)
        #expect(treadmill.distanceMiles == 3.1)
        let bike = try #require(snapshot.cardio.first { $0.exercise == "Bike" })
        #expect(bike.distanceMiles == nil)
        #expect(abs(snapshot.totalMiles - 3.1) < 0.0001)
        #expect(snapshot.totalCardioMinutes == 45)
    }

    @Test("mobility: keeps rounds and hold seconds")
    func mobilitySummary() throws {
        let context = try makeContext()
        let session = CompletedSession(programTitle: "Recovery", sessionName: "Stretch")
        context.insert(session)
        session.mobilityEntries.append(MobilityEntry(exercise: "Pigeon Pose", holdTime: 45, rounds: 3))

        let snapshot = WorkoutSnapshot(session: session)
        let summary = try #require(snapshot.mobility.first)
        #expect(summary.exercise == "Pigeon Pose")
        #expect(summary.rounds == 3)
        #expect(summary.holdSeconds == 45)
        #expect(!snapshot.isEmpty)
    }

    @Test("snapshot is independent of later edits to the session")
    func snapshotIsACopy() throws {
        let context = try makeContext()
        let session = CompletedSession(programTitle: "PPL", sessionName: "Push Day")
        context.insert(session)
        session.strengthEntries.append(StrengthEntry(exercise: "Bench Press", date: .now, sets: [SetRecord(combined: 135, reps: 10)]))

        let snapshot = WorkoutSnapshot(session: session)
        session.sessionName = "Renamed"
        session.strengthEntries.removeAll()

        #expect(snapshot.sessionName == "Push Day")
        #expect(snapshot.strength.count == 1)
    }
}

// MARK: - WorkoutPost encoding

@Suite("WorkoutPost encoding")
struct WorkoutPostEncodingTests {

    private func samplePost() -> WorkoutPost {
        WorkoutPost(
            authorId: "uid123",
            authorUsername: "mattb",
            authorDisplayName: "Matt",
            caption: "New PR!",
            workout: WorkoutSnapshot(
                programTitle: "PPL",
                sessionName: "Push Day",
                date: Date(timeIntervalSince1970: 1_800_000_000),
                strength: [.init(exercise: "Bench Press", sets: 3, totalReps: 24, topWeight: 185)],
                cardio: [.init(exercise: "Treadmill", durationSeconds: 600, distanceMiles: 1.0)],
                mobility: [.init(exercise: "Pigeon Pose", rounds: 2, holdSeconds: 30)]
            )
        )
    }

    // WorkoutPost itself can't be decoded outside a real snapshot (its @DocumentID
    // needs a DocumentReference), so round-trip the workout payload it carries.
    @Test("workout round-trips through the Firestore encoder without losing data")
    func firestoreRoundTrip() throws {
        let workout = samplePost().workout
        let fields = try Firestore.Encoder().encode(workout)
        let decoded = try Firestore.Decoder().decode(WorkoutSnapshot.self, from: fields)
        #expect(decoded == workout)
    }

    @Test("uses the field names the Firestore rules check")
    func fieldNames() throws {
        let object = try Firestore.Encoder().encode(samplePost())
        #expect(object["authorId"] as? String == "uid123")
        #expect(object["caption"] as? String == "New PR!")
        #expect(object["workout"] is [String: Any])
    }
}
