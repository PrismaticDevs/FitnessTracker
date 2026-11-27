//
//  SocialService.swift
//  FitnessTracker
//
//  Firestore access for FiT Social: public profiles, username claims and posts.
//
//  Collections:
//    profiles/{uid}         PublicProfile (readable by any signed-in user)
//    usernames/{username}   { uid } — makes usernames unique
//    posts/{postId}         WorkoutPost
//

import Foundation
import FirebaseFirestore

enum SocialError: LocalizedError {
    case notSignedIn
    case usernameTaken
    case invalidUsername(String)
    case noProfile
    case emptyWorkout
    case tooYoungForPublic

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "Sign in to use FiT Social."
        case .usernameTaken: return "That username is already taken."
        case .invalidUsername(let message): return message
        case .noProfile: return "Set up your FiT Social profile first."
        case .emptyWorkout: return "This session has no exercises to share."
        case .tooYoungForPublic:
            return "Public profiles are for people \(SocialPrivacyRules.minimumPublicAge) and older. Your profile will stay private."
        }
    }
}

@MainActor
final class SocialService: ObservableObject {
    static let shared = SocialService()

    @Published private(set) var myProfile: PublicProfile?
    @Published private(set) var hasLoadedProfile = false
    @Published private(set) var feed: [WorkoutPost] = []
    @Published private(set) var isLoadingFeed = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var profiles: CollectionReference { db.collection("profiles") }
    private var usernames: CollectionReference { db.collection("usernames") }
    private var posts: CollectionReference { db.collection("posts") }

    private init() {}

    // MARK: - Profile

    func loadMyProfile(uid: String) async {
        do {
            let snapshot = try await profiles.document(uid).getDocument()
            myProfile = snapshot.exists ? try snapshot.data(as: PublicProfile.self) : nil
        } catch {
            errorMessage = "Couldn't load your profile: \(error.localizedDescription)"
        }
        hasLoadedProfile = true
    }

    /// Creates or updates the signed-in user's profile, claiming the username atomically.
    func saveProfile(uid: String, username rawUsername: String, displayName: String, bio: String,
                     homeGym: String, homeGymPlace: GymPlace? = nil,
                     isPublic: Bool = false, showAtGym: Bool = false, age: Int? = nil) async throws {
        let username = UsernameRules.normalize(rawUsername)
        if let message = UsernameRules.validationMessage(for: username) {
            throw SocialError.invalidUsername(message)
        }
        if isPublic && !SocialPrivacyRules.canBePublic(age: age) {
            throw SocialError.tooYoungForPublic
        }

        let previousUsername = myProfile?.username
        let wasPublic = myProfile?.isPubliclyVisible ?? false
        let profileRef = profiles.document(uid)
        let usernameRef = usernames.document(username)
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        var fields: [String: Any] = [
            "username": username,
            "displayName": trimmedName.isEmpty ? username : trimmedName,
            "bio": String(bio.prefix(160)),
            "homeGym": String(homeGym.trimmingCharacters(in: .whitespacesAndNewlines).prefix(100)),
            "isPublic": isPublic,
            // Listing at a gym requires a public profile.
            "showAtGym": isPublic && showAtGym,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let homeGymPlace {
            fields["homeGymPlace"] = try Firestore.Encoder().encode(homeGymPlace)
        } else if myProfile?.homeGymPlace != nil {
            fields["homeGymPlace"] = FieldValue.delete()
        }
        if myProfile == nil {
            fields["createdAt"] = FieldValue.serverTimestamp()
            fields["followerCount"] = 0
            fields["followingCount"] = 0
            fields["postCount"] = 0
        }

        do {
            _ = try await db.runTransaction { transaction, errorPointer in
                do {
                    let claim = try transaction.getDocument(usernameRef)
                    if claim.exists, (claim.data()?["uid"] as? String) != uid {
                        errorPointer?.pointee = SocialError.usernameTaken as NSError
                        return nil
                    }
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
                if let previousUsername, previousUsername != username {
                    transaction.deleteDocument(self.usernames.document(previousUsername))
                }
                transaction.setData(["uid": uid], forDocument: usernameRef)
                transaction.setData(fields, forDocument: profileRef, merge: true)
                return nil
            }
        } catch let error as NSError where error.domain == String(reflecting: SocialError.self) {
            throw SocialError.usernameTaken
        }

        // Going public or private changes who can see existing posts too.
        if wasPublic != isPublic {
            try await setVisibilityOfMyPosts(isPublic ? .public : .private, uid: uid)
        }

        await loadMyProfile(uid: uid)
    }

    private func myPostRefs(uid: String) async throws -> [DocumentReference] {
        try await posts.whereField("authorId", isEqualTo: uid).getDocuments().documents.map(\.reference)
    }

    private func setVisibilityOfMyPosts(_ visibility: PostVisibility, uid: String) async throws {
        for chunk in try await myPostRefs(uid: uid).chunked(into: 450) {
            let batch = db.batch()
            chunk.forEach { batch.updateData(["visibility": visibility.rawValue], forDocument: $0) }
            try await batch.commit()
        }
    }

    // MARK: - Gyms

    /// People who chose to be listed at this gym (public profile + "show me at my gym").
    /// Only name, @username and gym are shown. Never when they're there or where they are.
    func membersAtGym(_ gymID: String, excluding uid: String?, limit: Int = 50) async throws -> [PublicProfile] {
        let snapshot = try await profiles
            .whereField("homeGymPlace.id", isEqualTo: gymID)
            .whereField("isPublic", isEqualTo: true)
            .whereField("showAtGym", isEqualTo: true)
            .limit(to: limit)
            .getDocuments()
        return snapshot.documents
            .compactMap { try? $0.data(as: PublicProfile.self) }
            .filter { $0.id != uid }
            .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }

    // MARK: - Delete

    /// Removes everything FiT Social stores for this user: posts, username claim and profile.
    /// Private workout history (users/{uid}) is not touched.
    func deleteMySocialData(uid: String) async throws {
        for chunk in try await myPostRefs(uid: uid).chunked(into: 450) {
            let batch = db.batch()
            chunk.forEach { batch.deleteDocument($0) }
            try await batch.commit()
        }
        let batch = db.batch()
        if let username = myProfile?.username {
            batch.deleteDocument(usernames.document(username))
        }
        batch.deleteDocument(profiles.document(uid))
        try await batch.commit()
        reset()
        hasLoadedProfile = true
    }

    // MARK: - Posts

    func shareWorkout(_ session: CompletedSession, caption: String, uid: String) async throws {
        guard let profile = myProfile else { throw SocialError.noProfile }
        let snapshot = WorkoutSnapshot(session: session)
        guard !snapshot.isEmpty else { throw SocialError.emptyWorkout }

        let post = WorkoutPost(
            authorId: uid,
            authorUsername: profile.username,
            authorDisplayName: profile.displayName,
            caption: String(caption.trimmingCharacters(in: .whitespacesAndNewlines).prefix(500)),
            workout: snapshot,
            visibility: PostVisibility.forAuthor(profile)
        )

        let batch = db.batch()
        let postRef = posts.document()
        try batch.setData(from: post, forDocument: postRef)
        batch.updateData(["postCount": FieldValue.increment(Int64(1))], forDocument: profiles.document(uid))
        try await batch.commit()

        await loadMyProfile(uid: uid)
        await refreshFeed()
    }

    func deletePost(_ post: WorkoutPost, uid: String) async throws {
        guard let id = post.id, post.authorId == uid else { return }
        let batch = db.batch()
        batch.deleteDocument(posts.document(id))
        batch.updateData(["postCount": FieldValue.increment(Int64(-1))], forDocument: profiles.document(uid))
        try await batch.commit()
        feed.removeAll { $0.id == id }
        await loadMyProfile(uid: uid)
    }

    /// Public posts from everyone plus your own posts (including private ones).
    /// Becomes "people you follow" once follows exist.
    func refreshFeed(limit: Int = 50) async {
        isLoadingFeed = true
        defer { isLoadingFeed = false }
        do {
            let publicPosts = try await posts
                .whereField("visibility", isEqualTo: PostVisibility.public.rawValue)
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .getDocuments()
                .documents.compactMap { try? $0.data(as: WorkoutPost.self) }

            var mine: [WorkoutPost] = []
            if let uid = myProfile?.id {
                mine = try await posts
                    .whereField("authorId", isEqualTo: uid)
                    .limit(to: limit)
                    .getDocuments()
                    .documents.compactMap { try? $0.data(as: WorkoutPost.self) }
            }
            feed = Self.mergeFeed(publicPosts, mine, limit: limit)
        } catch {
            errorMessage = "Couldn't load the feed: \(error.localizedDescription)"
        }
    }

    /// Combines public posts and your own, without duplicates, newest first.
    nonisolated static func mergeFeed(_ a: [WorkoutPost], _ b: [WorkoutPost], limit: Int) -> [WorkoutPost] {
        var seen = Set<String>()
        let combined = (a + b).filter { post in
            guard let id = post.id else { return true }
            return seen.insert(id).inserted
        }
        // Posts still being written have no server timestamp yet; treat them as newest.
        return Array(combined.sorted { ($0.createdAt ?? .distantFuture) > ($1.createdAt ?? .distantFuture) }.prefix(limit))
    }

    func reset() {
        myProfile = nil
        hasLoadedProfile = false
        feed = []
    }
}

extension Array {
    /// Splits into consecutive pieces of at most `size` elements (Firestore batches max out at 500 writes).
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map { Array(self[$0..<Swift.min($0 + size, count)]) }
    }
}
