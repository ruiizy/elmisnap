import Foundation

@MainActor
protocol MenuBarViewProtocol: AnyObject {
    func installStatusItem()
}

@MainActor
protocol MenuBarPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectCapture(mode: CaptureMode)
    func didSelectPreferences()
    func didSelectQuit()
}

@MainActor
protocol MenuBarInteractorProtocol: AnyObject {
    func registerGlobalHotkeys()
}

@MainActor
protocol MenuBarInteractorOutput: AnyObject {
    func hotkeyTriggered(for mode: CaptureMode)
}

@MainActor
protocol MenuBarRouterProtocol: AnyObject {
    func routeToCapture(mode: CaptureMode)
    func routeToPreferences()
    func quit()
}
