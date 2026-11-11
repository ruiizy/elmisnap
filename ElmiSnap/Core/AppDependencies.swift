import Foundation

/// Shared services, created once by the composition root and injected into
/// module builders. Plain struct, no DI framework.
@MainActor
struct AppDependencies {
    let permission: PermissionService
    let screenCapture: ScreenCaptureService
    let hotkeys: HotkeyService
    let clipboard: ClipboardService
    let fileStorage: FileStorageService
    let settings: SettingsStore

    static func live() -> AppDependencies {
        AppDependencies(
            permission: SystemPermissionService(),
            screenCapture: ScreenCaptureKitService(),
            hotkeys: CarbonHotkeyService(),
            clipboard: PasteboardClipboardService(),
            fileStorage: ImageIOFileStorageService(),
            settings: UserDefaultsSettingsStore()
        )
    }
}
