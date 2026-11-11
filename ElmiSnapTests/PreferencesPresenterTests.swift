import Foundation
import Testing
@testable import ElmiSnap

@MainActor
struct PreferencesPresenterTests {
    private final class MockView: PreferencesViewProtocol {
        private(set) var rendered: [PreferencesViewModel] = []
        func render(_ viewModel: PreferencesViewModel) { rendered.append(viewModel) }
    }

    private final class MockInteractor: PreferencesInteractorProtocol {
        var settings = AppSettings()
        func update(_ change: (inout AppSettings) -> Void) { change(&settings) }
    }

    private final class MockRouter: PreferencesRouterProtocol {
        var chosenDirectory: URL?
        func chooseDirectory(current: URL?) -> URL? { chosenDirectory }
    }

    private let view = MockView()
    private let interactor = MockInteractor()
    private let router = MockRouter()

    private func makePresenter() -> PreferencesPresenter {
        let presenter = PreferencesPresenter(interactor: interactor, router: router)
        presenter.view = view
        return presenter
    }

    @Test func viewDidLoadRendersCurrentSettings() {
        let sut = makePresenter()

        sut.viewDidLoad()

        #expect(view.rendered.last?.formatTitles == ["PNG", "JPEG"])
        #expect(view.rendered.last?.selectedFormatIndex == 0)
        #expect(view.rendered.last?.canClearFolder == false)
    }

    @Test func selectingFormatUpdatesSettingsAndRerenders() {
        let sut = makePresenter()

        sut.didSelectFormat(at: 1)

        #expect(interactor.settings.imageFormat == .jpeg)
        #expect(view.rendered.last?.selectedFormatIndex == 1)
    }

    @Test func choosingFolderStoresItAndEnablesClear() {
        let folder = URL(filePath: "/tmp/shots")
        router.chosenDirectory = folder
        let sut = makePresenter()

        sut.didTapChooseFolder()

        #expect(interactor.settings.saveDirectory == folder)
        #expect(view.rendered.last?.canClearFolder == true)
    }

    @Test func cancellingFolderPickerKeepsSettings() {
        router.chosenDirectory = nil
        let sut = makePresenter()

        sut.didTapChooseFolder()

        #expect(interactor.settings.saveDirectory == nil)
        #expect(view.rendered.isEmpty)
    }

    @Test func clearingFolderRemovesIt() {
        interactor.settings.saveDirectory = URL(filePath: "/tmp/shots")
        let sut = makePresenter()

        sut.didTapClearFolder()

        #expect(interactor.settings.saveDirectory == nil)
        #expect(view.rendered.last?.canClearFolder == false)
    }
}
