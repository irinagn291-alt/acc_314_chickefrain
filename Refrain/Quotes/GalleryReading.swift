import Foundation

/// Read-only phrasing for the day fold. The gallery still owns the rules.
enum GalleryReading {
    static func status(gallery: Gallery, day: DayKey, last: WeaveResult?) -> String {
        if gallery.isEmpty {
            return "Add a book, save a line, then tap Weave."
        }
        switch gallery.phase(on: day) {
        case .blank:
            return "Add a book, save a line, then tap Weave."
        case .idle:
            if last == .thin {
                return "No word is on three books yet."
            }
            if last == .bare {
                return "Save a word on a line, then tap Weave."
            }
            return "One word needs to sit on three books."
        case .spooled:
            return "Ready. Tap Weave to seat these three lines."
        case .woven:
            return "Seated for today. Tap Reopen to choose again."
        }
    }

    static func phaseTitle(_ phase: TriptychPhase) -> String {
        switch phase {
        case .blank: "Empty"
        case .idle: "Waiting"
        case .spooled: "Ready"
        case .woven: "Seated"
        }
    }

    static func heroWord(gallery: Gallery, picked: String?) -> String {
        if let picked, !picked.isEmpty {
            return picked
        }
        if let word = gallery.qualifyingLemmas().first?.word, !word.isEmpty {
            return word
        }
        return "Your word"
    }
}
