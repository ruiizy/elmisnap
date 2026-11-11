import CoreGraphics

@MainActor
protocol CaptureViewProtocol: AnyObject {
    func showSelectionOverlay()
    func hideSelectionOverlay()
    /// Display currently under the mouse cursor (used for fullscreen capture).
    func currentDisplayID() -> CGDirectDisplayID
    /// Blocks until the user dismisses the alert.
    func showPermissionAlert()
    func showError(message: String)
}

@MainActor
protocol CapturePresenterProtocol: AnyObject {
    func start()
    func didSelect(region: CaptureRegion)
    func didCancel()
    func didRequestOpenSystemSettings()
}

@MainActor
protocol CaptureInteractorProtocol: AnyObject {
    var hasScreenRecordingAccess: Bool { get }
    var shouldShowPreview: Bool { get }
    func requestScreenRecordingAccess()
    /// Captures, then applies the user's after-capture settings (clipboard, auto-save).
    func captureRegion(_ region: CaptureRegion) async throws -> CapturedImage
    func captureDisplay(_ displayID: CGDirectDisplayID) async throws -> CapturedImage
}

@MainActor
protocol CaptureRouterProtocol: AnyObject {
    func routeToPreview(image: CapturedImage)
    func openScreenRecordingSettings()
    /// Ends the capture session and releases the module.
    func finish()
}
