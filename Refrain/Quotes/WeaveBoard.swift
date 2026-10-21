import SwiftUI

/// Three quote cards, stacked so each line stays inside the screen margins.
struct WeaveBoard: View {
    struct Seat: Identifiable {
        var id: String
        var book: String
        var line: String
    }

    var seats: [Seat]
    var onOpen: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x2) {
            ForEach(seats) { seat in
                Button {
                    onOpen(seat.id)
                } label: {
                    VStack(alignment: .leading, spacing: Space.x1) {
                        Text(seat.book)
                            .font(TypeScale.label.font())
                            .foregroundStyle(DesignTokens.muted)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(seat.line)
                            .font(TypeScale.body.font())
                            .foregroundStyle(DesignTokens.ink)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(Space.x2)
                    .frame(maxWidth: .infinity, minHeight: Space.hit, alignment: .leading)
                    .contentShape(Rectangle())
                    .lifted(Radius.card)
                }
                .buttonStyle(PressPlainStyle())
                .accessibilityLabel("\(seat.book). \(seat.line). Open line")
            }
        }
    }
}
