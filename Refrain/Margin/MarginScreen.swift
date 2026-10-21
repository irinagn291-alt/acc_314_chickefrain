import SwiftUI

/// Every saved line. Long-press or Word writes the normalized word.
struct MarginScreen: View {
    @Bindable var board: GalleryBoard
    var day: DayKey
    var close: () -> Void

    @State private var editing: SlipID?
    @State private var draft = ""

    var body: some View {
        NavigationStack {
            Group {
                if board.gallery.slips.isEmpty {
                    empty
                } else {
                    list
                }
            }
            .navigationTitle("Lines")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { closeButton }
            .screenBackground()
        }
        .modifier(SheetEntrance())
        .sheet(item: $editing) { slipID in
            wordSheet(slipID)
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

    private var empty: some View {
        VStack(alignment: .leading, spacing: Space.x3) {
            Image("rfr_EmptyTriptychCutout")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: Space.x10 * 3)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            Text("No lines yet.")
                .font(TypeScale.title.font())
                .foregroundStyle(DesignTokens.ink)
            Text("Add a line, then save one word on it.")
                .font(TypeScale.body.font())
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(Space.x3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.x2) {
                ForEach(board.gallery.slips) { slip in
                    VStack(alignment: .leading, spacing: Space.x1) {
                        Text(slip.text)
                            .font(TypeScale.body.font())
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(alignment: .firstTextBaseline, spacing: Space.x2) {
                            Text(board.gallery.volume(slip.volumeID)?.title ?? "Book")
                                .font(TypeScale.caption.font())
                                .foregroundStyle(DesignTokens.muted)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Spacer(minLength: Space.x2)
                            if let page = slip.page {
                                Text(Figures.integer(page))
                                    .font(TypeScale.label.font())
                                    .foregroundStyle(DesignTokens.ink)
                                    .monospacedDigit()
                            }
                        }
                        Button(slip.lemma?.word ?? "Save word") {
                            draft = slip.lemma?.word ?? ""
                            editing = slip.id
                        }
                        .buttonStyle(ActionStripButtonStyle(kind: slip.lemma == nil ? .primary : .quiet))
                    }
                    .padding(Space.x2)
                    .lifted(Radius.card)
                    .contextMenu {
                        Button("Save word") {
                            draft = slip.lemma?.word ?? ""
                            editing = slip.id
                        }
                    }
                }
            }
            .padding(Space.x3)
        }
    }

    private func wordSheet(_ slipID: SlipID) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Space.x3) {
                TextField("Word", text: $draft)
                    .textInputAutocapitalization(.never)
                    .font(TypeScale.body.font())
                    .foregroundStyle(DesignTokens.ink)
                    .padding(Space.x2)
                    .frame(minHeight: Space.hit)
                    .lifted(Radius.chip)
                Text("One word. Extra spaces are dropped.")
                    .font(TypeScale.caption.font())
                    .foregroundStyle(DesignTokens.muted)
                Button("Save word") {
                    let ok = board.gallery.slip(slipID) != nil
                    if ok {
                        board.thread(slipID: slipID, rawLemma: draft, on: day)
                        if board.gallery.slip(slipID)?.lemma != nil {
                            CommitHaptic.fire()
                            editing = nil
                        }
                    }
                }
                .buttonStyle(ActionStripButtonStyle(kind: .primary, enabled: !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer(minLength: 0)
            }
            .padding(Space.x3)
            .navigationTitle("Word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { editing = nil }
                        .frame(minHeight: Space.hit)
                }
            }
            .screenBackground()
        }
        .presentationDetents([.medium])
        .presentationBackground(DesignTokens.bg)
    }
}

extension SlipID: Identifiable {
    var id: String { rawValue }
}
