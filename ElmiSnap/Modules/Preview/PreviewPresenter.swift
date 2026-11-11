import Foundation

@MainActor
final class PreviewPresenter: PreviewPresenterProtocol {
    weak var view: PreviewViewProtocol?
    private let interactor: PreviewInteractorProtocol
    private let router: PreviewRouterProtocol

    init(interactor: PreviewInteractorProtocol, router: PreviewRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        let image = interactor.image
        view?.render(
            PreviewViewModel(
                image: image.cgImage,
                pointSize: image.pointSize,
                caption: "\(image.cgImage.width) × \(image.cgImage.height) px"
            )
        )
    }

    func didTapCopy() {
        interactor.copyToClipboard()
        view?.showStatus("Copied to clipboard")
    }

    func didTapSave() {
        guard let url = router.askSaveLocation(
            suggestedName: interactor.suggestedFileName,
            format: interactor.imageFormat
        ) else { return }

        do {
            try interactor.save(to: url)
            view?.showStatus("Saved \(url.lastPathComponent)")
        } catch {
            view?.showStatus(error.localizedDescription)
        }
    }

    func didTapClose() {
        router.close()
    }
}
