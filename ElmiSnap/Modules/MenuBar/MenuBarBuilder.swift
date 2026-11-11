import Foundation

@MainActor
enum MenuBarBuilder {
    /// The returned view owns the whole module (view → presenter → interactor/router).
    static func build(dependencies: AppDependencies, appRouter: AppRouting) -> MenuBarView {
        let view = MenuBarView()
        let interactor = MenuBarInteractor(hotkeys: dependencies.hotkeys)
        let router = MenuBarRouter(appRouter: appRouter)
        let presenter = MenuBarPresenter(interactor: interactor, router: router)

        presenter.view = view
        interactor.output = presenter
        view.presenter = presenter
        return view
    }
}
