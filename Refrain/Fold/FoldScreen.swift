import SwiftUI

/// Day fold. Each day shows the lines that are ready or already seated.
struct FoldScreen: View {
    @Bindable var board: GalleryBoard
    var day: DayKey
    var close: () -> Void

    @State private var opened: DayKey?

    private var days: [Triptych] {
        board.gallery.fold().filter { $0.daykey.raw > 0 }
    }

    var body: some View {
        NavigationStack {
            Group {
                if board.gallery.isEmpty {
                    empty
                } else if let notice = board.notice, days.isEmpty {
                    error(notice)
                } else {
                    list
                }
            }
            .navigationTitle("Days")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { closeButton }
            .screenBackground()
        }
        .modifier(SheetEntrance())
        .onAppear {
            if opened == nil {
                opened = days.first(where: { $0.daykey == day })?.daykey ?? days.first?.daykey
            }
        }
    }

    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: close) {
                Image(systemName: "xmark")
                    .frame(width: Space.hit, height: Space.hit)
            }
            .accessibilityLabel("Close")
        }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.x3) {
                Text(Figures.daykey(day.raw))
                    .font(TypeScale.title.font())
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("A ready day has the same word on three books. A seated day keeps those three lines. Tap a day to read them.")
                    .font(TypeScale.body.font())
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(days, id: \.daykey) { item in
                    dayCard(item)
                }
            }
            .padding(Space.x3)
        }
    }

    private func dayCard(_ item: Triptych) -> some View {
        let expanded = opened == item.daykey
        let lines = lines(for: item)
        return VStack(alignment: .leading, spacing: Space.x2) {
            Button {
                opened = expanded ? nil : item.daykey
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: Space.x2) {
                    VStack(alignment: .leading, spacing: Space.x1) {
                        Text(Figures.daykey(item.daykey.raw))
                            .font(TypeScale.headline.font())
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(expanded ? "Hide lines" : "Show lines")
                            .font(TypeScale.label.font())
                            .foregroundStyle(DesignTokens.accent)
                    }
                    Spacer(minLength: Space.x2)
                    Text(GalleryReading.phaseTitle(item.phase))
                        .font(TypeScale.label.font())
                        .foregroundStyle(item.phase == .woven ? DesignTokens.accent : DesignTokens.ink)
                        .padding(.horizontal, Space.x2)
                        .frame(minHeight: Space.hit)
                        .lifted(Radius.chip)
                }
                .frame(maxWidth: .infinity, minHeight: Space.hit, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressPlainStyle())
            if expanded {
                Text(detail(for: item.phase))
                    .font(TypeScale.body.font())
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
                if lines.isEmpty {
                    Text("No lines saved for this day yet.")
                        .font(TypeScale.body.font())
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ForEach(lines) { slip in
                        VStack(alignment: .leading, spacing: Space.x1) {
                            Text(board.gallery.volume(slip.volumeID)?.title ?? "Book")
                                .font(TypeScale.label.font())
                                .foregroundStyle(DesignTokens.muted)
                                .lineLimit(1)
                            Text(slip.text)
                                .font(TypeScale.body.font())
                                .foregroundStyle(DesignTokens.ink)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(Space.x2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                                .fill(DesignTokens.bg)
                        }
                    }
                }
                if item.phase == .spooled {
                    Button("Weave this day") {
                        board.weave(on: item.daykey)
                    }
                    .buttonStyle(ActionStripButtonStyle(kind: .primary))
                } else if item.phase == .woven {
                    Button("Reopen this day") {
                        board.peel(on: item.daykey)
                    }
                    .buttonStyle(ActionStripButtonStyle(kind: .quiet))
                }
            }
        }
        .padding(Space.x2)
        .lifted(Radius.card)
    }

    private func lines(for item: Triptych) -> [Slip] {
        let seated = [item.left.slipID, item.center.slipID, item.right.slipID]
            .compactMap { $0 }
            .compactMap { board.gallery.slip($0) }
        if !seated.isEmpty {
            return seated
        }
        guard let lemma = board.gallery.qualifyingLemmas().first else { return [] }
        return Array(board.gallery.lines(for: lemma).prefix(3))
    }

    private func detail(for phase: TriptychPhase) -> String {
        switch phase {
        case .blank:
            "This day has no books yet."
        case .idle:
            "Waiting for one word on three books."
        case .spooled:
            "Ready to seat. These lines share one word."
        case .woven:
            "Seated. These are the three lines kept for the day."
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: Space.x3) {
            Image("rfr_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: Space.x10 * 3)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            Text("No days yet.")
                .font(TypeScale.title.font())
                .foregroundStyle(DesignTokens.ink)
            Text("Weave a day and the three lines land here.")
                .font(TypeScale.body.font())
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(Space.x3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func error(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: Space.x3) {
            Text("Days failed to load.")
                .font(TypeScale.title.font())
                .foregroundStyle(DesignTokens.ink)
            Text(message)
                .font(TypeScale.body.font())
                .foregroundStyle(DesignTokens.muted)
            Button("Retry") { Task { await board.reload() } }
                .buttonStyle(ActionStripButtonStyle(kind: .primary))
            Spacer(minLength: 0)
        }
        .padding(Space.x3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
