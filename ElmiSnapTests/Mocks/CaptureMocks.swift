import CoreGraphics
import Foundation
@testable import ElmiSnap

@MainActor
final class MockCaptureView: CaptureViewProtocol {
    var overlayShown = false
    var overlayHidden = false
    var displayID: CGDirectDisplayID = 42
    private(set) var permissionAlertCount = 0
    private(set) var errorMessages: [String] = []

    func showSelectionOverlay() { overlayShown = true }
    func hideSelectionOverlay() { overlayHidden = true }
    func currentDisplayID() -> CGDirectDisplayID { displayID }
    func showPermissionAlert() { permissionAlertCount += 1 }
    func showError(message: String) { errorMessages.append(message) }
}

@MainActor
final class MockCaptureInteractor: CaptureInteractorProtocol {
    var hasScreenRecordingAccess = true
    var shouldShowPreview = true
    var result: Result<CapturedImage, Error> = .success(TestImage.make())

    private(set) var requestAccessCount = 0
    private(set) var capturedRegions: [CaptureRegion] = []
    private(set) var capturedDisplays: [CGDirectDisplayID] = []

    func requestScreenRecordingAccess() { requestAccessCount += 1 }

    func captureRegion(_ region: CaptureRegion) async throws -> CapturedImage {
        capturedRegions.append(region)
        return try result.get()
    }

    func captureDisplay(_ displayID: CGDirectDisplayID) async throws -> CapturedImage {
        capturedDisplays.append(displayID)
        return try result.get()
    }
}

@MainActor
final class MockCaptureRouter: CaptureRouterProtocol {
    private(set) var previewImages: [CapturedImage] = []
    private(set) var openSettingsCount = 0
    private(set) var finishCount = 0

    func routeToPreview(image: CapturedImage) { previewImages.append(image) }
    func openScreenRecordingSettings() { openSettingsCount += 1 }
    func finish() { finishCount += 1 }
}

enum TestImage {
    static func make() -> CapturedImage {
        let context = CGContext(
            data: nil,
            width: 4,
            height: 4,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        return CapturedImage(cgImage: context.makeImage()!, capturedAt: Date(), scale: 2)
    }
}

struct TestError: LocalizedError {
    var errorDescription: String? { "boom" }
}
