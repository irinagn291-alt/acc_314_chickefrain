import SwiftUI

/// Counts for saved words. Each word opens the lines that carry it.
struct DashboardReadout: Equatable {
    struct Bar: Identifiable, Equatable {
        var word: String
        var count: Int
        var id: String { word }
    }

    var topWord: String
    var topCount: Int
    var streak: Int
    var bars: [Bar]

    init(gallery: Gallery, today: DayKey) {
        var counts: [String: Int] = [:]
        for slip in gallery.slips {
            guard let word = slip.lemma?.word else { continue }
            counts[word, default: 0] += 1
        }
        let ordered = counts.sorted { lhs, rhs in
            if lhs.value == rhs.value { return lhs.key < rhs.key }
            return lhs.value > rhs.value
        }
        bars = ordered.prefix(6).map { Bar(word: $0.key, count: $0.value) }
        topWord = bars.first?.word ?? ""
        topCount = bars.first?.count ?? 0
        streak = Self.streak(in: gallery, ending: today)
    }

    private static func streak(in gallery: Gallery, ending today: DayKey) -> Int {
        let woven = Set(gallery.weaveMarks.map(\.daykey))
        let calendar = Calendar.current
        var cursor: DayKey? = woven.contains(today) ? today : previous(today, calendar: calendar)
        guard let start = cursor, woven.contains(start) else { return 0 }
        cursor = start
        var count = 0
        while let day = cursor, woven.contains(day) {
            count += 1
            cursor = previous(day, calendar: calendar)
        }
        return count
    }

    private static func previous(_ day: DayKey, calendar: Calendar) -> DayKey? {
        let raw = day.raw
        var parts = DateComponents()
        parts.year = raw / 10_000
        parts.month = (raw / 100) % 100
        parts.day = raw % 100
        guard let date = calendar.date(from: parts),
              let prior = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: date))
        else { return nil }
        return DayKey.make(from: prior, calendar: calendar)
    }
}

struct DashboardView: View {
    @Bindable var board: GalleryBoard
    var day: DayKey
    var close: () -> Void
    var onUse: (String) -> Void

    @State private var selected: String?

    private var readout: DashboardReadout {
        DashboardReadout(gallery: board.gallery, today: day)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let notice = board.notice, board.gallery.slips.isEmpty {
                    error(notice)
                } else if readout.bars.isEmpty {
                    empty
                } else {
                    filled
                }
            }
            .navigationTitle("Counts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { closeButton }
            .screenBackground()
        }
        .modifier(SheetEntrance())
        .onAppear {
            if selected == nil {
                selected = readout.topWord
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

    private var filled: some View {
        let active = selected ?? readout.topWord
        let peak = max(readout.bars.map(\.count).max() ?? 1, 1)
        return ScrollView {
            VStack(alignment: .leading, spacing: Space.x3) {
                Text("Tap a word to read its lines")
                    .font(TypeScale.title.font())
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(Figures.integer(readout.streak) + " days seated in a row")
                    .font(TypeScale.label.font())
                    .foregroundStyle(DesignTokens.muted)
                ForEach(readout.bars) { bar in
                    wordRow(bar, peak: peak, active: active)
                }
                Button("Use \(active) on Quotes") {
                    onUse(active)
                }
                .buttonStyle(ActionStripButtonStyle(kind: .primary))
                .disabled(active.isEmpty)
            }
            .padding(Space.x3)
        }
    }

    private func wordRow(_ bar: DashboardReadout.Bar, peak: Int, active: String) -> some View {
        let open = active == bar.word
        let lines = board.gallery.slips.filter { $0.lemma?.word == bar.word }
        let fraction = CGFloat(bar.count) / CGFloat(peak)
        return Button {
            selected = bar.word
        } label: {
            VStack(alignment: .leading, spacing: Space.x2) {
                HStack(alignment: .firstTextBaseline, spacing: Space.x2) {
                    Text(bar.word)
                        .font(TypeScale.headline.font())
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(1)
                    Spacer(minLength: Space.x2)
                    Text(Figures.integer(bar.count) + " lines")
                        .font(TypeScale.label.font())
                        .foregroundStyle(DesignTokens.ink)
                        .monospacedDigit()
                }
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                        .fill(DesignTokens.accent)
                        .frame(width: max(Space.x2, proxy.size.width * fraction), height: Space.x2)
                }
                .frame(height: Space.x2)
                .accessibilityHidden(true)
                if open {
                    ForEach(lines) { slip in
                        VStack(alignment: .leading, spacing: Space.x1) {
                            Text(board.gallery.volume(slip.volumeID)?.title ?? "Book")
                                .font(TypeScale.label.font())
                                .foregroundStyle(DesignTokens.muted)
                                .lineLimit(1)
                            Text(slip.text)
                                .font(TypeScale.body.font())
                                .foregroundStyle(DesignTokens.ink)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(Space.x2)
            .frame(maxWidth: .infinity, minHeight: Space.hit, alignment: .leading)
            .contentShape(Rectangle())
            .lifted(Radius.card)
            .overlay {
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(open ? DesignTokens.accent : Color.clear, lineWidth: 2)
            }
        }
        .buttonStyle(PressPlainStyle())
        .accessibilityLabel(bar.word + ", " + Figures.integer(bar.count) + " lines")
        .accessibilityAddTraits(open ? .isSelected : [])
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: Space.x3) {
            Image("rfr_TwistHero")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: Space.x10 * 3)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            Text("No words counted yet.")
                .font(TypeScale.title.font())
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Save a word on a line. Counts show up here.")
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
            Text("Counts failed to load.")
                .font(TypeScale.title.font())
                .foregroundStyle(DesignTokens.ink)
            Text(message)
                .font(TypeScale.body.font())
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Button("Retry") {
                Task { await board.reload() }
            }
            .buttonStyle(ActionStripButtonStyle(kind: .primary))
            Spacer(minLength: 0)
        }
        .padding(Space.x3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
