import Foundation

@MainActor
enum CaptureBuilder {
    /// The returned view owns the whole module (view → presenter → interactor/router).
    static func build(
        mode: CaptureMode,
        dependencies: AppDependencies,
        appRouter: AppRouting
    ) -> CaptureOverlayController {
        let view = CaptureOverlayController()
        let interactor = CaptureInteractor(
            permission: dependencies.permission,
            screenCapture: dependencies.screenCapture,
            clipboard: dependencies.clipboard,
            fileStorage: dependencies.fileStorage,
            settings: dependencies.settings
        )
        let router = CaptureRouter(appRouter: appRouter)
        let presenter = CapturePresenter(mode: mode, interactor: interactor, router: router)

        presenter.view = view
        view.presenter = presenter
        return view
    }
}
