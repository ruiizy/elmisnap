import AppKit

/// Composition root and root router. Owns the module instances and the windows
/// that host them; modules reach each other only through `AppRouting`.
@MainActor
final class AppRouter: AppRouting {
    private let dependencies: AppDependencies

    private var menuBar: MenuBarView?
    private var captureSession: CaptureOverlayController?
    private var preview: ManagedWindow?
    private var preferences: ManagedWindow?

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func start() {
        let menuBar = MenuBarBuilder.build(dependencies: dependencies, appRouter: self)
        menuBar.start()
        self.menuBar = menuBar
    }

    // MARK: - Capture

    func startCapture(mode: CaptureMode) {
        guard captureSession == nil else { return }
        let session = CaptureBuilder.build(mode: mode, dependencies: dependencies, appRouter: self)
        captureSession = session
        session.start()
    }

    func captureDidFinish() {
        captureSession = nil
    }

    // MARK: - Preview

    func showPreview(image: CapturedImage) {
        closePreview()

        let controller = PreviewBuilder.build(image: image, dependencies: dependencies, appRouter: self)
        let panel = NSPanel(contentViewController: controller)
        panel.styleMask = [.titled, .closable, .utilityWindow]
        panel.title = "ElmiSnap"
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.isReleasedWhenClosed = false

        let handler = WindowCloseHandler { [weak self, weak panel] in
            guard let self, self.preview?.window === panel else { return }
            self.preview = nil
        }
        panel.delegate = handler
        preview = ManagedWindow(window: panel, closeHandler: handler)

        if let area = NSScreen.main?.visibleFrame {
            let size = panel.frame.size
            panel.setFrameOrigin(NSPoint(x: area.maxX - size.width - 16, y: area.minY + 16))
        }
        NSApp.activate()
        panel.makeKeyAndOrderFront(nil)
    }

    func closePreview() {
        preview?.window.close()
        preview = nil
    }

    // MARK: - Preferences

    func showPreferences() {
        if let existing = preferences {
            NSApp.activate()
            existing.window.makeKeyAndOrderFront(nil)
            return
        }

        let controller = PreferencesBuilder.build(dependencies: dependencies)
        let window = NSWindow(contentViewController: controller)
        window.styleMask = [.titled, .closable]
        window.title = "ElmiSnap Preferences"
        window.isReleasedWhenClosed = false

        let handler = WindowCloseHandler { [weak self, weak window] in
            guard let self, self.preferences?.window === window else { return }
            self.preferences = nil
        }
        window.delegate = handler
        preferences = ManagedWindow(window: window, closeHandler: handler)

        window.center()
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }

    // MARK: - App

    func quit() {
        NSApp.terminate(nil)
    }
}
