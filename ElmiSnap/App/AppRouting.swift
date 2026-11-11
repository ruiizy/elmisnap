import Foundation

/// Navigation surface the module routers use to reach each other.
/// `AppRouter` is the only implementation; modules never know about each other.
@MainActor
protocol AppRouting: AnyObject {
    func startCapture(mode: CaptureMode)
    func captureDidFinish()
    func showPreview(image: CapturedImage)
    func closePreview()
    func showPreferences()
    func quit()
}
