//import XCTest
//import FirebaseAILogic
//
//final class AICoachServiceTests: XCTestCase {
//
//    func testGeminiConnection() async throws {
//        let coachService = AICoachService()
//
//        let context = "User has just completed a light cardio workout."
//        let userQuery = "What's a good post-workout snack?"
//
//        let advice = try await coachService.getWorkoutAdvice(context: context, userQuery: userQuery)
//
//        XCTAssertFalse(advice.isEmpty, "The AI coach should return a non-empty advice string.")
//        print("✅ Successfully received AI advice: \(advice.prefix(100))...")
//    }
//}
