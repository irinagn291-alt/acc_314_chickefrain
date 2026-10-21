import SwiftUI

/// Primary strip control. Press scales to 0.97. Reduce Motion fades only.
struct ActionStripButtonStyle: ButtonStyle {
    enum Kind {
        case primary
        case quiet
        case destructive
    }

    var kind: Kind = .primary
    var enabled: Bool = true
    var expands: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && enabled
        configuration.label
            .font(TypeScale.label.font())
            .foregroundStyle(foreground)
            .frame(maxWidth: expands ? .infinity : nil, minHeight: Space.hit)
            .padding(.horizontal, Space.x2)
            .contentShape(Rectangle())
            .background {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(fill)
                    .shadow(color: Elevation.color, radius: Elevation.blur, x: 0, y: Elevation.y)
            }
            .overlay {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(border, lineWidth: kind == .primary ? 2 : 1)
            }
            .opacity(opacity(pressed: pressed))
            .scaleEffect(scale(pressed: pressed))
            .animation(Motion.press, value: pressed)
    }

    private var corner: CGFloat {
        kind == .quiet ? Radius.chip : Radius.card
    }

    private var fill: Color {
        switch kind {
        case .primary:
            DesignTokens.surface
        case .quiet:
            DesignTokens.surface
        case .destructive:
            DesignTokens.bg
        }
    }

    private var foreground: Color {
        enabled ? DesignTokens.ink : DesignTokens.muted
    }

    private var border: Color {
        guard enabled else { return DesignTokens.muted.opacity(0.45) }
        switch kind {
        case .primary:
            return DesignTokens.accent
        case .quiet:
            return DesignTokens.muted.opacity(0.55)
        case .destructive:
            return DesignTokens.muted
        }
    }

    private func opacity(pressed: Bool) -> Double {
        if !enabled { return 0.45 }
        if pressed { return 0.72 }
        return 1
    }

    private func scale(pressed: Bool) -> CGFloat {
        if reduceMotion || !enabled { return 1 }
        return pressed ? Motion.pressScale : 1
    }
}

/// Press feedback for a row that already draws its own plate.
struct PressPlainStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? Motion.pressScale : 1))
            .animation(Motion.press, value: configuration.isPressed)
    }
}
