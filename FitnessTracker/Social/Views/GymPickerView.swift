//
//  GymPickerView.swift
//  FitnessTracker
//
//  Sheet for choosing a home gym: browse gyms near you on a map, search Apple Maps
//  by name, or just use what you typed.
//

import SwiftUI
import MapKit

/// What the user picked: a real place from Apple Maps, or free text.
enum GymChoice: Equatable {
    case place(GymPlace)
    case manual(String)

    var name: String {
        switch self {
        case .place(let place): return place.name
        case .manual(let text): return text
        }
    }

    var place: GymPlace? {
        if case .place(let place) = self { return place }
        return nil
    }
}

struct GymPickerView: View {
    enum Mode {
        /// Choose a home gym for the profile.
        case pick
        /// Look around: tapping a gym shows who trains there.
        case browse
    }

    var mode: Mode = .pick
    /// Text to start with (e.g. what's already in the profile's gym field).
    var initialQuery: String = ""
    /// The gym already saved on the profile, shown as selected.
    var initialPlace: GymPlace?
    var onChoose: (GymChoice) -> Void = { _ in }

    @ObservedObject var theme = ThemeManager.shared
    @StateObject private var location = LocationManager()
    @StateObject private var search = GymSearchService()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var query = ""
    @State private var choice: GymChoice?
    @State private var mapSelection: String?
    @State private var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var gymToShow: GymPlace?

    private var trimmedQuery: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        VStack(spacing: 14) {
            Text(mode == .pick ? "Choose Your Gym" : "Browse Gyms")
                .font(.title3.bold())
                .padding(.top)

            searchField
            locationStatus
            map

            ScrollView {
                VStack(spacing: 8) {
                    if mode == .pick { manualEntryRow }
                    resultsList
                }
            }

            if mode == .pick {
                SheetActionButtons(
                    primaryTitle: "Use This Gym",
                    isPrimaryEnabled: choice != nil,
                    onCancel: { dismiss() },
                    onPrimary: {
                        if let choice { onChoose(choice) }
                        dismiss()
                    }
                )
            } else {
                SheetActionButtons(primaryTitle: "Done", onPrimary: { dismiss() })
            }
        }
        .sheet(item: $gymToShow, onDismiss: {
            // Let the same map pin be tapped again after closing its details.
            if mode == .browse { mapSelection = nil }
        }) { gym in
            GymDetailView(gym: gym)
        }
        .padding(.horizontal, 25)
        .padding(.bottom, 25)
        .foregroundColor(.textPrimary)
        .presentationDragIndicator(.visible)
        .onAppear {
            query = initialQuery
            if let initialPlace {
                choice = .place(initialPlace)
                camera = .region(MKCoordinateRegion(center: initialPlace.coordinate,
                                                    latitudinalMeters: 1_500, longitudinalMeters: 1_500))
            }
            if location.isAuthorized { location.requestLocation() }
        }
        // Search as the user types (short pause so we don't search on every keystroke).
        .task(id: query) {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            await runSearch()
        }
        .onChange(of: location.location) { _, _ in
            Task { await runSearch() }
        }
        .onChange(of: mapSelection) { _, id in
            if let id, let place = search.results.first(where: { $0.id == id }) {
                if mode == .browse { gymToShow = place } else { choice = .place(place) }
            }
        }
        .onChange(of: search.results) { _, results in
            // Fit all markers on screen, unless the user is looking at a gym they picked.
            if !results.isEmpty, choice?.place == nil { camera = .automatic }
        }
    }

    // MARK: - Pieces

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(.textSecondary)
            TextField("Search gyms or type a name", text: $query,
                      prompt: Text("Search gyms or type a name").foregroundColor(.textTertiary))
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit { Task { await runSearch() } }
            if search.isSearching {
                ProgressView()
            } else if !query.isEmpty {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(theme.currentTheme.accentSurface.opacity(0.8))
        .cornerRadius(12)
    }

    @ViewBuilder
    private var locationStatus: some View {
        if location.isDenied {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "location.slash")
                VStack(alignment: .leading, spacing: 4) {
                    Text("Location is off for FitnessTracker. Search by name, or turn it on to see gyms near you.")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                    }
                    .font(.caption.bold())
                    .foregroundColor(theme.currentTheme.accentText)
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .background(Color.fillSubtle)
            .cornerRadius(10)
        } else if !location.isAuthorized || location.location == nil {
            Button { location.requestLocation() } label: {
                HStack {
                    if location.isLocating {
                        ProgressView().tint(.onAccent)
                    } else {
                        Image(systemName: "location.fill")
                    }
                    Text(location.isLocating ? "Finding you…" : "Find Gyms Near Me")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(theme.currentTheme.accent)
                .foregroundColor(.onAccent)
                .cornerRadius(12)
            }
            .disabled(location.isLocating)
        }

        if let message = location.errorMessage ?? search.errorMessage {
            Text(message)
                .font(.caption)
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var map: some View {
        Map(position: $camera, selection: $mapSelection) {
            UserAnnotation()
            ForEach(search.results) { place in
                Marker(place.name, systemImage: "dumbbell.fill", coordinate: place.coordinate)
                    .tint(choice?.place?.id == place.id ? theme.currentTheme.accent : .gray)
                    .tag(place.id)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .frame(height: 200)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.strokeSubtle, lineWidth: 1))
    }

    @ViewBuilder
    private var manualEntryRow: some View {
        if !trimmedQuery.isEmpty {
            let isChosen = choice == .manual(trimmedQuery)
            Button {
                choice = .manual(trimmedQuery)
                mapSelection = nil
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "pencil.line")
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Use “\(trimmedQuery)”").font(.subheadline.bold())
                        Text("Not on the map? Save it exactly as typed.")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    if isChosen { Image(systemName: "checkmark.circle.fill").foregroundColor(theme.currentTheme.accentText) }
                }
                .padding(12)
                .background(isChosen ? theme.currentTheme.accentSurface.opacity(0.6) : Color.fillSubtle)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var resultsList: some View {
        if search.results.isEmpty && !search.isSearching {
            Text(emptyMessage)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
        } else {
            ForEach(search.results) { place in
                gymRow(place)
            }
        }
    }

    private func gymRow(_ place: GymPlace) -> some View {
        let isChosen = choice?.place?.id == place.id
        // Two sibling buttons (not nested) so each has its own tap target and VoiceOver element.
        return HStack(spacing: 4) {
            Button {
                if mode == .browse {
                    gymToShow = place
                    return
                }
                choice = .place(place)
                mapSelection = place.id
                camera = .region(MKCoordinateRegion(center: place.coordinate,
                                                    latitudinalMeters: 1_500, longitudinalMeters: 1_500))
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "dumbbell.fill")
                        .frame(width: 28)
                        .foregroundColor(theme.currentTheme.accentText)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(place.name).font(.subheadline.bold())
                        if !place.address.isEmpty {
                            Text(place.address)
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                    if let distance = GymPlace.distanceText(miles: place.miles(from: location.location)) {
                        Text(distance)
                            .font(.caption.bold())
                            .foregroundColor(.textSecondary)
                    }
                    if isChosen { Image(systemName: "checkmark.circle.fill").foregroundColor(theme.currentTheme.accentText) }
                    if mode == .browse {
                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                            .foregroundColor(.textTertiary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if mode == .pick {
                // See who trains here before choosing it.
                Button { gymToShow = place } label: {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.textSecondary)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See members at \(place.name)")
            }
        }
        .padding(12)
        .background(isChosen ? theme.currentTheme.accentSurface.opacity(0.6) : Color.fillSubtle)
        .cornerRadius(12)
    }

    private var emptyMessage: String {
        if !trimmedQuery.isEmpty { return "No gyms on Apple Maps match “\(trimmedQuery)”. You can still use it as typed." }
        if location.location == nil { return "Search for your gym by name, or find gyms near you." }
        return "No gyms found within about 5 miles. Try searching by name."
    }

    private func runSearch() async {
        await search.search(query, near: location.location)
    }
}

#Preview {
    Text("Profile")
        .sheet(isPresented: .constant(true)) {
            GymPickerView(initialQuery: "") { print($0) }
        }
}
