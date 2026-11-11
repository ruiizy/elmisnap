import Foundation

@MainActor
protocol SettingsStore: AnyObject {
    var settings: AppSettings { get set }
}

/// Persists `AppSettings` in `UserDefaults`. The save folder is stored as a
/// security-scoped bookmark so access survives relaunches under the sandbox.
@MainActor
final class UserDefaultsSettingsStore: SettingsStore {
    private enum Key {
        static let format = "imageFormat"
        static let copyToClipboard = "copyToClipboard"
        static let showPreview = "showPreview"
        static let directoryBookmark = "saveDirectoryBookmark"
    }

    private let defaults: UserDefaults
    /// Folder whose security scope is currently open (kept open while it is the save folder).
    private var scopedDirectory: URL?

    var settings: AppSettings {
        didSet { persist() }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [Key.copyToClipboard: true, Key.showPreview: true])

        let directory = Self.resolveBookmark(in: defaults)
        _ = directory?.startAccessingSecurityScopedResource()
        scopedDirectory = directory

        settings = AppSettings(
            imageFormat: defaults.string(forKey: Key.format).flatMap(ImageFormat.init(rawValue:)) ?? .png,
            copyToClipboard: defaults.bool(forKey: Key.copyToClipboard),
            showPreview: defaults.bool(forKey: Key.showPreview),
            saveDirectory: directory
        )
    }

    private func persist() {
        defaults.set(settings.imageFormat.rawValue, forKey: Key.format)
        defaults.set(settings.copyToClipboard, forKey: Key.copyToClipboard)
        defaults.set(settings.showPreview, forKey: Key.showPreview)

        guard settings.saveDirectory != scopedDirectory else { return }
        scopedDirectory?.stopAccessingSecurityScopedResource()
        scopedDirectory = settings.saveDirectory

        if let url = settings.saveDirectory {
            _ = url.startAccessingSecurityScopedResource()
            let bookmark = try? url.bookmarkData(options: .withSecurityScope)
            defaults.set(bookmark, forKey: Key.directoryBookmark)
        } else {
            defaults.removeObject(forKey: Key.directoryBookmark)
        }
    }

    private static func resolveBookmark(in defaults: UserDefaults) -> URL? {
        guard let data = defaults.data(forKey: Key.directoryBookmark) else { return nil }
        var isStale = false
        return try? URL(
            resolvingBookmarkData: data,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
    }
}
