import Foundation

@MainActor
final class MenuBarPresenter: MenuBarPresenterProtocol, MenuBarInteractorOutput {
    weak var view: MenuBarViewProtocol?
    private let interactor: MenuBarInteractorProtocol
    private let router: MenuBarRouterProtocol

    init(interactor: MenuBarInteractorProtocol, router: MenuBarRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        view?.installStatusItem()
        interactor.registerGlobalHotkeys()
    }

    func didSelectCapture(mode: CaptureMode) {
        router.routeToCapture(mode: mode)
    }

    func didSelectPreferences() {
        router.routeToPreferences()
    }

    func didSelectQuit() {
        router.quit()
    }

    func hotkeyTriggered(for mode: CaptureMode) {
        router.routeToCapture(mode: mode)
    }
}
