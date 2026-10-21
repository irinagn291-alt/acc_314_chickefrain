import Foundation

/// Gallery is the root fold. Each daykey is a Triptych of Idle, Spooled, or Woven.
/// Thread writes a Lemma. Weave seats three slips. Peel reopens the day.
struct Gallery: Codable, Hashable, Sendable, Equatable {
    static let schemaVersion = 1
    static let storageKey = "rfr.gallery.v1"
    static let demoKey = "rfr.demo.v1"

    var schemaVersion: Int
    var volumes: [Volume]
    var slips: [Slip]
    var threadMarks: [ThreadMark]
    var weaveMarks: [WeaveMark]
    var thinMarks: [ThinMark]
    var bareMarks: [BareMark]
    var blanks: [Blank]
    var peels: [Peel]

    init(
        schemaVersion: Int = Gallery.schemaVersion,
        volumes: [Volume] = [],
        slips: [Slip] = [],
        threadMarks: [ThreadMark] = [],
        weaveMarks: [WeaveMark] = [],
        thinMarks: [ThinMark] = [],
        bareMarks: [BareMark] = [],
        blanks: [Blank] = [],
        peels: [Peel] = []
    ) {
        self.schemaVersion = schemaVersion
        self.volumes = volumes
        self.slips = slips
        self.threadMarks = threadMarks
        self.weaveMarks = weaveMarks
        self.thinMarks = thinMarks
        self.bareMarks = bareMarks
        self.blanks = blanks
        self.peels = peels
    }

    var isEmpty: Bool { volumes.isEmpty && slips.isEmpty }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            volumes = try container.decodeIfPresent([Volume].self, forKey: .volumes) ?? []
            slips = try container.decodeIfPresent([Slip].self, forKey: .slips) ?? []
            threadMarks = try container.decodeIfPresent([ThreadMark].self, forKey: .threadMarks) ?? []
            weaveMarks = try container.decodeIfPresent([WeaveMark].self, forKey: .weaveMarks) ?? []
            thinMarks = try container.decodeIfPresent([ThinMark].self, forKey: .thinMarks) ?? []
            bareMarks = try container.decodeIfPresent([BareMark].self, forKey: .bareMarks) ?? []
            blanks = try container.decodeIfPresent([Blank].self, forKey: .blanks) ?? []
            peels = try container.decodeIfPresent([Peel].self, forKey: .peels) ?? []
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unknown gallery schema \(version)"
            )
        }
    }

    /// Slips that belong to one volume. A slip never appears in a second store.
    func quoteStore(for volumeID: VolumeID) -> [Slip] {
        slips.filter { $0.volumeID == volumeID }
    }

    func volume(_ id: VolumeID) -> Volume? {
        volumes.first { $0.id == id }
    }

    func slip(_ id: SlipID) -> Slip? {
        slips.first { $0.id == id }
    }

    /// Lemmas that name at least three slips from three distinct volumes.
    func qualifyingLemmas() -> [Lemma] {
        var volumesByWord: [String: Set<String>] = [:]
        for slip in slips {
            guard let lemma = slip.lemma else { continue }
            guard volume(slip.volumeID) != nil else { continue }
            volumesByWord[lemma.word, default: []].insert(slip.volumeID.rawValue)
        }
        return volumesByWord
            .filter { $0.value.count >= 3 }
            .map { Lemma(word: $0.key) }
            .sorted { $0.word < $1.word }
    }

    func phase(on day: DayKey) -> TriptychPhase {
        if isEmpty { return .blank }
        if weaveMarks.contains(where: { $0.daykey == day }) { return .woven }
        if !qualifyingLemmas().isEmpty { return .spooled }
        return .idle
    }

    func triptych(on day: DayKey) -> Triptych {
        if let mark = weaveMarks.last(where: { $0.daykey == day }) {
            return Triptych(
                daykey: day,
                phase: .woven,
                left: Panel(slipID: mark.left),
                center: Panel(slipID: mark.center),
                right: Panel(slipID: mark.right)
            )
        }
        return Triptych(
            daykey: day,
            phase: phase(on: day),
            left: Panel(),
            center: Panel(),
            right: Panel()
        )
    }

    /// Fold over every daykey that carries a mark. An empty gallery is one Blank.
    func fold() -> [Triptych] {
        var days = Set<DayKey>()
        days.formUnion(threadMarks.map(\.daykey))
        days.formUnion(weaveMarks.map(\.daykey))
        days.formUnion(thinMarks.map(\.daykey))
        days.formUnion(bareMarks.map(\.daykey))
        days.formUnion(blanks.map(\.daykey))
        days.formUnion(peels.map(\.daykey))
        if days.isEmpty {
            return [triptych(on: DayKey(raw: 0))]
        }
        return days.sorted().map { triptych(on: $0) }
    }

    @discardableResult
    mutating func addVolume(title: String, author: String, totalPages: Int, id: VolumeID = VolumeID(UUID().uuidString)) -> VolumeID? {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAuthor = author.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, !trimmedAuthor.isEmpty else { return nil }
        guard !volumes.contains(where: { $0.id == id }) else { return nil }
        volumes.append(
            Volume(
                id: id,
                title: trimmedTitle,
                author: trimmedAuthor,
                currentPage: 0,
                totalPages: max(0, totalPages),
                spine: .held,
                verdict: .not
            )
        )
        return id
    }

    /// Capture into that volume's only quote store.
    @discardableResult
    mutating func captureSlip(
        volumeID: VolumeID,
        text: String,
        page: Int? = nil,
        id: SlipID = SlipID(UUID().uuidString)
    ) -> SlipID? {
        guard volume(volumeID) != nil else { return nil }
        guard !slips.contains(where: { $0.id == id }) else { return nil }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        slips.append(Slip(id: id, volumeID: volumeID, text: trimmed, page: page, lemma: nil))
        return id
    }

    @discardableResult
    mutating func thread(slipID: SlipID, rawLemma: String, on day: DayKey) -> Bool {
        guard let lemma = Lemma.normalize(rawLemma) else { return false }
        guard let index = slips.firstIndex(where: { $0.id == slipID }) else { return false }
        slips[index].lemma = lemma
        threadMarks.append(
            ThreadMark(id: UUID(), daykey: day, slipID: slipID, lemma: lemma)
        )
        return true
    }

    /// Weave seats a triptych, or writes Bare, Thin, or Blank. A second Weave while Woven is refused.
    @discardableResult
    mutating func weave(on day: DayKey, lemma preferred: Lemma? = nil) -> WeaveResult {
        if isEmpty {
            blanks.append(Blank(id: UUID(), daykey: day))
            return .blank
        }
        if weaveMarks.contains(where: { $0.daykey == day }) {
            return .refused
        }
        let lemma: Lemma?
        if let preferred, qualifyingLemmas().contains(preferred) {
            lemma = preferred
        } else {
            lemma = qualifyingLemmas().first
        }
        guard let lemma else {
            let anyLemma = slips.contains { $0.lemma != nil }
            if anyLemma {
                thinMarks.append(ThinMark(id: UUID(), daykey: day))
                return .thin
            }
            bareMarks.append(BareMark(id: UUID(), daykey: day))
            return .bare
        }
        guard let seated = seat(lemma: lemma) else {
            thinMarks.append(ThinMark(id: UUID(), daykey: day))
            return .thin
        }
        weaveMarks.append(
            WeaveMark(
                id: UUID(),
                daykey: day,
                lemma: lemma,
                left: seated.0,
                center: seated.1,
                right: seated.2
            )
        )
        return .woven
    }

    /// Removes the newest WeaveMark for the day and returns the fold to Spooled when a lemma still qualifies.
    @discardableResult
    mutating func peel(on day: DayKey) -> Bool {
        guard let index = weaveMarks.lastIndex(where: { $0.daykey == day }) else { return false }
        let removed = weaveMarks.remove(at: index)
        peels.append(Peel(id: UUID(), daykey: day, weaveMarkID: removed.id))
        return true
    }

    @discardableResult
    mutating func hollow(_ id: VolumeID) -> Bool {
        guard let index = volumes.firstIndex(where: { $0.id == id }) else { return false }
        volumes[index].spine = .hollowed
        return true
    }

    @discardableResult
    mutating func setVerdict(_ verdict: Verdict, volumeID: VolumeID) -> Bool {
        guard let index = volumes.firstIndex(where: { $0.id == volumeID }) else { return false }
        volumes[index].verdict = verdict
        return true
    }

    @discardableResult
    mutating func setPages(current: Int, total: Int, volumeID: VolumeID) -> Bool {
        guard let index = volumes.firstIndex(where: { $0.id == volumeID }) else { return false }
        volumes[index].totalPages = max(0, total)
        volumes[index].currentPage = max(0, current)
        return true
    }

    /// Three volumes, three slips sharing "threshold", plus two commonplace lines. Fold starts Spooled.
    static func simulatorSeed(on day: DayKey) -> Gallery {
        var gallery = Gallery()
        let waves = VolumeID("rfr.volume.waves")
        let middle = VolumeID("rfr.volume.middlemarch")
        let odyssey = VolumeID("rfr.volume.odyssey")
        gallery.addVolume(title: "The Waves", author: "Virginia Woolf", totalPages: 240, id: waves)
        gallery.addVolume(title: "Middlemarch", author: "George Eliot", totalPages: 880, id: middle)
        gallery.addVolume(title: "The Odyssey", author: "Homer", totalPages: 416, id: odyssey)
        gallery.setPages(current: 48, total: 240, volumeID: waves)
        gallery.setPages(current: 120, total: 880, volumeID: middle)
        gallery.setPages(current: 36, total: 416, volumeID: odyssey)
        gallery.setVerdict(.reread, volumeID: waves)
        let first = SlipID("rfr.slip.waves.threshold")
        let second = SlipID("rfr.slip.middle.threshold")
        let third = SlipID("rfr.slip.odyssey.threshold")
        gallery.captureSlip(
            volumeID: waves,
            text: "The sun had not yet risen. The sea was indistinguishable from the sky.",
            page: 3,
            id: first
        )
        gallery.captureSlip(
            volumeID: middle,
            text: "It is a narrow mind which cannot look at a subject from various points of view.",
            page: 64,
            id: second
        )
        gallery.captureSlip(
            volumeID: odyssey,
            text: "Tell me, Muse, of the man of many ways.",
            page: 1,
            id: third
        )
        gallery.captureSlip(
            volumeID: waves,
            text: "The light struck upon the trees in the garden.",
            page: 12,
            id: SlipID("rfr.slip.waves.light")
        )
        gallery.captureSlip(
            volumeID: odyssey,
            text: "There is a time for many words, and there is a time for sleep.",
            page: 200,
            id: SlipID("rfr.slip.odyssey.sleep")
        )
        gallery.thread(slipID: first, rawLemma: "Threshold", on: day)
        gallery.thread(slipID: second, rawLemma: " threshold ", on: day)
        gallery.thread(slipID: third, rawLemma: "THRESHOLD", on: day)
        gallery.thread(slipID: SlipID("rfr.slip.waves.light"), rawLemma: "light", on: day)
        return gallery
    }

    /// One line per book for this word, book id ascending. Weave seats the first three.
    func lines(for lemma: Lemma) -> [Slip] {
        var chosen: [(volume: String, slip: Slip)] = []
        let ordered = slips.sorted { $0.id.rawValue < $1.id.rawValue }
        for slip in ordered where slip.lemma == lemma {
            guard volume(slip.volumeID) != nil else { continue }
            if chosen.contains(where: { $0.volume == slip.volumeID.rawValue }) { continue }
            chosen.append((slip.volumeID.rawValue, slip))
        }
        chosen.sort { $0.volume < $1.volume }
        return chosen.map(\.slip)
    }

    private func seat(lemma: Lemma) -> (SlipID, SlipID, SlipID)? {
        let chosen = lines(for: lemma)
        guard chosen.count >= 3 else { return nil }
        return (chosen[0].id, chosen[1].id, chosen[2].id)
    }
}

enum WeaveResult: String, Codable, Hashable, Sendable {
    case woven
    case bare
    case thin
    case blank
    case refused
}
