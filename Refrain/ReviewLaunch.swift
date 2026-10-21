import Foundation
#if os(iOS)
import UIKit
#endif

/// Live screenshot driver: `-ReviewScreen today|log|goals` (plus extra cover keys).
/// Read `ReviewLaunch.screen` once, after onboarding is done, and open that
/// screen. Keep this file; the navigation it drives belongs to the app.
enum ReviewLaunch {
    static let argument = "-ReviewScreen"

    /// The key after `-ReviewScreen`, or nil on a normal launch.
    static var screen: String? {
        screen(in: ProcessInfo.processInfo.arguments)
    }

    static func screen(in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: argument), index + 1 < arguments.count else {
            return nil
        }
        let value = arguments[index + 1]
        guard !value.hasPrefix("-") else { return nil }
        return value
    }

    /// Cover launches pass `-ReviewScreen`. Freeze UIKit transitions so the
    /// screenshot is the destination, not a mid-animation. No-op on watchOS.
    static func disableAnimationsIfNeeded() {
        #if os(iOS)
        if ProcessInfo.processInfo.arguments.contains(argument) {
            MainActor.assumeIsolated {
                UIView.setAnimationsEnabled(false)
            }
        }
        #endif
    }
}
