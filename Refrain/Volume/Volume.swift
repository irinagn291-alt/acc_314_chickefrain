import Foundation

/// Volume is one book and the only quote store for its Slips.
/// Hollowed keeps the spine on the shelf and leaves Slips weavable.
struct Volume: Codable, Hashable, Sendable, Equatable, Identifiable {
    var id: VolumeID
    var title: String
    var author: String
    var currentPage: Int
    var totalPages: Int
    var spine: Spine
    var verdict: Verdict

    /// currentPage / totalPages. Nil when the book has no page count.
    var progressFraction: Double? {
        guard totalPages > 0 else { return nil }
        let page = max(0, currentPage)
        return Double(page) / Double(totalPages)
    }
}

/// Stable identity for a Volume. Not a list index.
struct VolumeID: Codable, Hashable, Sendable, Equatable, RawRepresentable {
    var rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

/// Held is on the shelf. Hollowed is gone, with slips retained.
enum Spine: String, Codable, Hashable, Sendable {
    case held
    case hollowed
}

/// Reread or not. There is no star rating.
enum Verdict: String, Codable, Hashable, Sendable {
    case reread
    case not
}
