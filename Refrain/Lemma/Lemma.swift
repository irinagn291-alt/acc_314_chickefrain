import Foundation

/// Lemma is the single normalized word Thread writes onto a Slip.
/// Qualification is counted in words, never in raw typing.
struct Lemma: Codable, Hashable, Sendable, Equatable {
    var word: String

    /// Lowercase, trimmed, internal whitespace collapsed. Empty input is nil.
    static func normalize(_ raw: String) -> Lemma? {
        let folded = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let pieces = folded.split(whereSeparator: { $0.isWhitespace })
        let word = pieces.joined(separator: " ")
        guard !word.isEmpty else { return nil }
        return Lemma(word: word)
    }
}
