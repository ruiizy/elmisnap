import Carbon.HIToolbox

struct Hotkey: Sendable, Hashable {
    let keyCode: UInt32
    let modifiers: UInt32

    /// Control + Shift + 4
    static let captureArea = Hotkey(
        keyCode: UInt32(kVK_ANSI_4),
        modifiers: UInt32(controlKey | shiftKey)
    )

    /// Control + Shift + 3
    static let captureFullscreen = Hotkey(
        keyCode: UInt32(kVK_ANSI_3),
        modifiers: UInt32(controlKey | shiftKey)
    )
}

@MainActor
protocol HotkeyService: AnyObject {
    /// Returns `false` if the system refused the registration (e.g. already taken).
    @discardableResult
    func register(_ hotkey: Hotkey, handler: @escaping @MainActor () -> Void) -> Bool
    func unregisterAll()
}

/// Global hotkeys via Carbon's `RegisterEventHotKey`: no Accessibility
/// permission required and it works inside the App Sandbox.
@MainActor
final class CarbonHotkeyService: HotkeyService {
    fileprivate var handlers: [UInt32: @MainActor () -> Void] = [:]
    private var hotKeyRefs: [EventHotKeyRef] = []
    private var eventHandler: EventHandlerRef?
    private var nextID: UInt32 = 1

    @discardableResult
    func register(_ hotkey: Hotkey, handler: @escaping @MainActor () -> Void) -> Bool {
        installEventHandlerIfNeeded()

        let id = nextID
        nextID += 1
        let hotKeyID = EventHotKeyID(signature: OSType(0x454C_4D49), id: id) // 'ELMI'
        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(
            hotkey.keyCode,
            hotkey.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &ref
        )
        guard status == noErr, let ref else {
            Log.hotkeys.error("RegisterEventHotKey failed with status \(status)")
            return false
        }
        hotKeyRefs.append(ref)
        handlers[id] = handler
        return true
    }

    func unregisterAll() {
        hotKeyRefs.forEach { UnregisterEventHotKey($0) }
        hotKeyRefs.removeAll()
        handlers.removeAll()
    }

    private func installEventHandlerIfNeeded() {
        guard eventHandler == nil else { return }
        var spec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetApplicationEventTarget(),
            carbonHotkeyHandler,
            1,
            &spec,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
    }
}

private func carbonHotkeyHandler(
    _ nextHandler: EventHandlerCallRef?,
    _ event: EventRef?,
    _ userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let event, let userData else { return OSStatus(eventNotHandledErr) }

    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(
        event,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )
    guard status == noErr else { return status }

    let id = hotKeyID.id
    let service = Unmanaged<CarbonHotkeyService>.fromOpaque(userData).takeUnretainedValue()
    // Application event target events are delivered on the main thread.
    MainActor.assumeIsolated {
        service.handlers[id]?()
    }
    return noErr
}
