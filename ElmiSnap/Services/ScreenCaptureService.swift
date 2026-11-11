import CoreGraphics
import Foundation
import ScreenCaptureKit

enum CaptureError: LocalizedError {
    case displayNotFound
    case invalidRegion

    var errorDescription: String? {
        switch self {
        case .displayNotFound: "The selected display is no longer available."
        case .invalidRegion: "The selected area is too small to capture."
        }
    }
}

protocol ScreenCaptureService: Sendable {
    func captureRegion(_ region: CaptureRegion) async throws -> CapturedImage
    func captureDisplay(_ displayID: CGDirectDisplayID) async throws -> CapturedImage
}

/// ScreenCaptureKit-backed implementation. ElmiSnap's own windows (selection
/// overlay, preview) are always excluded from the captured content.
struct ScreenCaptureKitService: ScreenCaptureService {
    func captureRegion(_ region: CaptureRegion) async throws -> CapturedImage {
        guard region.rect.width >= 1, region.rect.height >= 1 else {
            throw CaptureError.invalidRegion
        }
        return try await capture(displayID: region.displayID, sourceRect: region.rect)
    }

    func captureDisplay(_ displayID: CGDirectDisplayID) async throws -> CapturedImage {
        try await capture(displayID: displayID, sourceRect: nil)
    }

    private func capture(displayID: CGDirectDisplayID, sourceRect: CGRect?) async throws -> CapturedImage {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        guard let display = content.displays.first(where: { $0.displayID == displayID }) else {
            throw CaptureError.displayNotFound
        }

        let ownBundleID = Bundle.main.bundleIdentifier
        let ownApps = content.applications.filter { $0.bundleIdentifier == ownBundleID }
        let filter = SCContentFilter(display: display, excludingApplications: ownApps, exceptingWindows: [])
        let scale = CGFloat(filter.pointPixelScale)

        let configuration = SCStreamConfiguration()
        configuration.showsCursor = false
        configuration.captureResolution = .best

        let pointSize: CGSize
        if let sourceRect {
            configuration.sourceRect = sourceRect
            pointSize = sourceRect.size
        } else {
            pointSize = CGSize(width: display.width, height: display.height)
        }
        configuration.width = Int((pointSize.width * scale).rounded())
        configuration.height = Int((pointSize.height * scale).rounded())

        let cgImage = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
        return CapturedImage(cgImage: cgImage, capturedAt: Date(), scale: scale)
    }
}
