//
//  HistoryView.swift
//  FitnessTracker
//
//  Created by Matt on 10/15/25.
//

import SwiftUI
import SwiftData
import FirebaseFirestore

struct WorkoutHistoryList: View {
    @Query(sort: [SortDescriptor(\WorkoutHistory.date, order: .reverse)]) var history: [WorkoutHistory]
    @EnvironmentObject var auth: AuthManager
    @Environment(\.modelContext) private var context
    var body: some View {
        List {
            ForEach(history) { h in
                NavigationLink(value: h) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(h.exercise).font(.headline)
                            Text(DateFormatter.localizedString(from: h.date, dateStyle: .short, timeStyle: .short))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(h.entries.count) entry\(h.entries.count == 1 ? "" : "ies")")
                            .font(.caption)
                    }
                }
            }
            .onDelete { idx in
                delete(at: idx)
            }
        }
        .onAppear {
            if let userId = auth.user?.uid ?? FBAuth.auth().currentUser?.uid {
                SyncManager.shared.fetchHistoryFromCloud(userId: userId, context: context)
            }
        }
        .task {
            if let userId = auth.user?.uid ?? FBAuth.auth().currentUser?.uid {
                SyncManager.shared.fetchHistoryFromCloud(userId: userId, context: context)
            }
        }
        .refreshable {
            if let userId = auth.user?.uid ?? FBAuth.auth().currentUser?.uid {
                SyncManager.shared.fetchHistoryFromCloud(userId: userId, context: context)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets {
            let historyItem = history[i]
            let idToDelete = historyItem.id.uuidString
            
            // 1. Delete from Local
            context.delete(historyItem)
            
            // 2. Delete from Cloud
            if let userId = auth.user?.uid {
                Firestore.firestore().collection("users").document(userId)
                    .collection("history").document(idToDelete).delete()
            }
        }
        try? context.save()
    }
}
#Preview {
    WorkoutHistoryList()
}
