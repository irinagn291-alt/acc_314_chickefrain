import Foundation
#if os(iOS)
import UIKit
#endif

/// One commit haptic. Navigation does not call this.
@MainActor
enum CommitHaptic {
    static func fire() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }
}
