import AppKit

/// View layer of the menu bar module. There is no view controller: the UI is
/// an `NSStatusItem` with an `NSMenu`.
@MainActor
final class MenuBarView: NSObject, MenuBarViewProtocol {
    var presenter: MenuBarPresenterProtocol!
    private var statusItem: NSStatusItem?

    func start() {
        presenter.viewDidLoad()
    }

    func installStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = NSImage(
            systemSymbolName: "camera.viewfinder",
            accessibilityDescription: "ElmiSnap"
        )
        item.menu = makeMenu()
        statusItem = item
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()

        // Key equivalents only document the global hotkeys inside the menu.
        let area = menuItem("Capture Area", action: #selector(captureArea), key: "4")
        area.keyEquivalentModifierMask = [.control, .shift]
        let fullscreen = menuItem("Capture Fullscreen", action: #selector(captureFullscreen), key: "3")
        fullscreen.keyEquivalentModifierMask = [.control, .shift]

        menu.addItem(area)
        menu.addItem(fullscreen)
        menu.addItem(.separator())
        menu.addItem(menuItem("Preferences…", action: #selector(openPreferences), key: ","))
        menu.addItem(.separator())
        menu.addItem(menuItem("Quit ElmiSnap", action: #selector(quit), key: "q"))
        return menu
    }

    private func menuItem(_ title: String, action: Selector, key: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        return item
    }

    @objc private func captureArea() { presenter.didSelectCapture(mode: .area) }
    @objc private func captureFullscreen() { presenter.didSelectCapture(mode: .fullscreen) }
    @objc private func openPreferences() { presenter.didSelectPreferences() }
    @objc private func quit() { presenter.didSelectQuit() }
}
