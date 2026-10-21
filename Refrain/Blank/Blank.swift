import Foundation

/// Blank is the mark Weave writes when the gallery has no volumes and no slips.
struct Blank: Codable, Hashable, Sendable, Equatable, Identifiable {
    var id: UUID
    var daykey: DayKey
}
