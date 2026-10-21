import Foundation
import Observation

/// GalleryBoard is the state between the gallery fold and the screens.
/// Views send Thread, Weave, and Peel here. They never touch the archive.
@MainActor
@Observable
final class GalleryBoard {
    private(set) var gallery: Gallery
    private(set) var notice: String?
    private(set) var lastWeave: WeaveResult?
    private let archive: GalleryArchive
    private var saveTask: Task<Void, Never>?
    private var generation = 0

    init(archive: GalleryArchive, gallery: Gallery = Gallery()) {
        self.archive = archive
        self.gallery = gallery
    }

    func bootstrap() async {
        let loaded = await archive.load()
        gallery = loaded.gallery
        notice = loaded.notice
        await seedSimulatorIfNeeded()
    }

    func thread(slipID: SlipID, rawLemma: String, on day: DayKey) {
        guard gallery.thread(slipID: slipID, rawLemma: rawLemma, on: day) else { return }
        scheduleSave()
    }

    func weave(on day: DayKey, lemma: Lemma? = nil) {
        let result = gallery.weave(on: day, lemma: lemma)
        lastWeave = result
        guard result != .refused else { return }
        scheduleSave()
    }

    func peel(on day: DayKey) {
        guard gallery.peel(on: day) else { return }
        scheduleSave()
    }

    @discardableResult
    func addVolume(title: String, author: String, totalPages: Int) -> VolumeID? {
        guard let id = gallery.addVolume(title: title, author: author, totalPages: totalPages) else { return nil }
        scheduleSave()
        return id
    }

    @discardableResult
    func captureSlip(volumeID: VolumeID, text: String, page: Int?) -> SlipID? {
        guard let id = gallery.captureSlip(volumeID: volumeID, text: text, page: page) else { return nil }
        scheduleSave()
        return id
    }

    func setPages(current: Int, total: Int, volumeID: VolumeID) {
        guard gallery.setPages(current: current, total: total, volumeID: volumeID) else { return }
        scheduleSave()
    }

    func reload() async {
        let loaded = await archive.load()
        gallery = loaded.gallery
        notice = loaded.notice
    }

    func hollow(_ id: VolumeID) {
        guard gallery.hollow(id) else { return }
        scheduleSave()
    }

    func setVerdict(_ verdict: Verdict, volumeID: VolumeID) {
        guard gallery.setVerdict(verdict, volumeID: volumeID) else { return }
        scheduleSave()
    }

    func flush() async {
        generation += 1
        saveTask?.cancel()
        saveTask = nil
        _ = await archive.save(gallery)
    }

    func resetAllData() async {
        generation += 1
        saveTask?.cancel()
        saveTask = nil
        gallery = Gallery()
        notice = nil
        lastWeave = nil
        await archive.reset()
    }

    private func scheduleSave() {
        generation += 1
        let token = generation
        let snapshot = gallery
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled, token == generation else { return }
            _ = await archive.save(snapshot)
        }
    }

    private func seedSimulatorIfNeeded() async {
        #if targetEnvironment(simulator)
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: Gallery.demoKey) == false else { return }
        guard gallery.isEmpty else {
            defaults.set(true, forKey: Gallery.demoKey)
            return
        }
        gallery = Gallery.simulatorSeed(on: DayKey.make(from: Date()))
        defaults.set(true, forKey: Gallery.demoKey)
        _ = await archive.save(gallery)
        #endif
    }
}
