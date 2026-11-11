import AppKit

@MainActor
final class PreferencesViewController: NSViewController, PreferencesViewProtocol {
    var presenter: PreferencesPresenterProtocol!

    private let formatPopUp = NSPopUpButton(frame: .zero, pullsDown: false)
    private lazy var copyCheckbox = NSButton(
        checkboxWithTitle: "Copy screenshot to clipboard", target: self, action: #selector(copyToggled)
    )
    private lazy var previewCheckbox = NSButton(
        checkboxWithTitle: "Show preview after capture", target: self, action: #selector(previewToggled)
    )
    private let folderLabel = NSTextField(labelWithString: "")
    private let clearButton = NSButton()

    override func loadView() {
        formatPopUp.target = self
        formatPopUp.action = #selector(formatChanged)

        folderLabel.lineBreakMode = .byTruncatingMiddle
        folderLabel.textColor = .secondaryLabelColor
        folderLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let choose = NSButton(title: "Choose…", target: self, action: #selector(chooseTapped))
        clearButton.title = "Clear"
        clearButton.target = self
        clearButton.action = #selector(clearTapped)

        let formatRow = NSStackView(views: [NSTextField(labelWithString: "Format:"), formatPopUp])
        formatRow.spacing = 8

        let folderTitle = NSTextField(labelWithString: "Auto-save to:")
        let folderButtons = NSStackView(views: [folderLabel, choose, clearButton])
        folderButtons.spacing = 8
        let folderRow = NSStackView(views: [folderTitle, folderButtons])
        folderRow.orientation = .vertical
        folderRow.alignment = .leading
        folderRow.spacing = 4

        let root = NSStackView(views: [formatRow, copyCheckbox, previewCheckbox, folderRow])
        root.orientation = .vertical
        root.alignment = .leading
        root.spacing = 14
        root.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        root.widthAnchor.constraint(equalToConstant: 440).isActive = true
        folderButtons.widthAnchor.constraint(equalTo: root.widthAnchor, constant: -40).isActive = true

        view = root
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }

    func render(_ viewModel: PreferencesViewModel) {
        if formatPopUp.itemTitles != viewModel.formatTitles {
            formatPopUp.removeAllItems()
            formatPopUp.addItems(withTitles: viewModel.formatTitles)
        }
        formatPopUp.selectItem(at: viewModel.selectedFormatIndex)
        copyCheckbox.state = viewModel.copyToClipboard ? .on : .off
        previewCheckbox.state = viewModel.showPreview ? .on : .off
        folderLabel.stringValue = viewModel.saveFolderText
        clearButton.isEnabled = viewModel.canClearFolder
    }

    @objc private func formatChanged() { presenter.didSelectFormat(at: formatPopUp.indexOfSelectedItem) }
    @objc private func copyToggled() { presenter.didToggleCopyToClipboard(copyCheckbox.state == .on) }
    @objc private func previewToggled() { presenter.didToggleShowPreview(previewCheckbox.state == .on) }
    @objc private func chooseTapped() { presenter.didTapChooseFolder() }
    @objc private func clearTapped() { presenter.didTapClearFolder() }
}
