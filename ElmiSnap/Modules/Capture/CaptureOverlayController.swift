import AppKit

/// View layer of the capture module. It manages one borderless overlay panel
/// per screen, each hosting a `SelectionView`, so it is an object rather than
/// a single `NSViewController`.
@MainActor
final class CaptureOverlayController: NSObject, CaptureViewProtocol {
    var presenter: CapturePresenterProtocol!
    private var panels: [OverlayPanel] = []

    func start() {
        presenter.start()
    }

    func showSelectionOverlay() {
        panels = NSScreen.screens.map { screen in
            let selection = SelectionView(frame: NSRect(origin: .zero, size: screen.frame.size))
            selection.displayID = screen.displayID
            selection.onSelect = { [weak self] region in self?.presenter.didSelect(region: region) }
            selection.onCancel = { [weak self] in self?.presenter.didCancel() }

            let panel = OverlayPanel(screen: screen)
            panel.contentView = selection
            return panel
        }

        NSApp.activate()
        panels.forEach { $0.orderFrontRegardless() }
        let mouse = NSEvent.mouseLocation
        let keyPanel = panels.first { NSMouseInRect(mouse, $0.frame, false) } ?? panels.first
        keyPanel?.makeKey()
    }

    func hideSelectionOverlay() {
        panels.forEach { $0.orderOut(nil) }
        panels.removeAll()
    }

    func currentDisplayID() -> CGDirectDisplayID {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main
        return screen?.displayID ?? CGMainDisplayID()
    }

    func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Screen Recording access required"
        alert.informativeText = "ElmiSnap needs permission to record the screen to take screenshots. "
            + "Enable it in System Settings → Privacy & Security → Screen Recording, then try again."
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        NSApp.activate()
        if alert.runModal() == .alertFirstButtonReturn {
            presenter.didRequestOpenSystemSettings()
        }
    }

    func showError(message: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Capture failed"
        alert.informativeText = message
        NSApp.activate()
        alert.runModal()
    }
}

extension NSScreen {
    var displayID: CGDirectDisplayID {
        let number = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
        return number?.uint32Value ?? CGMainDisplayID()
    }
}
