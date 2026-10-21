import Foundation

/// WeaveMark seats three SlipIDs for one daykey and folds Spooled to Woven.
struct WeaveMark: Codable, Hashable, Sendable, Equatable, Identifiable {
    var id: UUID
    var daykey: DayKey
    var lemma: Lemma
    var left: SlipID
    var center: SlipID
    var right: SlipID
}
