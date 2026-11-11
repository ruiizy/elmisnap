import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var router: AppRouter?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Unit tests are hosted in this app: do not install the status item or hotkeys.
        guard !Self.isRunningTests else { return }

        let router = AppRouter(dependencies: .live())
        router.start()
        self.router = router
    }

    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
            || NSClassFromString("XCTestCase") != nil
    }
}
