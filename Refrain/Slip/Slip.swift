import Foundation

/// Slip is one saved line inside a single Volume quote store.
/// Thread replaces its Lemma. The line stays when the spine is hollowed.
struct Slip: Codable, Hashable, Sendable, Equatable, Identifiable {
    var id: SlipID
    var volumeID: VolumeID
    var text: String
    var page: Int?
    var lemma: Lemma?
}

/// Stable identity for a Slip. Not a list index.
struct SlipID: Codable, Hashable, Sendable, Equatable, RawRepresentable {
    var rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}
