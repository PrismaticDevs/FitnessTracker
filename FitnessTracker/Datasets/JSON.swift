//
//  JSON.swift
//  FitnessTracker
//
//  Created by Matt on 2/9/25.
//

import Foundation

class JSONDataManager {
    static let shared = JSONDataManager()
    
    private init() {}
    
    func saveSession(_ session: Session) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(session) {
            let url = getDocumentsDirectory().appendingPathComponent("session.json")
            try? data.write(to: url)
        }
    }
    
    func loadSession() -> Session? {
        let url = getDocumentsDirectory().appendingPathComponent("session.json")
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            return try? decoder.decode(Session.self, from: data)
        }
        return nil
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
