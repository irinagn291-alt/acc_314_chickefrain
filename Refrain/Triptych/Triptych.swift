import Foundation

/// Triptych is the daykey fold: Blank, Idle, Spooled, or Woven.
/// The gallery is the list of these folds, one per day that has a mark.
struct Triptych: Codable, Hashable, Sendable, Equatable {
    var daykey: DayKey
    var phase: TriptychPhase
    var left: Panel
    var center: Panel
    var right: Panel

    var panelsEmpty: Bool {
        left.isEmpty && center.isEmpty && right.isEmpty
    }
}

/// Idle waits for a lemma across three volumes.
/// Spooled can Weave. Woven is seated until Peel. Blank is an empty gallery.
enum TriptychPhase: String, Codable, Hashable, Sendable {
    case blank
    case idle
    case spooled
    case woven
}

/// YYYYMMDD calendar day. Folds do not share a daykey.
struct DayKey: Codable, Hashable, Sendable, Equatable, Comparable {
    var raw: Int

    static func < (lhs: DayKey, rhs: DayKey) -> Bool {
        lhs.raw < rhs.raw
    }

    static func make(from date: Date, calendar: Calendar = .current) -> DayKey {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return DayKey(raw: year * 10_000 + month * 100 + day)
    }
}
