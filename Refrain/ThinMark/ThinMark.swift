import Foundation

/// ThinMark is Weave when lemmas exist and none spans three volumes.
struct ThinMark: Codable, Hashable, Sendable, Equatable, Identifiable {
    var id: UUID
    var daykey: DayKey
}
