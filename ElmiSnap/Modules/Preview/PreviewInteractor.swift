import Foundation

@MainActor
final class PreviewInteractor: PreviewInteractorProtocol {
    let image: CapturedImage
    private let clipboard: ClipboardService
    private let fileStorage: FileStorageService
    private let settings: SettingsStore

    init(
        image: CapturedImage,
        clipboard: ClipboardService,
        fileStorage: FileStorageService,
        settings: SettingsStore
    ) {
        self.image = image
        self.clipboard = clipboard
        self.fileStorage = fileStorage
        self.settings = settings
    }

    var imageFormat: ImageFormat { settings.settings.imageFormat }

    var suggestedFileName: String {
        fileStorage.defaultFileName(format: imageFormat, date: image.capturedAt)
    }

    func copyToClipboard() {
        clipboard.copy(image)
    }

    func save(to url: URL) throws {
        try fileStorage.write(image, format: imageFormat, to: url)
    }
}
