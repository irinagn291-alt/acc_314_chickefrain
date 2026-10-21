import SwiftUI

@main
struct RefrainWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchRoot()
        }
    }
}

/// Apple Watch cover. Same today / log / goals keys as the phone, laid out for the wrist.
struct WatchRoot: View {
    var body: some View {
        switch ReviewLaunch.screen {
        case "log":
            WatchShelf()
        case "goals":
            WatchCounts()
        default:
            WatchToday()
        }
    }
}

private struct WatchToday: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ready")
                .font(.custom(DesignTokens.fontFamily, size: 12, relativeTo: .caption))
                .foregroundStyle(DesignTokens.muted)
            Text("Weave")
                .font(.custom(DesignTokens.fontFamily, size: 28, relativeTo: .title))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Seat three lines from three books.")
                .font(.custom(DesignTokens.fontFamily, size: 14, relativeTo: .body))
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(8)
        .background(DesignTokens.bg.ignoresSafeArea())
    }
}

private struct WatchShelf: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shelf")
                .font(.custom(DesignTokens.fontFamily, size: 22, relativeTo: .title2))
                .foregroundStyle(DesignTokens.ink)
            Text("The Waves")
                .font(.custom(DesignTokens.fontFamily, size: 14, relativeTo: .body))
                .foregroundStyle(DesignTokens.ink)
            Text("Middlemarch")
                .font(.custom(DesignTokens.fontFamily, size: 14, relativeTo: .body))
                .foregroundStyle(DesignTokens.muted)
            Text("The Odyssey")
                .font(.custom(DesignTokens.fontFamily, size: 14, relativeTo: .body))
                .foregroundStyle(DesignTokens.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(8)
        .background(DesignTokens.bg.ignoresSafeArea())
    }
}

private struct WatchCounts: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("threshold")
                .font(.custom(DesignTokens.fontFamily, size: 22, relativeTo: .title2))
                .foregroundStyle(DesignTokens.ink)
            Text("3 lines")
                .font(.custom(DesignTokens.fontFamily, size: 16, relativeTo: .headline))
                .foregroundStyle(DesignTokens.accent)
            Text("Days in a row wait until Weave.")
                .font(.custom(DesignTokens.fontFamily, size: 12, relativeTo: .caption))
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(8)
        .background(DesignTokens.bg.ignoresSafeArea())
    }
}
