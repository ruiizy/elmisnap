import Foundation

@MainActor
final class MenuBarRouter: MenuBarRouterProtocol {
    private weak var appRouter: AppRouting?

    init(appRouter: AppRouting) {
        self.appRouter = appRouter
    }

    func routeToCapture(mode: CaptureMode) {
        appRouter?.startCapture(mode: mode)
    }

    func routeToPreferences() {
        appRouter?.showPreferences()
    }

    func quit() {
        appRouter?.quit()
    }
}
