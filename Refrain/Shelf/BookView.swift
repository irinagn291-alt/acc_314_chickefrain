import SwiftUI

/// One book. Progress, reread or once, and the lines that stay if it goes.
struct BookView: View {
    @Bindable var board: GalleryBoard
    var volumeID: VolumeID

    @State private var confirmGone = false

    private var volume: Volume? { board.gallery.volume(volumeID) }

    var body: some View {
        Group {
            if let volume {
                filled(volume)
            } else {
                missing
            }
        }
        .navigationTitle("Book")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .screenBackground()
        .confirmationDialog("Mark this book gone?", isPresented: $confirmGone, titleVisibility: .visible) {
            Button("Mark gone", role: .destructive) {
                board.hollow(volumeID)
                CommitHaptic.fire()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This book leaves the held shelf. Lines stay and can still be woven.")
        }
    }

    private func filled(_ volume: Volume) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.x3) {
                Text(progressText(volume))
                    .font(TypeScale.display.font())
                    .foregroundStyle(DesignTokens.accent)
                    .monospacedDigit()
                    .fixedSize(horizontal: false, vertical: true)
                Text(volume.title)
                    .font(TypeScale.title.font())
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(volume.author)
                    .font(TypeScale.body.font())
                    .foregroundStyle(DesignTokens.muted)
                    .lineLimit(1)
                    .truncationMode(.tail)
                HStack(spacing: Space.x1) {
                    verdictButton("Reread", selected: volume.verdict == .reread) {
                        board.setVerdict(.reread, volumeID: volume.id)
                        CommitHaptic.fire()
                    }
                    verdictButton("Once", selected: volume.verdict == .not) {
                        board.setVerdict(.not, volumeID: volume.id)
                        CommitHaptic.fire()
                    }
                }
                pageControls(volume)
                if volume.spine == .held {
                    Button("Mark gone") { confirmGone = true }
                        .buttonStyle(ActionStripButtonStyle(kind: .destructive))
                } else {
                    Text("Gone. Lines remain.")
                        .font(TypeScale.body.font())
                        .foregroundStyle(DesignTokens.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Space.x2)
                        .lifted(Radius.card)
                }
                Text("Lines")
                    .font(TypeScale.headline.font())
                    .foregroundStyle(DesignTokens.ink)
                let lines = board.gallery.quoteStore(for: volume.id)
                if lines.isEmpty {
                    Text("No lines in this book yet.")
                        .font(TypeScale.body.font())
                        .foregroundStyle(DesignTokens.muted)
                } else {
                    ForEach(lines) { slip in
                        VStack(alignment: .leading, spacing: Space.x1) {
                            Text(slip.text)
                                .font(TypeScale.body.font())
                                .foregroundStyle(DesignTokens.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            HStack {
                                Text(slip.lemma?.word ?? "No word")
                                    .font(TypeScale.caption.font())
                                    .foregroundStyle(DesignTokens.muted)
                                Spacer(minLength: Space.x2)
                                if let page = slip.page {
                                    Text(Figures.integer(page))
                                        .font(TypeScale.label.font())
                                        .foregroundStyle(DesignTokens.ink)
                                        .monospacedDigit()
                                }
                            }
                        }
                        .padding(Space.x2)
                        .lifted(Radius.card)
                    }
                }
            }
            .padding(Space.x3)
        }
    }

    private var missing: some View {
        VStack(alignment: .leading, spacing: Space.x2) {
            Text("That book is not on the shelf.")
                .font(TypeScale.title.font())
                .foregroundStyle(DesignTokens.ink)
            Text("It may have been removed.")
                .font(TypeScale.body.font())
                .foregroundStyle(DesignTokens.muted)
        }
        .padding(Space.x3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func progressText(_ volume: Volume) -> String {
        guard let fraction = volume.progressFraction else { return "unknown" }
        return Figures.percent(fraction)
    }

    private func verdictButton(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Space.x1) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .accessibilityHidden(true)
                Text(title)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ActionStripButtonStyle(kind: selected ? .primary : .quiet))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func pageControls(_ volume: Volume) -> some View {
        HStack(spacing: Space.x2) {
            Button {
                shift(volume, delta: -1)
            } label: {
                Image(systemName: "minus")
                    .frame(width: Space.hit, height: Space.hit)
            }
            .buttonStyle(ActionStripButtonStyle(kind: .quiet))
            .accessibilityLabel("Previous page")
            VStack(alignment: .leading, spacing: Space.x1) {
                Text(Figures.integer(volume.currentPage))
                    .font(TypeScale.headline.font())
                    .foregroundStyle(DesignTokens.ink)
                    .monospacedDigit()
                Text("of " + Figures.integer(volume.totalPages))
                    .font(TypeScale.caption.font())
                    .foregroundStyle(DesignTokens.muted)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                shift(volume, delta: 1)
            } label: {
                Image(systemName: "plus")
                    .frame(width: Space.hit, height: Space.hit)
            }
            .buttonStyle(ActionStripButtonStyle(kind: .quiet))
            .accessibilityLabel("Next page")
        }
        .padding(Space.x2)
        .lifted(Radius.card)
    }

    private func shift(_ volume: Volume, delta: Int) {
        let next = max(0, volume.currentPage + delta)
        let capped = volume.totalPages > 0 ? min(next, volume.totalPages) : next
        board.setPages(current: capped, total: volume.totalPages, volumeID: volume.id)
        CommitHaptic.fire()
    }
}
