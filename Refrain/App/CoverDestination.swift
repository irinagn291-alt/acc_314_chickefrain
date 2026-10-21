import Foundation

/// Value route for sheets over the locked quotes canvas.
enum CoverDestination: Identifiable, Equatable {
    case shelf
    case dashboard
    case settings
    case margin
    case fold
    case capture
    case thread(String?)
    case book(String?)

    var id: String {
        switch self {
        case .shelf:
            "shelf"
        case .dashboard:
            "dashboard"
        case .settings:
            "settings"
        case .margin:
            "margin"
        case .fold:
            "fold"
        case .capture:
            "capture"
        case .thread(let raw):
            "thread-\(raw ?? "all")"
        case .book(let raw):
            "book-\(raw ?? "first")"
        }
    }
}

enum OnboardingGate {
    static let storageKey = "rfr.onboarding.v1"

    static var isComplete: Bool {
        UserDefaults.standard.bool(forKey: storageKey)
    }

    static func complete() {
        UserDefaults.standard.set(true, forKey: storageKey)
    }

    static func reopen() {
        UserDefaults.standard.set(false, forKey: storageKey)
    }
}
