import SwiftUI

/// Settings. Contact, reset, and a second pass through onboarding.
struct SettingsView: View {
    @Bindable var board: GalleryBoard
    var close: () -> Void
    var rerunOnboarding: () -> Void

    @State private var confirmReset = false

    private var summary: String {
        let books = Figures.integer(board.gallery.volumes.count)
        let lines = Figures.integer(board.gallery.slips.count)
        let seated = Figures.integer(board.gallery.weaveMarks.count)
        return "\(books) books, \(lines) lines, \(seated) days seated."
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.x3) {
                    if board.gallery.volumes.isEmpty && board.gallery.slips.isEmpty {
                        Text("Nothing stored yet.")
                            .font(TypeScale.title.font())
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text(summary)
                            .font(TypeScale.title.font())
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let notice = board.notice {
                        NoticeBanner(message: notice) {
                            Task { await board.reload() }
                        }
                    }
                    VStack(alignment: .leading, spacing: Space.x1) {
                        Text("Export")
                            .font(TypeScale.caption.font())
                            .foregroundStyle(DesignTokens.muted)
                        Text(summary)
                            .font(TypeScale.body.font())
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        ShareLink(item: summary) {
                            Label("Share summary", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity, minHeight: Space.hit)
                        }
                        .buttonStyle(ActionStripButtonStyle(kind: .quiet))
                    }
                    .padding(Space.x2)
                    .lifted(Radius.card)
                    if let url = URL(string: "https://refrain-triptych.pro/contact-us") {
                        Link(destination: url) {
                            Label("Contact", systemImage: "envelope")
                                .frame(maxWidth: .infinity, minHeight: Space.hit)
                        }
                        .buttonStyle(ActionStripButtonStyle(kind: .primary))
                    }
                    Button("Show intro again", action: rerunOnboarding)
                        .buttonStyle(ActionStripButtonStyle(kind: .quiet))
                    Button("Delete library") { confirmReset = true }
                        .buttonStyle(ActionStripButtonStyle(kind: .destructive))
                }
                .padding(Space.x3)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: close) {
                        Image(systemName: "xmark")
                            .frame(width: Space.hit, height: Space.hit)
                    }
                    .accessibilityLabel("Close")
                }
            }
            .screenBackground()
            .confirmationDialog("Delete the library?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Delete library", role: .destructive) {
                    Task { await board.resetAllData() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Books and lines are removed from this device.")
            }
        }
        .modifier(SheetEntrance())
    }
}
