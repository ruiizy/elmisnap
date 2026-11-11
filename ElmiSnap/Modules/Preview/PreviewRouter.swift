import AppKit

@MainActor
final class PreviewRouter: PreviewRouterProtocol {
    private weak var appRouter: AppRouting?

    init(appRouter: AppRouting) {
        self.appRouter = appRouter
    }

    func askSaveLocation(suggestedName: String, format: ImageFormat) -> URL? {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = suggestedName
        panel.allowedContentTypes = [format.utType]
        panel.canCreateDirectories = true
        return panel.runModal() == .OK ? panel.url : nil
    }

    func close() {
        appRouter?.closePreview()
    }
}
