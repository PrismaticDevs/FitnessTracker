//
//  AICoachServiceTests.swift
//  FitnessTrackerTests
//
//  Diagnostic + validation tests for the Gemini (Firebase AI Logic) connection.
//

import Testing
import Foundation
@testable import FitnessTracker

@Suite("AICoach / Gemini Service", .serialized)
struct AICoachServiceTests {

    /// Hits the real Gemini backend through Firebase AI Logic.
    ///
    /// The app normally swallows the error in `ChatViewModel.sendMessage` and shows
    /// "Sorry, I'm having trouble connecting to my brain right now." This test instead
    /// surfaces the ACTUAL thrown error so we can see *why* the chat is failing
    /// (e.g. App Check enforcement, Firebase AI Logic API disabled, quota/429, bad model name).
    @Test("Gemini returns a non-empty response")
    func geminiConnectionReturnsAdvice() async throws {
        AICoachService.configureFirebaseIfNeeded()

        let service = AICoachService()
        let context = "User just completed a light cardio workout."
        let query = "What's a good post-workout snack?"

        do {
            let advice = try await service.getWorkoutAdvice(context: context, userQuery: query)
            #expect(!advice.isEmpty, "Expected a non-empty advice string from Gemini")
            print("✅ Gemini responded: \(advice.prefix(300))")
        } catch {
            // Print the full error so it shows up in the test log for troubleshooting.
            print("❌ Gemini call failed.")
            print("   error: \(error)")
            print("   reflecting: \(String(reflecting: error))")
            print("   localized: \(error.localizedDescription)")
            Issue.record("Gemini call failed with real error: \(error.localizedDescription)")
            throw error
        }
    }
}
