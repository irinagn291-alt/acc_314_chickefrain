import SwiftUI

/// Capture a line into one book's quote store, then optionally save a word.
struct CaptureScreen: View {
    @Bindable var board: GalleryBoard
    var day: DayKey
    var close: () -> Void

    @FocusState private var focus: Field?
    @State private var volumeRaw: String = ""
    @State private var text = ""
    @State private var page = ""
    @State private var word = ""
    @State private var saving = false
    @State private var confirmDiscard = false

    private enum Field: Hashable {
        case text, page, word
    }

    private var volumes: [Volume] { board.gallery.volumes }

    private var pageValue: Int? {
        if page.isEmpty { return nil }
        let digits = page.filter(\.isNumber)
        guard digits == page, let value = Int(digits), value >= 0 else { return nil }
        return value
    }

    private var canSave: Bool {
        !saving
            && volumes.contains(where: { $0.id.rawValue == volumeRaw })
            && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (page.isEmpty || pageValue != nil)
    }

    var body: some View {
        NavigationStack {
            Group {
                if volumes.isEmpty {
                    empty
                } else {
                    form
                }
            }
            .navigationTitle("Add a line")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { closeItem }
            .screenBackground()
        }
        .modifier(SheetEntrance())
        .onAppear {
            if volumeRaw.isEmpty {
                volumeRaw = volumes.first?.id.rawValue ?? ""
            }
        }
    }

    private var closeItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: askClose) {
                Image(systemName: "xmark")
                    .frame(width: Space.hit, height: Space.hit)
            }
            .accessibilityLabel("Close")
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
            Text("Add a book before a line.")
                .font(TypeScale.title.font())
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("A line belongs to one book.")
                .font(TypeScale.body.font())
                .foregroundStyle(DesignTokens.muted)
            Spacer(minLength: 0)
        }
        .padding(Space.x3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.x3) {
                Text("Book")
                    .font(TypeScale.label.font())
                    .foregroundStyle(DesignTokens.muted)
                Picker("Book", selection: $volumeRaw) {
                    ForEach(volumes) { volume in
                        Text(volume.title).tag(volume.id.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, minHeight: Space.hit, alignment: .leading)
                .padding(.horizontal, Space.x2)
                .lifted(Radius.chip)
                labeled("Line", text: $text, field: .text, axis: .vertical)
                VStack(alignment: .leading, spacing: Space.x1) {
                    Text("Page")
                        .font(TypeScale.label.font())
                        .foregroundStyle(DesignTokens.muted)
                    TextField("Optional", text: $page)
                        .keyboardType(.numberPad)
                        .focused($focus, equals: .page)
                        .font(TypeScale.body.font())
                        .foregroundStyle(DesignTokens.ink)
                        .padding(Space.x2)
                        .frame(minHeight: Space.hit)
                        .lifted(Radius.chip)
                        .onChange(of: page) { _, newValue in
                            let digits = newValue.filter(\.isNumber)
                            if digits != newValue { page = digits }
                        }
                }
                labeled("Word", text: $word, field: .word, axis: .horizontal)
                Text("A word is saved on this line. Three books with the same word make Weave live.")
                    .font(TypeScale.caption.font())
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Button(action: save) {
                    Text("Save line")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ActionStripButtonStyle(kind: .primary, enabled: canSave))
                .disabled(!canSave)
            }
            .padding(Space.x3)
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focus = nil }
            }
        }
        .confirmationDialog("Leave without saving?", isPresented: $confirmDiscard, titleVisibility: .visible) {
            Button("Discard", role: .destructive) { close() }
            Button("Keep editing", role: .cancel) {}
        }
        .simultaneousGesture(TapGesture().onEnded { focus = nil })
    }

    private func labeled(_ title: String, text: Binding<String>, field: Field, axis: Axis) -> some View {
        VStack(alignment: .leading, spacing: Space.x1) {
            Text(title)
                .font(TypeScale.label.font())
                .foregroundStyle(DesignTokens.muted)
            TextField(title, text: text, axis: axis)
                .lineLimit(axis == .vertical ? 4...8 : 1...1)
                .focused($focus, equals: field)
                .font(TypeScale.body.font())
                .foregroundStyle(DesignTokens.ink)
                .padding(Space.x2)
                .frame(minHeight: Space.hit)
                .lifted(Radius.chip)
        }
    }

    private func askClose() {
        let typed = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !word.isEmpty || !page.isEmpty
        if typed {
            confirmDiscard = true
        } else {
            close()
        }
    }

    private func save() {
        guard canSave else { return }
        saving = true
        let id = VolumeID(volumeRaw)
        guard let slipID = board.captureSlip(volumeID: id, text: text, page: pageValue) else {
            saving = false
            return
        }
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            board.thread(slipID: slipID, rawLemma: trimmed, on: day)
        }
        CommitHaptic.fire()
        close()
    }
}
