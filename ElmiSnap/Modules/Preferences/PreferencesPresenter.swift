import Foundation

@MainActor
final class PreferencesPresenter: PreferencesPresenterProtocol {
    weak var view: PreferencesViewProtocol?
    private let interactor: PreferencesInteractorProtocol
    private let router: PreferencesRouterProtocol

    init(interactor: PreferencesInteractorProtocol, router: PreferencesRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        render()
    }

    func didSelectFormat(at index: Int) {
        guard ImageFormat.allCases.indices.contains(index) else { return }
        interactor.update { $0.imageFormat = ImageFormat.allCases[index] }
        render()
    }

    func didToggleCopyToClipboard(_ isOn: Bool) {
        interactor.update { $0.copyToClipboard = isOn }
        render()
    }

    func didToggleShowPreview(_ isOn: Bool) {
        interactor.update { $0.showPreview = isOn }
        render()
    }

    func didTapChooseFolder() {
        guard let url = router.chooseDirectory(current: interactor.settings.saveDirectory) else { return }
        interactor.update { $0.saveDirectory = url }
        render()
    }

    func didTapClearFolder() {
        interactor.update { $0.saveDirectory = nil }
        render()
    }

    func makeViewModel() -> PreferencesViewModel {
        let settings = interactor.settings
        return PreferencesViewModel(
            formatTitles: ImageFormat.allCases.map(\.displayName),
            selectedFormatIndex: ImageFormat.allCases.firstIndex(of: settings.imageFormat) ?? 0,
            copyToClipboard: settings.copyToClipboard,
            showPreview: settings.showPreview,
            saveFolderText: settings.saveDirectory?.path(percentEncoded: false) ?? "Not set (clipboard only)",
            canClearFolder: settings.saveDirectory != nil
        )
    }

    private func render() {
        view?.render(makeViewModel())
    }
}
