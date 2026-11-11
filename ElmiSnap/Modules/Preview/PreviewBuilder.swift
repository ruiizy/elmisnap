import AppKit

@MainActor
enum PreviewBuilder {
    static func build(
        image: CapturedImage,
        dependencies: AppDependencies,
        appRouter: AppRouting
    ) -> NSViewController {
        let view = PreviewViewController()
        let interactor = PreviewInteractor(
            image: image,
            clipboard: dependencies.clipboard,
            fileStorage: dependencies.fileStorage,
            settings: dependencies.settings
        )
        let router = PreviewRouter(appRouter: appRouter)
        let presenter = PreviewPresenter(interactor: interactor, router: router)

        presenter.view = view
        view.presenter = presenter
        return view
    }
}
