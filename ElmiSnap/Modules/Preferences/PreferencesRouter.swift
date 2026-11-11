import AppKit

@MainActor
final class PreferencesRouter: PreferencesRouterProtocol {
    func chooseDirectory(current: URL?) -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose"
        panel.directoryURL = current
        return panel.runModal() == .OK ? panel.url : nil
    }
}
