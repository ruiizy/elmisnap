import Foundation

struct PreferencesViewModel: Equatable {
    let formatTitles: [String]
    let selectedFormatIndex: Int
    let copyToClipboard: Bool
    let showPreview: Bool
    let saveFolderText: String
    let canClearFolder: Bool
}

@MainActor
protocol PreferencesViewProtocol: AnyObject {
    func render(_ viewModel: PreferencesViewModel)
}

@MainActor
protocol PreferencesPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectFormat(at index: Int)
    func didToggleCopyToClipboard(_ isOn: Bool)
    func didToggleShowPreview(_ isOn: Bool)
    func didTapChooseFolder()
    func didTapClearFolder()
}

@MainActor
protocol PreferencesInteractorProtocol: AnyObject {
    var settings: AppSettings { get }
    func update(_ change: (inout AppSettings) -> Void)
}

@MainActor
protocol PreferencesRouterProtocol: AnyObject {
    /// Returns `nil` if the user cancels.
    func chooseDirectory(current: URL?) -> URL?
}
