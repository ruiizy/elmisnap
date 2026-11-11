import CoreGraphics
import Foundation

@MainActor
final class CaptureInteractor: CaptureInteractorProtocol {
    private let permission: PermissionService
    private let screenCapture: ScreenCaptureService
    private let clipboard: ClipboardService
    private let fileStorage: FileStorageService
    private let settings: SettingsStore

    init(
        permission: PermissionService,
        screenCapture: ScreenCaptureService,
        clipboard: ClipboardService,
        fileStorage: FileStorageService,
        settings: SettingsStore
    ) {
        self.permission = permission
        self.screenCapture = screenCapture
        self.clipboard = clipboard
        self.fileStorage = fileStorage
        self.settings = settings
    }

    var hasScreenRecordingAccess: Bool { permission.hasScreenRecordingAccess }
    var shouldShowPreview: Bool { settings.settings.showPreview }

    func requestScreenRecordingAccess() {
        permission.requestScreenRecordingAccess()
    }

    func captureRegion(_ region: CaptureRegion) async throws -> CapturedImage {
        let image = try await screenCapture.captureRegion(region)
        deliver(image)
        return image
    }

    func captureDisplay(_ displayID: CGDirectDisplayID) async throws -> CapturedImage {
        let image = try await screenCapture.captureDisplay(displayID)
        deliver(image)
        return image
    }

    private func deliver(_ image: CapturedImage) {
        let current = settings.settings
        if current.copyToClipboard {
            clipboard.copy(image)
        }
        if let directory = current.saveDirectory {
            let name = fileStorage.defaultFileName(format: current.imageFormat, date: image.capturedAt)
            do {
                try fileStorage.write(image, format: current.imageFormat, to: directory.appendingPathComponent(name))
            } catch {
                Log.capture.error("Auto-save failed: \(error.localizedDescription)")
            }
        }
    }
}
