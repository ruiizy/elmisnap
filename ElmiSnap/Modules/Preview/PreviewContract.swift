import CoreGraphics
import Foundation

struct PreviewViewModel {
    let image: CGImage
    let pointSize: CGSize
    let caption: String
}

@MainActor
protocol PreviewViewProtocol: AnyObject {
    func render(_ viewModel: PreviewViewModel)
    func showStatus(_ text: String)
}

@MainActor
protocol PreviewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapCopy()
    func didTapSave()
    func didTapClose()
}

@MainActor
protocol PreviewInteractorProtocol: AnyObject {
    var image: CapturedImage { get }
    var imageFormat: ImageFormat { get }
    var suggestedFileName: String { get }
    func copyToClipboard()
    func save(to url: URL) throws
}

@MainActor
protocol PreviewRouterProtocol: AnyObject {
    /// Returns `nil` if the user cancels.
    func askSaveLocation(suggestedName: String, format: ImageFormat) -> URL?
    func close()
}
