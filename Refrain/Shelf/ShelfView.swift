import SwiftUI

/// Shelf sheet. Spines, progress, and a path to add a book.
struct ShelfView: View {
    @Bindable var board: GalleryBoard
    var close: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if let notice = board.notice, board.gallery.volumes.isEmpty {
                    errorBody(notice)
                } else if board.gallery.volumes.isEmpty {
                    emptyBody
                } else {
                    listBody
                }
            }
            .navigationTitle("Shelf")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { closeButton }
            .screenBackground()
        }
        .modifier(SheetEntrance())
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

    private var emptyBody: some View {
        VStack(alignment: .leading, spacing: Space.x3) {
            Spacer(minLength: Space.x2)
            Image("rfr_EmptyShelfCutout")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: Space.x10 * 3)
                .accessibilityHidden(true)
            Text("The shelf is empty.")
                .font(TypeScale.title.font())
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Set down your first book and leave a line in the margin.")
                .font(TypeScale.body.font())
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Space.x2)
            NavigationLink {
                AddBookForm(board: board)
            } label: {
                Text("Add a book")
                    .frame(maxWidth: .infinity, minHeight: Space.hit)
            }
            .buttonStyle(ActionStripButtonStyle(kind: .primary))
        }
        .padding(Space.x3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var listBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.x3) {
                if let first = board.gallery.volumes.first {
                    NavigationLink {
                        BookView(board: board, volumeID: first.id)
                    } label: {
                        hero(first)
                    }
                    .buttonStyle(PressPlainStyle())
                }
                VStack(spacing: Space.x1) {
                    ForEach(Array(board.gallery.volumes.dropFirst())) { volume in
                        NavigationLink {
                            BookView(board: board, volumeID: volume.id)
                        } label: {
                            compact(volume)
                        }
                        .buttonStyle(PressPlainStyle())
                    }
                }
                NavigationLink {
                    AddBookForm(board: board)
                } label: {
                    Text("Add a book")
                        .frame(maxWidth: .infinity, minHeight: Space.hit)
                }
                .buttonStyle(ActionStripButtonStyle(kind: .primary))
            }
            .padding(Space.x3)
        }
    }

    private func hero(_ volume: Volume) -> some View {
        VStack(alignment: .leading, spacing: Space.x2) {
            HStack(alignment: .firstTextBaseline, spacing: Space.x2) {
                Text(volume.title)
                    .font(TypeScale.title.font())
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(progressLabel(volume))
                    .font(TypeScale.headline.font())
                    .foregroundStyle(DesignTokens.accent)
                    .monospacedDigit()
                    .lineLimit(1)
            }
            Text(volume.author)
                .font(TypeScale.body.font())
                .foregroundStyle(DesignTokens.muted)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(spineLabel(volume))
                .font(TypeScale.label.font())
                .foregroundStyle(DesignTokens.ink)
                .padding(.horizontal, Space.x2)
                .frame(minHeight: Space.hit)
                .lifted(Radius.chip)
            progressTrack(volume)
        }
        .padding(Space.x3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .lifted(Radius.card)
        .accessibilityElement(children: .combine)
    }

    private func compact(_ volume: Volume) -> some View {
        HStack(spacing: Space.x2) {
            VStack(alignment: .leading, spacing: Space.x1) {
                Text(volume.title)
                    .font(TypeScale.headline.font())
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(spineLabel(volume))
                    .font(TypeScale.caption.font())
                    .foregroundStyle(DesignTokens.muted)
                    .lineLimit(1)
            }
            Spacer(minLength: Space.x2)
            Text(progressLabel(volume))
                .font(TypeScale.label.font())
                .foregroundStyle(DesignTokens.ink)
                .monospacedDigit()
                .lineLimit(1)
            Image(systemName: "chevron.right")
                .foregroundStyle(DesignTokens.muted)
                .accessibilityHidden(true)
        }
        .padding(Space.x2)
        .frame(minHeight: Space.hit)
        .contentShape(Rectangle())
        .lifted(Radius.card)
    }

    private func progressTrack(_ volume: Volume) -> some View {
        GeometryReader { geo in
            let fraction = volume.progressFraction ?? 0
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                    .fill(DesignTokens.bg)
                RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                    .fill(DesignTokens.accent)
                    .frame(width: max(Space.x1, geo.size.width * fraction))
            }
        }
        .frame(height: Space.x1)
        .accessibilityHidden(true)
    }

    private func progressLabel(_ volume: Volume) -> String {
        guard let fraction = volume.progressFraction else { return "unknown" }
        return Figures.percent(fraction)
    }

    private func spineLabel(_ volume: Volume) -> String {
        let place = volume.spine == .held ? "On shelf" : "Gone"
        let verdict = volume.verdict == .reread ? "Reread" : "Once"
        return "\(place), \(verdict)"
    }

    private func errorBody(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: Space.x3) {
            Text("Shelf failed to load.")
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

/// New book form. Title and author are required. Pages reject junk.
struct AddBookForm: View {
    @Bindable var board: GalleryBoard
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool

    @State private var title = ""
    @State private var author = ""
    @State private var pages = ""
    @State private var saving = false
    @State private var confirmDiscard = false

    private var total: Int? {
        let digits = pages.filter(\.isNumber)
        guard !digits.isEmpty, let value = Int(digits), value >= 0 else { return pages.isEmpty ? 0 : nil }
        return value
    }

    private var dirty: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !pages.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.x3) {
                field("Title", text: $title)
                field("Author", text: $author)
                VStack(alignment: .leading, spacing: Space.x1) {
                    Text("Pages")
                        .font(TypeScale.label.font())
                        .foregroundStyle(DesignTokens.muted)
                    TextField("0", text: $pages)
                        .keyboardType(.numberPad)
                        .focused($focused)
                        .font(TypeScale.body.font())
                        .foregroundStyle(DesignTokens.ink)
                        .padding(Space.x2)
                        .frame(minHeight: Space.hit)
                        .lifted(Radius.chip)
                        .onChange(of: pages) { _, newValue in
                            let digits = newValue.filter(\.isNumber)
                            if digits != newValue { pages = digits }
                        }
                }
                if total == nil {
                    Text("Pages must be a whole number.")
                        .font(TypeScale.caption.font())
                        .foregroundStyle(DesignTokens.ink)
                }
                Button(action: save) {
                    Text("Save book")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ActionStripButtonStyle(kind: .primary, enabled: canSave))
                .disabled(!canSave)
            }
            .padding(Space.x3)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Add a book")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .screenBackground()
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focused = false }
            }
        }
        .navigationBarBackButtonHidden(dirty)
        .toolbar {
            if dirty {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") { confirmDiscard = true }
                        .frame(minHeight: Space.hit)
                }
            }
        }
        .confirmationDialog("Leave without saving?", isPresented: $confirmDiscard, titleVisibility: .visible) {
            Button("Discard", role: .destructive) { dismiss() }
            Button("Keep editing", role: .cancel) {}
        }
    }

    private var canSave: Bool {
        !saving && total != nil
            && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func field(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: Space.x1) {
            Text(label)
                .font(TypeScale.label.font())
                .foregroundStyle(DesignTokens.muted)
            TextField(label, text: text)
                .focused($focused)
                .font(TypeScale.body.font())
                .foregroundStyle(DesignTokens.ink)
                .padding(Space.x2)
                .frame(minHeight: Space.hit)
                .lifted(Radius.chip)
        }
    }

    private func save() {
        guard canSave, let total else { return }
        saving = true
        let id = board.addVolume(title: title, author: author, totalPages: total)
        if id != nil {
            CommitHaptic.fire()
            dismiss()
        } else {
            saving = false
        }
    }
}
