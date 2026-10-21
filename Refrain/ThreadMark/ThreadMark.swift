import Foundation

/// ThreadMark records one Thread: a normalized Lemma assigned to one Slip.
struct ThreadMark: Codable, Hashable, Sendable, Equatable, Identifiable {
    var id: UUID
    var daykey: DayKey
    var slipID: SlipID
    var lemma: Lemma
}
