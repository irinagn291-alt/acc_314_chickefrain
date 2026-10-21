import SwiftUI

/// Tokens for space, type, radius, and motion. Views read these, not raw numbers.
enum Space {
    static let unit: CGFloat = 8
    static let x1: CGFloat = 8
    static let x2: CGFloat = 16
    static let x3: CGFloat = 24
    static let x4: CGFloat = 32
    static let x5: CGFloat = 40
    static let x6: CGFloat = 48
    static let x8: CGFloat = 64
    static let x10: CGFloat = 80
    static let hit: CGFloat = 44
}

enum Radius {
    static let card: CGFloat = 18
    static let chip: CGFloat = 8
}

enum Elevation {
    static let color = DesignTokens.ink.opacity(0.2)
    static let blur: CGFloat = 8
    static let y: CGFloat = 8
}

enum Motion {
    static let pressScale: CGFloat = 0.97
    static let sheetScale: CGFloat = 0.96
    static let press = Animation.easeOut(duration: 0.16)
    static let sheet = Animation.easeOut(duration: 0.28)
}

enum TypeScale {
    case display
    case title
    case headline
    case body
    case label
    case caption

    func font() -> Font {
        switch self {
        case .display:
            Font.custom(DesignTokens.fontFamily, size: 44, relativeTo: .largeTitle)
        case .title:
            Font.custom(DesignTokens.fontFamily, size: 28, relativeTo: .title)
        case .headline:
            Font.custom(DesignTokens.fontFamily, size: 22, relativeTo: .title2)
        case .body:
            Font.custom(DesignTokens.fontFamily, size: 17, relativeTo: .body)
        case .label:
            Font.custom(DesignTokens.fontFamily, size: 14, relativeTo: .subheadline)
        case .caption:
            Font.custom(DesignTokens.fontFamily, size: 12, relativeTo: .caption)
        }
    }
}

enum Figures {
    static func integer(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "unknown"
    }

    static func daykey(_ raw: Int) -> String {
        var parts = DateComponents()
        parts.calendar = Calendar(identifier: .gregorian)
        parts.year = raw / 10_000
        parts.month = (raw / 100) % 100
        parts.day = raw % 100
        guard let date = parts.date else { return "unknown" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }

    static func percent(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "unknown"
    }
}

extension View {
    func lifted(_ radius: CGFloat) -> some View {
        background {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(DesignTokens.surface)
                .shadow(color: Elevation.color, radius: Elevation.blur, x: 0, y: Elevation.y)
        }
    }

    func screenBackground() -> some View {
        background(DesignTokens.bg.ignoresSafeArea())
    }
}

/// Sheet entry. Cover launches skip the fade so the frame is already settled.
struct SheetEntrance: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = ReviewLaunch.screen != nil

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .scaleEffect(reduceMotion || ReviewLaunch.screen != nil ? 1 : (shown ? 1 : Motion.sheetScale))
            .onAppear {
                guard ReviewLaunch.screen == nil else {
                    shown = true
                    return
                }
                if reduceMotion {
                    withAnimation(.easeOut(duration: 0.2)) { shown = true }
                } else {
                    withAnimation(Motion.sheet) { shown = true }
                }
            }
    }
}
