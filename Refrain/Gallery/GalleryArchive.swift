import Foundation

/// GalleryArchive is the only storage seam. The file is a projection of the in-memory gallery.
/// UserDefaults holds the same document under rfr.gallery.v1. Writes are atomic and off the main actor.
actor GalleryArchive {
    static let recoveryNotice = "Saved library could not be read. Started from an empty shelf."

    private let directory: URL
    private let defaults: GalleryDefaults

    init(directory: URL, defaults: GalleryDefaults) {
        self.directory = directory
        self.defaults = defaults
    }

    private var fileManager: FileManager { .default }

    static func live() -> GalleryArchive {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let directory = base.appendingPathComponent("Chickefrain", isDirectory: true)
        return GalleryArchive(directory: directory, defaults: GalleryDefaults(.standard))
    }

    func load() -> ArchiveLoad {
        let destination = documentURL
        if let gallery = read(destination) {
            return ArchiveLoad(gallery: gallery, notice: nil)
        }
        if fileManager.fileExists(atPath: destination.path) {
            if let gallery = read(backupURL) {
                return ArchiveLoad(gallery: gallery, notice: nil)
            }
            if let data = defaults.data(forKey: Gallery.storageKey), let gallery = decode(data) {
                return ArchiveLoad(gallery: gallery, notice: nil)
            }
            return ArchiveLoad(gallery: Gallery(), notice: Self.recoveryNotice)
        }
        if let data = defaults.data(forKey: Gallery.storageKey), let gallery = decode(data) {
            return ArchiveLoad(gallery: gallery, notice: nil)
        }
        return ArchiveLoad(gallery: Gallery(), notice: nil)
    }

    func save(_ gallery: Gallery) -> Bool {
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            let destination = documentURL
            if fileManager.fileExists(atPath: destination.path) {
                if fileManager.fileExists(atPath: backupURL.path) {
                    try fileManager.removeItem(at: backupURL)
                }
                try fileManager.copyItem(at: destination, to: backupURL)
            }
            let data = try encoder.encode(gallery)
            try data.write(to: destination, options: .atomic)
            defaults.set(data, forKey: Gallery.storageKey)
            return true
        } catch {
            return false
        }
    }

    func overwriteStorage(_ data: Data) {
        defaults.set(data, forKey: Gallery.storageKey)
    }

    func reset() {
        defaults.removeObject(forKey: Gallery.storageKey)
        defaults.removeObject(forKey: Gallery.demoKey)
        for url in [documentURL, backupURL] where fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                continue
            }
        }
    }

    private var documentURL: URL {
        directory.appendingPathComponent("rfr.gallery.v1.json")
    }

    private var backupURL: URL {
        directory.appendingPathComponent("rfr.gallery.v1.json.backup")
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private var decoder: JSONDecoder {
        JSONDecoder()
    }

    private func read(_ url: URL) -> Gallery? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return decode(data)
    }

    private func decode(_ data: Data) -> Gallery? {
        try? decoder.decode(Gallery.self, from: data)
    }
}

/// UserDefaults is documented thread-safe. GalleryArchive is the only owner after init.
final class GalleryDefaults: @unchecked Sendable {
    let store: UserDefaults

    init(_ store: UserDefaults) {
        self.store = store
    }

    func data(forKey key: String) -> Data? {
        store.data(forKey: key)
    }

    func set(_ data: Data, forKey key: String) {
        store.set(data, forKey: key)
    }

    func removeObject(forKey key: String) {
        store.removeObject(forKey: key)
    }
}

struct ArchiveLoad: Sendable, Equatable {
    var gallery: Gallery
    var notice: String?
}
