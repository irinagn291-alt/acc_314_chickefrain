import Foundation

/// BareMark is Weave on Idle, when no Slip carries a Lemma. Panels stay empty.
struct BareMark: Codable, Hashable, Sendable, Equatable, Identifiable {
    var id: UUID
    var daykey: DayKey
}
