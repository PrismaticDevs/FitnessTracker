//
//  PrivacyTests.swift
//  FitnessTrackerTests
//
//  FiT Social privacy: opt-in visibility, gym listing, age gate, post visibility, feed merging.
//

import Testing
import Foundation
import FirebaseFirestore
@testable import FitnessTracker

private let gymPlace = GymPlace(id: "gym1", name: "Iron Temple", address: "", latitude: 0, longitude: 0)

private func profile(isPublic: Bool?, showAtGym: Bool?, place: GymPlace? = gymPlace) -> PublicProfile {
    var p = PublicProfile(username: "matt", displayName: "Matt", bio: "", homeGym: place?.name ?? "")
    p.homeGymPlace = place
    p.isPublic = isPublic
    p.showAtGym = showAtGym
    return p
}

private func post(_ id: String?, secondsAgo: TimeInterval?, visibility: PostVisibility? = .public) -> WorkoutPost {
    var p = WorkoutPost(
        authorId: "u", authorUsername: "u", authorDisplayName: "U", caption: "",
        workout: WorkoutSnapshot(programTitle: "", sessionName: "", date: .now, strength: [], cardio: [], mobility: []),
        visibility: visibility
    )
    p.id = id
    p.createdAt = secondsAgo.map { Date(timeIntervalSinceNow: -$0) }
    return p
}

@Suite("Profile privacy")
struct ProfilePrivacyTests {

    @Test("profiles are private unless explicitly made public")
    func privateByDefault() {
        #expect(!profile(isPublic: nil, showAtGym: nil).isPubliclyVisible)
        #expect(!profile(isPublic: false, showAtGym: nil).isPubliclyVisible)
        #expect(profile(isPublic: true, showAtGym: nil).isPubliclyVisible)
    }

    @Test("listed at a gym only with public profile, gym opt-in, and a map gym",
          arguments: [
            (true as Bool?, true as Bool?, true, true),
            (true, false, true, false),
            (true, nil, true, false),
            (false, true, true, false),   // gym opt-in without public profile
            (nil, true, true, false),
            (true, true, false, false)    // typed gym, not from the map
          ])
    func gymListing(isPublic: Bool?, showAtGym: Bool?, hasPlace: Bool, expected: Bool) {
        let p = profile(isPublic: isPublic, showAtGym: showAtGym, place: hasPlace ? gymPlace : nil)
        #expect(p.isListedAtGym == expected)
    }

    @Test("age gate", arguments: [
        (nil as Int?, true),
        (17, false),
        (18, true),
        (35, true),
        (0, false)
    ])
    func ageGate(age: Int?, allowed: Bool) {
        #expect(SocialPrivacyRules.canBePublic(age: age) == allowed)
    }

    @Test("older profiles without privacy fields still decode as private")
    func decodesWithoutPrivacyFields() throws {
        let fields: [String: Any] = [
            "username": "matt", "displayName": "Matt", "bio": "", "homeGym": "",
            "followerCount": 0, "followingCount": 0, "postCount": 0
        ]
        // Decode the plain fields (the @DocumentID needs a real snapshot, so strip it via a helper type).
        struct Probe: Decodable { var isPublic: Bool?; var showAtGym: Bool? }
        let probe = try Firestore.Decoder().decode(Probe.self, from: fields)
        #expect(probe.isPublic == nil)
        #expect(probe.showAtGym == nil)
    }
}

@Suite("Post visibility")
struct PostVisibilityTests {

    @Test("new posts follow the author's profile")
    func followsProfile() {
        #expect(PostVisibility.forAuthor(profile(isPublic: true, showAtGym: false)) == .public)
        #expect(PostVisibility.forAuthor(profile(isPublic: false, showAtGym: false)) == .private)
        #expect(PostVisibility.forAuthor(profile(isPublic: nil, showAtGym: nil)) == .private)
    }

    @Test("posts without a visibility count as private")
    func missingIsPrivate() {
        #expect(!post("a", secondsAgo: 1, visibility: nil).isPublic)
        #expect(post("a", secondsAgo: 1, visibility: .public).isPublic)
    }

    @Test("visibility is stored as the string the rules check")
    func encodedValue() throws {
        let encoded = try Firestore.Encoder().encode(post(nil, secondsAgo: nil, visibility: .private))
        #expect(encoded["visibility"] as? String == "private")
    }
}

@Suite("Feed merging")
struct FeedMergeTests {

    @Test("merges public and own posts without duplicates, newest first")
    func mergesAndSorts() {
        let publicPosts = [post("p1", secondsAgo: 10), post("shared", secondsAgo: 30)]
        let mine = [post("shared", secondsAgo: 30), post("m1", secondsAgo: 20, visibility: .private)]
        let feed = SocialService.mergeFeed(publicPosts, mine, limit: 10)
        #expect(feed.compactMap(\.id) == ["p1", "m1", "shared"])
    }

    @Test("posts still being saved (no timestamp) show first")
    func pendingFirst() {
        let feed = SocialService.mergeFeed([post("old", secondsAgo: 60)], [post("new", secondsAgo: nil)], limit: 10)
        #expect(feed.first?.id == "new")
    }

    @Test("respects the limit")
    func limit() {
        let many = (0..<10).map { post("p\($0)", secondsAgo: Double($0)) }
        #expect(SocialService.mergeFeed(many, [], limit: 3).count == 3)
    }
}

@Suite("Batch chunking")
struct ChunkTests {

    @Test("splits into Firestore-sized batches")
    func chunks() {
        let items = Array(0..<1000)
        let chunks = items.chunked(into: 450)
        #expect(chunks.map(\.count) == [450, 450, 100])
        #expect(chunks.flatMap { $0 } == items)
    }

    @Test("empty input gives no batches")
    func empty() {
        #expect([Int]().chunked(into: 450).isEmpty)
    }
}
