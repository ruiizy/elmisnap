import AppKit

@MainActor
final class CaptureRouter: CaptureRouterProtocol {
    private weak var appRouter: AppRouting?

    init(appRouter: AppRouting) {
        self.appRouter = appRouter
    }

    func routeToPreview(image: CapturedImage) {
        appRouter?.showPreview(image: image)
    }

    func openScreenRecordingSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    func finish() {
        appRouter?.captureDidFinish()
    }
}
