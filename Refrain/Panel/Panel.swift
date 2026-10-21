import Foundation

/// Panel is one seat of a Triptych. Empty until Weave writes a SlipID.
struct Panel: Codable, Hashable, Sendable, Equatable {
    var slipID: SlipID?

    init(slipID: SlipID? = nil) {
        self.slipID = slipID
    }

    var isEmpty: Bool { slipID == nil }
}
