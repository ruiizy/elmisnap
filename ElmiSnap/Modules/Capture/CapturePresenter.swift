import CoreGraphics
import Foundation

@MainActor
final class CapturePresenter: CapturePresenterProtocol {
    weak var view: CaptureViewProtocol?
    private let mode: CaptureMode
    private let interactor: CaptureInteractorProtocol
    private let router: CaptureRouterProtocol

    /// In-flight capture, exposed so tests can await it.
    private(set) var captureTask: Task<Void, Never>?

    private enum Request {
        case region(CaptureRegion)
        case display(CGDirectDisplayID)
    }

    init(mode: CaptureMode, interactor: CaptureInteractorProtocol, router: CaptureRouterProtocol) {
        self.mode = mode
        self.interactor = interactor
        self.router = router
    }

    func start() {
        guard interactor.hasScreenRecordingAccess else {
            interactor.requestScreenRecordingAccess()
            view?.showPermissionAlert()
            router.finish()
            return
        }

        switch mode {
        case .area:
            view?.showSelectionOverlay()
        case .fullscreen:
            guard let displayID = view?.currentDisplayID() else {
                router.finish()
                return
            }
            perform(.display(displayID))
        }
    }

    func didSelect(region: CaptureRegion) {
        view?.hideSelectionOverlay()
        perform(.region(region))
    }

    func didCancel() {
        view?.hideSelectionOverlay()
        router.finish()
    }

    func didRequestOpenSystemSettings() {
        router.openScreenRecordingSettings()
    }

    private func perform(_ request: Request) {
        captureTask = Task {
            do {
                let image: CapturedImage
                switch request {
                case .region(let region): image = try await interactor.captureRegion(region)
                case .display(let id): image = try await interactor.captureDisplay(id)
                }
                if interactor.shouldShowPreview {
                    router.routeToPreview(image: image)
                }
            } catch {
                Log.capture.error("Capture failed: \(error.localizedDescription)")
                view?.showError(message: error.localizedDescription)
            }
            router.finish()
        }
    }
}
