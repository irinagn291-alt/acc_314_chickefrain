import Foundation

/// Peel removes the newest WeaveMark for a daykey and folds Woven back to Spooled.
struct Peel: Codable, Hashable, Sendable, Equatable, Identifiable {
    var id: UUID
    var daykey: DayKey
    var weaveMarkID: UUID
}
