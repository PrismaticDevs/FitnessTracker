//
//  ChatViewModel.swift
//  FitnessTracker
//
//  Created by Matt on 1/23/26.
//

import FirebaseAILogic
import SwiftUI

struct AICoachService {
    private let ai = FirebaseAI.firebaseAI(backend: .googleAI())
    
    private var model: GenerativeModel {
        ai.generativeModel(modelName: "gemini-3-flash")
    }
    
    func getWorkoutAdvice(context: String, userQuery: String) async throws -> String {
        // Create a detailed prompt combining your Session data and the user's question
        let prompt = """
            You are an expert fitness coach. Use the following workout data to answer:
            \(context)
            
            User Question: \(userQuery)
            """
        
        let response = try await model.generateContent(prompt)
        return response.text ?? "I'm not sure how to answer that based on your current sets."
    }
}
