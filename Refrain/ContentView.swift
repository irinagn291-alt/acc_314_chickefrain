import SwiftUI

/// Root frame. Onboarding finishes before `-ReviewScreen` is read.
struct ContentView: View {
    @Bindable var board: GalleryBoard
    @Environment(\.scenePhase) private var scenePhase

    @State private var booted = false
    @State private var onboarded = OnboardingGate.isComplete
    @State private var day = DayKey.make(from: Date())
    @State private var cover: CoverDestination?
    @State private var focusWord: String?
    @State private var didReadLaunch = false

    var body: some View {
        Group {
            if !booted {
                quotes(redacted: true)
            } else if !onboarded {
                OnboardingView {
                    OnboardingGate.complete()
                    onboarded = true
                    readLaunch()
                }
            } else {
                quotes(redacted: false)
                    .sheet(item: $cover) { destination in
                        destinationView(destination)
                    }
            }
        }
        .task { await boot() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            day = DayKey.make(from: Date())
        }
    }

    private func quotes(redacted: Bool) -> some View {
        QuotesView(board: board, day: day, redacted: redacted, focusWord: $focusWord) { destination in
            cover = destination
        }
    }

    @ViewBuilder
    private func destinationView(_ destination: CoverDestination) -> some View {
        switch destination {
        case .shelf:
            ShelfView(board: board) { cover = nil }
        case .dashboard:
            DashboardView(board: board, day: day, close: { cover = nil }) { word in
                focusWord = word
                cover = nil
            }
        case .settings:
            SettingsView(board: board, close: { cover = nil }) {
                cover = nil
                OnboardingGate.reopen()
                onboarded = false
            }
        case .margin:
            MarginScreen(board: board, day: day) { cover = nil }
        case .fold:
            FoldScreen(board: board, day: day) { cover = nil }
        case .capture:
            CaptureScreen(board: board, day: day) { cover = nil }
        case .thread(let raw):
            ThreadScreen(board: board, day: day, slipRaw: raw) { cover = nil }
        case .book(let raw):
            NavigationStack {
                BookView(
                    board: board,
                    volumeID: VolumeID(raw ?? board.gallery.volumes.first?.id.rawValue ?? "")
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: { cover = nil }) {
                            Image(systemName: "xmark")
                                .frame(width: Space.hit, height: Space.hit)
                        }
                        .accessibilityLabel("Close")
                    }
                }
            }
            .modifier(SheetEntrance())
        }
    }

    private func boot() async {
        guard !booted else { return }
        await board.bootstrap()
        #if targetEnvironment(simulator)
        if UserDefaults.standard.bool(forKey: Gallery.demoKey) || !board.gallery.isEmpty {
            OnboardingGate.complete()
            onboarded = true
        }
        #endif
        booted = true
        if onboarded {
            readLaunch()
        }
    }

    /// Once, after onboarding. today stays on Quotes. Other keys open their own screen.
    private func readLaunch() {
        guard !didReadLaunch else { return }
        didReadLaunch = true
        switch ReviewLaunch.screen {
        case "log", "shelf":
            cover = .shelf
        case "goals", "dashboard":
            cover = .dashboard
        case "settings":
            cover = .settings
        case "margin":
            cover = .margin
        case "fold":
            cover = .fold
        case "capture":
            cover = .capture
        case "thread":
            cover = .thread(nil)
        case "book":
            cover = .book(nil)
        default:
            cover = nil
        }
    }
}

#Preview {
    ContentView(board: GalleryBoard(archive: GalleryArchive.live()))
}
