import Foundation

@MainActor
final class MenuBarInteractor: MenuBarInteractorProtocol {
    weak var output: MenuBarInteractorOutput?
    private let hotkeys: HotkeyService

    init(hotkeys: HotkeyService) {
        self.hotkeys = hotkeys
    }

    func registerGlobalHotkeys() {
        hotkeys.register(.captureArea) { [weak self] in
            self?.output?.hotkeyTriggered(for: .area)
        }
        hotkeys.register(.captureFullscreen) { [weak self] in
            self?.output?.hotkeyTriggered(for: .fullscreen)
        }
    }
}
