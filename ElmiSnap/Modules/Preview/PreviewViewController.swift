import AppKit

@MainActor
final class PreviewViewController: NSViewController, PreviewViewProtocol {
    var presenter: PreviewPresenterProtocol!

    private let imageView = NSImageView()
    private let captionLabel = NSTextField(labelWithString: "")
    private let statusLabel = NSTextField(labelWithString: "")

    override func loadView() {
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)

        captionLabel.textColor = .secondaryLabelColor
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let copy = NSButton(title: "Copy", target: self, action: #selector(copyTapped))
        let save = NSButton(title: "Save…", target: self, action: #selector(saveTapped))
        let close = NSButton(title: "Close", target: self, action: #selector(closeTapped))

        let buttons = NSStackView(views: [statusLabel, copy, save, close])
        buttons.orientation = .horizontal
        buttons.spacing = 8

        let root = NSStackView(views: [imageView, captionLabel, buttons])
        root.orientation = .vertical
        root.alignment = .leading
        root.spacing = 8
        root.edgeInsets = NSEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        imageView.widthAnchor.constraint(equalTo: root.widthAnchor, constant: -24).isActive = true
        buttons.widthAnchor.constraint(equalTo: root.widthAnchor, constant: -24).isActive = true
        imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true

        view = root
        preferredContentSize = NSSize(width: 480, height: 360)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }

    func render(_ viewModel: PreviewViewModel) {
        imageView.image = NSImage(cgImage: viewModel.image, size: viewModel.pointSize)
        captionLabel.stringValue = viewModel.caption
    }

    func showStatus(_ text: String) {
        statusLabel.stringValue = text
    }

    @objc private func copyTapped() { presenter.didTapCopy() }
    @objc private func saveTapped() { presenter.didTapSave() }
    @objc private func closeTapped() { presenter.didTapClose() }
}
