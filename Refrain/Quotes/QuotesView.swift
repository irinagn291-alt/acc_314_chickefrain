import SwiftUI

/// Quotes home. The word, the three lines, and the next tap stay on screen.
struct QuotesView: View {
    @Bindable var board: GalleryBoard
    var day: DayKey
    var redacted: Bool
    @Binding var focusWord: String?
    var open: (CoverDestination) -> Void

    @State private var weaving = false

    private var gallery: Gallery { board.gallery }
    private var phase: TriptychPhase { gallery.phase(on: day) }
    private var words: [String] {
        var seen: [String] = []
        for slip in gallery.slips {
            guard let word = slip.lemma?.word, !seen.contains(word) else { continue }
            seen.append(word)
        }
        return seen
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.x2) {
                    Text(GalleryReading.status(gallery: gallery, day: day, last: board.lastWeave))
                        .font(TypeScale.body.font())
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(Figures.daykey(day.raw))
                        .font(TypeScale.label.font())
                        .foregroundStyle(DesignTokens.muted)
                    Text(GalleryReading.heroWord(gallery: gallery, picked: focusWord))
                        .font(TypeScale.display.font())
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)
                    wordRail
                    Text(seatHeading)
                        .font(TypeScale.headline.font())
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    WeaveBoard(seats: seats) { raw in
                        open(.thread(raw))
                    }
                    weaveButton
                    destinationGrid
                    statRow
                    if let notice = board.notice {
                        NoticeBanner(message: notice) {
                            Task { await board.reload() }
                        }
                    }
                }
                .padding(.horizontal, Space.x3)
                .padding(.top, Space.x2)
                .padding(.bottom, Space.x4)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Quotes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .screenBackground()
        }
        .redacted(reason: redacted ? .placeholder : [])
        .onAppear { alignPick() }
        .onChange(of: gallery.slips) { _, _ in alignPick() }
    }

    private var seatHeading: String {
        if phase == .woven {
            return "Seated from three books"
        }
        if seats.count >= 3 {
            return "Three lines from three books"
        }
        if seats.isEmpty {
            return "No lines for this word yet"
        }
        return "Lines saved for this word"
    }

    private var seats: [WeaveBoard.Seat] {
        let slips = seatedSlips
        return slips.map { slip in
            WeaveBoard.Seat(
                id: slip.id.rawValue,
                book: gallery.volume(slip.volumeID)?.title ?? "Book",
                line: slip.text
            )
        }
    }

    private var seatedSlips: [Slip] {
        let triptych = gallery.triptych(on: day)
        let seated = [triptych.left.slipID, triptych.center.slipID, triptych.right.slipID]
            .compactMap { $0 }
            .compactMap { gallery.slip($0) }
        if !seated.isEmpty {
            return seated
        }
        guard let word = focusWord, let lemma = Lemma.normalize(word) else { return [] }
        let ready = gallery.lines(for: lemma)
        if ready.count >= 3 {
            return Array(ready.prefix(3))
        }
        return gallery.slips.filter { $0.lemma?.word == lemma.word }
    }

    private var wordRail: some View {
        VStack(alignment: .leading, spacing: Space.x1) {
            Text(words.isEmpty ? "No shared word yet." : "Words on your lines")
                .font(TypeScale.label.font())
                .foregroundStyle(DesignTokens.muted)
            if words.isEmpty {
                Text("Save a word on a line to light Weave.")
                    .font(TypeScale.body.font())
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Space.x1) {
                        ForEach(words, id: \.self) { word in
                            let live = gallery.qualifyingLemmas().contains(Lemma(word: word))
                            Button {
                                focusWord = word
                            } label: {
                                HStack(spacing: Space.x1) {
                                    if live {
                                        Image(systemName: "circle.fill")
                                            .font(TypeScale.caption.font())
                                            .foregroundStyle(DesignTokens.accent)
                                            .accessibilityHidden(true)
                                    }
                                    Text(word)
                                        .font(TypeScale.label.font())
                                        .foregroundStyle(DesignTokens.ink)
                                }
                                .padding(.horizontal, Space.x2)
                                .frame(minHeight: Space.hit)
                                .lifted(Radius.chip)
                                .overlay {
                                    RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                                        .strokeBorder(live ? DesignTokens.accent : DesignTokens.muted.opacity(0.4), lineWidth: live ? 2 : 1)
                                }
                            }
                            .buttonStyle(PressPlainStyle())
                            .accessibilityLabel(live ? "\(word), ready to weave" : word)
                            .accessibilityAddTraits(focusWord == word ? .isSelected : [])
                        }
                    }
                }
            }
        }
    }

    private var statRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: Space.x3) {
            VStack(alignment: .leading, spacing: Space.x1) {
                Text(Figures.integer(gallery.slips.count))
                    .font(TypeScale.title.font())
                    .foregroundStyle(DesignTokens.ink)
                    .monospacedDigit()
                Text("Lines saved")
                    .font(TypeScale.label.font())
                    .foregroundStyle(DesignTokens.muted)
            }
            Spacer(minLength: Space.x2)
            VStack(alignment: .trailing, spacing: Space.x1) {
                Text(bookCountLabel)
                    .font(TypeScale.label.font())
                    .foregroundStyle(DesignTokens.ink)
                    .monospacedDigit()
                Text(readyCountLabel)
                    .font(TypeScale.label.font())
                    .foregroundStyle(DesignTokens.muted)
                    .monospacedDigit()
            }
        }
        .padding(Space.x2)
        .lifted(Radius.card)
    }

    private var bookCountLabel: String {
        Figures.integer(gallery.volumes.count) + " books"
    }

    private var readyCountLabel: String {
        let count = gallery.qualifyingLemmas().count
        let noun = count == 1 ? "word ready" : "words ready"
        return Figures.integer(count) + " " + noun
    }

    private var weaveButton: some View {
        Button(action: weave) {
            HStack(spacing: Space.x2) {
                RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                    .fill(phase == .woven ? DesignTokens.muted : DesignTokens.accent)
                    .frame(width: Space.x1, height: Space.x3)
                    .accessibilityHidden(true)
                Text("Weave")
                Spacer(minLength: Space.x1)
            }
        }
        .buttonStyle(ActionStripButtonStyle(kind: .primary, enabled: phase != .woven && !weaving))
        .disabled(phase == .woven || weaving)
    }

    private var destinationGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: Space.x1),
                GridItem(.flexible(), spacing: Space.x1)
            ],
            spacing: Space.x1
        ) {
            strip("Reopen", enabled: phase == .woven) { reopen() }
            strip("Add line", enabled: true) { open(.capture) }
            strip("Shelf", enabled: true) { open(.shelf) }
            strip("Days", enabled: true) { open(.fold) }
            strip("Counts", enabled: true) { open(.dashboard) }
            strip("Settings", enabled: true) { open(.settings) }
        }
    }

    private func strip(_ title: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .buttonStyle(ActionStripButtonStyle(kind: .quiet, enabled: enabled, expands: true))
            .disabled(!enabled)
    }

    private func weave() {
        guard !weaving, phase != .woven else { return }
        weaving = true
        let before = gallery.weaveMarks.count
        let lemma = focusWord.flatMap { Lemma.normalize($0) }
        board.weave(on: day, lemma: lemma)
        if board.gallery.weaveMarks.count > before {
            CommitHaptic.fire()
        }
        weaving = false
    }

    private func reopen() {
        guard phase == .woven else { return }
        board.peel(on: day)
        CommitHaptic.fire()
    }

    private func alignPick() {
        let ready = gallery.qualifyingLemmas().map(\.word)
        if let focusWord, ready.contains(focusWord) || words.contains(focusWord) {
            return
        }
        focusWord = ready.first ?? words.first
    }
}

struct NoticeBanner: View {
    var message: String
    var retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x2) {
            Text("Library failed to load.")
                .font(TypeScale.headline.font())
                .foregroundStyle(DesignTokens.ink)
            Text(message)
                .font(TypeScale.body.font())
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Button("Retry", action: retry)
                .buttonStyle(ActionStripButtonStyle(kind: .primary))
        }
        .padding(Space.x2)
        .lifted(Radius.card)
    }
}
