import SwiftUI

/// Signature screen. Save a word, then return to Weave on Quotes.
struct ThreadScreen: View {
    @Bindable var board: GalleryBoard
    var day: DayKey
    var slipRaw: String?
    var close: () -> Void

    @State private var draft = ""
    @State private var saving = false
    @FocusState private var focused: Bool

    private var slip: Slip? {
        if let slipRaw, let found = board.gallery.slip(SlipID(slipRaw)) {
            return found
        }
        return board.gallery.slips.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.x3) {
                    Image("rfr_TwistHero")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: Space.x10 * 3)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                    Text("Save a word")
                        .font(TypeScale.display.font())
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Three books that share it make Weave live for today.")
                        .font(TypeScale.body.font())
                        .foregroundStyle(DesignTokens.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    if let slip {
                        Text(slip.text)
                            .font(TypeScale.headline.font())
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(Space.x2)
                            .lifted(Radius.card)
                        TextField("Word", text: $draft)
                            .textInputAutocapitalization(.never)
                            .focused($focused)
                            .font(TypeScale.body.font())
                            .foregroundStyle(DesignTokens.ink)
                            .padding(Space.x2)
                            .frame(minHeight: Space.hit)
                            .lifted(Radius.chip)
                            .onAppear {
                                if draft.isEmpty { draft = slip.lemma?.word ?? "" }
                            }
                        Button(action: save) {
                            Text("Save word")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ActionStripButtonStyle(kind: .primary, enabled: canSave))
                        .disabled(!canSave)
                    } else {
                        Text("Add a line first.")
                            .font(TypeScale.body.font())
                            .foregroundStyle(DesignTokens.ink)
                    }
                }
                .padding(Space.x3)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Word")
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
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = false }
                }
            }
            .screenBackground()
        }
        .modifier(SheetEntrance())
    }

    private var canSave: Bool {
        !saving && slip != nil && !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        guard canSave, let slip else { return }
        saving = true
        board.thread(slipID: slip.id, rawLemma: draft, on: day)
        let saved = board.gallery.slip(slip.id)?.lemma?.word
        if saved == Lemma.normalize(draft)?.word {
            CommitHaptic.fire()
            close()
        } else {
            saving = false
        }
    }
}
