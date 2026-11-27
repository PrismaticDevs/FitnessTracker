//
//  GymSearchService.swift
//  FitnessTracker
//
//  Finds gyms with Apple Maps (MapKit local search). No API key or extra cost.
//

import Foundation
import CoreLocation
import MapKit

@MainActor
final class GymSearchService: ObservableObject {
    @Published private(set) var results: [GymPlace] = []
    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?

    /// How far around the user to look when browsing nearby gyms.
    static let nearbyRadiusMeters: CLLocationDistance = 8_000   // ~5 miles

    private var currentSearch: MKLocalSearch?

    /// Gyms near `location` (no search text).
    func searchNearby(_ location: CLLocation) async {
        let request = MKLocalPointsOfInterestRequest(center: location.coordinate, radius: Self.nearbyRadiusMeters)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.fitnessCenter])
        await run(MKLocalSearch(request: request), sortedFrom: location)
    }

    /// Gyms matching `query`, preferring ones near `location` when available.
    /// Tries fitness centers first, then any place, so gyms Apple Maps files under another
    /// category (climbing gyms, boxing clubs, studios) still show up.
    func search(_ query: String, near location: CLLocation?) async {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            if let location { await searchNearby(location) } else { results = [] }
            return
        }

        await run(makeSearch(text, near: location, fitnessOnly: true), sortedFrom: location)
        if results.isEmpty && errorMessage == nil {
            await run(makeSearch(text, near: location, fitnessOnly: false), sortedFrom: location)
        }
    }

    func clear() {
        currentSearch?.cancel()
        results = []
        errorMessage = nil
    }

    private func makeSearch(_ text: String, near location: CLLocation?, fitnessOnly: Bool) -> MKLocalSearch {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.resultTypes = .pointOfInterest
        if fitnessOnly {
            request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.fitnessCenter])
        }
        if let location {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: Self.nearbyRadiusMeters * 4,
                longitudinalMeters: Self.nearbyRadiusMeters * 4
            )
        }
        return MKLocalSearch(request: request)
    }

    private func run(_ search: MKLocalSearch, sortedFrom location: CLLocation?) async {
        currentSearch?.cancel()
        currentSearch = search
        isSearching = true
        errorMessage = nil
        defer { isSearching = false }

        do {
            let response = try await search.start()
            guard currentSearch === search else { return } // a newer search replaced this one
            results = Self.dedupedAndSorted(response.mapItems.compactMap(GymPlace.init(mapItem:)), from: location)
        } catch {
            guard currentSearch === search else { return }
            results = []
            // MKError.placemarkNotFound just means "no results"; anything else is a real failure.
            if (error as? MKError)?.code != .placemarkNotFound {
                errorMessage = "Couldn't search Apple Maps right now. You can still type your gym's name."
            }
        }
    }

    nonisolated static func dedupedAndSorted(_ places: [GymPlace], from location: CLLocation?) -> [GymPlace] {
        var seen = Set<String>()
        let unique = places.filter { seen.insert($0.id).inserted }
        guard let location else { return unique }
        return unique.sorted { ($0.miles(from: location) ?? .infinity) < ($1.miles(from: location) ?? .infinity) }
    }
}
