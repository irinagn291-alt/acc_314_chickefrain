import SwiftUI

/// Full-page intro. Continue sits on the bottom edge. Skip writes the same flag.
struct OnboardingView: View {
    var finish: () -> Void

    @State private var page = 0

    private let pages: [(image: String, title: String, body: String)] = [
        (
            "rfr_Onboarding1",
            "Keep the line",
            "Save a line from a book you finished. It stays after the book is gone."
        ),
        (
            "rfr_Onboarding2",
            "Weave today",
            "When one word sits on three books, Weave seats three lines for this day."
        ),
        (
            "rfr_Onboarding3",
            "Reopen the day",
            "Reopen if you want a different three. The word stays on each line."
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x3) {
            Spacer(minLength: Space.x2)
            Image(pages[page].image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: Space.x10 * 4)
                .accessibilityHidden(true)
            Text(pages[page].title)
                .font(TypeScale.display.font())
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(pages[page].body)
                .font(TypeScale.body.font())
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: Space.x1) {
                ForEach(pages.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                        .fill(index == page ? DesignTokens.accent : DesignTokens.muted.opacity(0.4))
                        .frame(width: index == page ? Space.x4 : Space.x2, height: Space.x1)
                        .accessibilityHidden(true)
                }
            }
            Spacer(minLength: Space.x2)
            Button(page == pages.count - 1 ? "Continue" : "Next") {
                if page == pages.count - 1 {
                    finish()
                } else {
                    page += 1
                }
            }
            .buttonStyle(ActionStripButtonStyle(kind: .primary))
            if page < pages.count - 1 {
                Button("Skip", action: finish)
                    .buttonStyle(ActionStripButtonStyle(kind: .quiet))
            }
        }
        .padding(Space.x3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .screenBackground()
    }
}
