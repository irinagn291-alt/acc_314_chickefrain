import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #3B2848
    static let bg = Color(red: 0.231373, green: 0.156863, blue: 0.282353)
    static let bgHex = "#3B2848"
    /// #4A3857
    static let surface = Color(red: 0.290196, green: 0.219608, blue: 0.341176)
    static let surfaceHex = "#4A3857"
    /// #F5F4F6
    static let ink = Color(red: 0.960784, green: 0.956863, blue: 0.964706)
    static let inkHex = "#F5F4F6"
    /// #B270E1
    static let accent = Color(red: 0.698039, green: 0.439216, blue: 0.882353)
    static let accentHex = "#B270E1"
    /// #BEB6C3
    static let muted = Color(red: 0.745098, green: 0.713725, blue: 0.764706)
    static let mutedHex = "#BEB6C3"
    static let fontFamily = "American Typewriter"
}
