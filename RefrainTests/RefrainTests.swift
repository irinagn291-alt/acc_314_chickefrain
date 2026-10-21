import XCTest
@testable import Refrain

@MainActor
final class RefrainTests: XCTestCase {
    private let day = DayKey(raw: 20261021)
    private let nextDay = DayKey(raw: 20261022)

    func testQuoteStoreIsPerVolumeAndVerdictHasNoStars() {
        var gallery = Gallery()
        let waves = VolumeID("waves")
        let other = VolumeID("other")
        XCTAssertNotNil(gallery.addVolume(title: "The Waves", author: "Woolf", totalPages: 100, id: waves))
        XCTAssertNotNil(gallery.addVolume(title: "The Odyssey", author: "Homer", totalPages: 0, id: other))
        XCTAssertNotNil(gallery.captureSlip(volumeID: waves, text: "A line", page: 10, id: SlipID("a")))
        XCTAssertNil(gallery.captureSlip(volumeID: VolumeID("missing"), text: "Nowhere", id: SlipID("b")))
        XCTAssertEqual(gallery.quoteStore(for: waves).map(\.id), [SlipID("a")])
        XCTAssertTrue(gallery.quoteStore(for: other).isEmpty)
        XCTAssertTrue(gallery.setPages(current: 25, total: 100, volumeID: waves))
        XCTAssertEqual(gallery.volume(waves)?.progressFraction, 0.25)
        XCTAssertNil(gallery.volume(other)?.progressFraction)
        XCTAssertTrue(gallery.setVerdict(.reread, volumeID: waves))
        XCTAssertEqual(gallery.volume(waves)?.verdict, .reread)
        let names = Mirror(reflecting: gallery.volume(waves)!).children.map(\.label)
        XCTAssertFalse(names.contains("stars"))
        XCTAssertFalse(names.contains("rating"))
    }

    func testWeaveEmptyPopulatedAndInvalid() {
        var empty = Gallery()
        XCTAssertEqual(empty.fold().map(\.phase), [.blank])
        XCTAssertEqual(empty.weave(on: day), .blank)
        XCTAssertEqual(empty.blanks.count, 1)
        XCTAssertTrue(empty.triptych(on: day).panelsEmpty)

        var idle = Gallery()
        XCTAssertNotNil(idle.addVolume(title: "The Waves", author: "Woolf", totalPages: 10, id: VolumeID("v")))
        XCTAssertNotNil(idle.captureSlip(volumeID: VolumeID("v"), text: "Line", id: SlipID("s")))
        XCTAssertEqual(idle.phase(on: day), .idle)
        XCTAssertFalse(idle.thread(slipID: SlipID("s"), rawLemma: "   ", on: day))
        XCTAssertEqual(idle.weave(on: day), .bare)
        XCTAssertEqual(idle.bareMarks.count, 1)
        XCTAssertTrue(idle.triptych(on: day).panelsEmpty)
        XCTAssertEqual(idle.phase(on: day), .idle)

        XCTAssertTrue(idle.thread(slipID: SlipID("s"), rawLemma: "light", on: day))
        XCTAssertEqual(idle.weave(on: day), .thin)
        XCTAssertEqual(idle.thinMarks.count, 1)
        XCTAssertTrue(idle.triptych(on: day).panelsEmpty)
    }

    func testThreadThenWeaveRefusesSecondSeatUntilPeel() {
        var gallery = threeVolumeShelf()
        XCTAssertEqual(gallery.phase(on: day), .idle)
        threadThreshold(&gallery)
        XCTAssertEqual(gallery.phase(on: day), .spooled)
        XCTAssertEqual(gallery.qualifyingLemmas(), [Lemma(word: "threshold")])
        XCTAssertEqual(gallery.weave(on: day), .woven)
        let seated = gallery.triptych(on: day)
        XCTAssertEqual(seated.phase, .woven)
        XCTAssertFalse(seated.panelsEmpty)
        XCTAssertEqual(gallery.weaveMarks.count, 1)
        XCTAssertEqual(gallery.weave(on: day), .refused)
        XCTAssertEqual(gallery.weaveMarks.count, 1)
        XCTAssertTrue(gallery.peel(on: day))
        XCTAssertTrue(gallery.weaveMarks.isEmpty)
        XCTAssertEqual(gallery.phase(on: day), .spooled)
        XCTAssertEqual(gallery.peels.count, 1)
        XCTAssertEqual(gallery.weave(on: day), .woven)
        XCTAssertEqual(gallery.weaveMarks.count, 1)
    }

    func testFoldIsPerDaykeyAndHollowKeepsSlips() {
        var gallery = threeVolumeShelf()
        threadThreshold(&gallery)
        XCTAssertEqual(gallery.weave(on: day), .woven)
        XCTAssertEqual(gallery.phase(on: nextDay), .spooled)
        XCTAssertTrue(gallery.triptych(on: nextDay).panelsEmpty)
        XCTAssertEqual(gallery.weave(on: nextDay), .woven)
        XCTAssertEqual(gallery.fold().map(\.phase), [.woven, .woven])
        XCTAssertTrue(gallery.hollow(VolumeID("a")))
        XCTAssertEqual(gallery.volume(VolumeID("a"))?.spine, .hollowed)
        XCTAssertEqual(gallery.quoteStore(for: VolumeID("a")).count, 1)
        XCTAssertEqual(gallery.phase(on: DayKey(raw: 20261023)), .spooled)
    }

    func testPersistenceRoundTripAndCorruptFallback() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("refrain-tests-\(UUID().uuidString)", isDirectory: true)
        let suite = "refrain.tests.\(UUID().uuidString)"
        guard let store = UserDefaults(suiteName: suite) else {
            XCTFail("suite")
            return
        }
        store.removePersistentDomain(forName: suite)
        let defaults = GalleryDefaults(store)
        let archive = GalleryArchive(directory: directory, defaults: defaults)
        var gallery = threeVolumeShelf()
        threadThreshold(&gallery)
        XCTAssertEqual(gallery.weave(on: day), .woven)
        let saved = await archive.save(gallery)
        XCTAssertTrue(saved)
        let reloaded = await GalleryArchive(directory: directory, defaults: defaults).load()
        XCTAssertNil(reloaded.notice)
        XCTAssertEqual(reloaded.gallery, gallery)
        XCTAssertEqual(reloaded.gallery.phase(on: day), .woven)

        let url = directory.appendingPathComponent("rfr.gallery.v1.json")
        try Data("not-json".utf8).write(to: url, options: .atomic)
        let recovered = await GalleryArchive(directory: directory, defaults: defaults).load()
        XCTAssertEqual(recovered.gallery.weaveMarks.count, 1)
        XCTAssertNil(recovered.notice)

        try Data("still-bad".utf8).write(to: url, options: .atomic)
        let backup = directory.appendingPathComponent("rfr.gallery.v1.json.backup")
        try Data("also-bad".utf8).write(to: backup, options: .atomic)
        await archive.overwriteStorage(Data("nope".utf8))
        let emptied = await archive.load()
        XCTAssertTrue(emptied.gallery.isEmpty)
        XCTAssertEqual(emptied.notice, GalleryArchive.recoveryNotice)

        let board = GalleryBoard(archive: archive, gallery: gallery)
        await board.resetAllData()
        let after = await archive.load()
        XCTAssertTrue(after.gallery.isEmpty)
        store.removePersistentDomain(forName: suite)
    }

    func testReviewLaunchParsesScreenArgument() {
        XCTAssertEqual(ReviewLaunch.screen(in: ["Refrain", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Refrain", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Refrain", "-ReviewScreen", "goals"]), "goals")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Refrain", "-ReviewScreen", "settings"]), "settings")
        XCTAssertNil(ReviewLaunch.screen(in: ["Refrain"]))
        XCTAssertNil(ReviewLaunch.screen(in: ["Refrain", "-ReviewScreen"]))
        XCTAssertNil(ReviewLaunch.screen(in: ["Refrain", "-ReviewScreen", "-Other"]))
    }

    func testSimulatorSeedStartsSpooled() {
        let seeded = Gallery.simulatorSeed(on: day)
        XCTAssertEqual(seeded.volumes.count, 3)
        XCTAssertEqual(seeded.phase(on: day), .spooled)
        XCTAssertEqual(seeded.qualifyingLemmas().first?.word, "threshold")
        var copy = seeded
        XCTAssertEqual(copy.weave(on: day), .woven)
    }

    private func threeVolumeShelf() -> Gallery {
        var gallery = Gallery()
        for (id, title) in [("a", "The Waves"), ("b", "Middlemarch"), ("c", "The Odyssey")] {
            XCTAssertNotNil(gallery.addVolume(title: title, author: "Author", totalPages: 100, id: VolumeID(id)))
            XCTAssertNotNil(
                gallery.captureSlip(volumeID: VolumeID(id), text: "Line \(id)", id: SlipID(id))
            )
        }
        return gallery
    }

    private func threadThreshold(_ gallery: inout Gallery) {
        XCTAssertTrue(gallery.thread(slipID: SlipID("a"), rawLemma: "Threshold", on: day))
        XCTAssertTrue(gallery.thread(slipID: SlipID("b"), rawLemma: "threshold", on: day))
        XCTAssertTrue(gallery.thread(slipID: SlipID("c"), rawLemma: "THRESHOLD", on: day))
    }
}
