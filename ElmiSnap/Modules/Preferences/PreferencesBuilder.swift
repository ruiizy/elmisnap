import AppKit

@MainActor
enum PreferencesBuilder {
    static func build(dependencies: AppDependencies) -> NSViewController {
        let view = PreferencesViewController()
        let interactor = PreferencesInteractor(store: dependencies.settings)
        let router = PreferencesRouter()
        let presenter = PreferencesPresenter(interactor: interactor, router: router)

        presenter.view = view
        view.presenter = presenter
        return view
    }
}
