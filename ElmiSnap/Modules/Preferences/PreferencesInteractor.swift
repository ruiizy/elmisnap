import Foundation

@MainActor
final class PreferencesInteractor: PreferencesInteractorProtocol {
    private let store: SettingsStore

    init(store: SettingsStore) {
        self.store = store
    }

    var settings: AppSettings { store.settings }

    func update(_ change: (inout AppSettings) -> Void) {
        var updated = store.settings
        change(&updated)
        store.settings = updated
    }
}
