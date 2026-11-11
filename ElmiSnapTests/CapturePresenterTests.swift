import CoreGraphics
import Testing
@testable import ElmiSnap

@MainActor
struct CapturePresenterTests {
    private let view = MockCaptureView()
    private let interactor = MockCaptureInteractor()
    private let router = MockCaptureRouter()
    private let region = CaptureRegion(displayID: 42, rect: CGRect(x: 10, y: 20, width: 100, height: 50))

    private func makePresenter(mode: CaptureMode = .area) -> CapturePresenter {
        let presenter = CapturePresenter(mode: mode, interactor: interactor, router: router)
        presenter.view = view
        return presenter
    }

    @Test func startWithoutPermissionShowsAlertAndFinishes() {
        interactor.hasScreenRecordingAccess = false
        let sut = makePresenter()

        sut.start()

        #expect(interactor.requestAccessCount == 1)
        #expect(view.permissionAlertCount == 1)
        #expect(!view.overlayShown)
        #expect(router.finishCount == 1)
    }

    @Test func startInAreaModeShowsOverlay() {
        let sut = makePresenter(mode: .area)

        sut.start()

        #expect(view.overlayShown)
        #expect(router.finishCount == 0)
    }

    @Test func startInFullscreenModeCapturesDisplayUnderCursor() async {
        let sut = makePresenter(mode: .fullscreen)

        sut.start()
        await sut.captureTask?.value

        #expect(!view.overlayShown)
        #expect(interactor.capturedDisplays == [42])
        #expect(router.previewImages.count == 1)
        #expect(router.finishCount == 1)
    }

    @Test func selectingRegionCapturesAndShowsPreview() async {
        let sut = makePresenter()

        sut.didSelect(region: region)
        await sut.captureTask?.value

        #expect(view.overlayHidden)
        #expect(interactor.capturedRegions == [region])
        #expect(router.previewImages.count == 1)
        #expect(router.finishCount == 1)
    }

    @Test func skipsPreviewWhenDisabledInSettings() async {
        interactor.shouldShowPreview = false
        let sut = makePresenter()

        sut.didSelect(region: region)
        await sut.captureTask?.value

        #expect(router.previewImages.isEmpty)
        #expect(router.finishCount == 1)
    }

    @Test func captureFailureShowsErrorAndFinishes() async {
        interactor.result = .failure(TestError())
        let sut = makePresenter()

        sut.didSelect(region: region)
        await sut.captureTask?.value

        #expect(view.errorMessages == ["boom"])
        #expect(router.previewImages.isEmpty)
        #expect(router.finishCount == 1)
    }

    @Test func cancelHidesOverlayAndFinishes() {
        let sut = makePresenter()

        sut.didCancel()

        #expect(view.overlayHidden)
        #expect(router.finishCount == 1)
        #expect(interactor.capturedRegions.isEmpty)
    }

    @Test func openSystemSettingsRoutesThroughRouter() {
        let sut = makePresenter()

        sut.didRequestOpenSystemSettings()

        #expect(router.openSettingsCount == 1)
    }
}
