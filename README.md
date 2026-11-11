# ElmiSnap

Native macOS screenshot app, built to fit workflows the built-in tool does not cover.

Menu bar app (no Dock icon). Area and fullscreen capture through ScreenCaptureKit, global hotkeys, clipboard / auto-save, and a preview window after each capture.

## Status

Early stage. Scaffolding and a minimal capture flow work; no annotation, history or video yet.

| Action | Hotkey |
| --- | --- |
| Capture area | `⌃⇧4` |
| Capture fullscreen | `⌃⇧3` |

The first capture asks for **Screen Recording** permission (System Settings → Privacy & Security).

## Requirements

- macOS 14+
- Xcode 16+ (Swift 6)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

## Build

The `.xcodeproj` is generated from `project.yml` and not committed.

```bash
xcodegen generate
open ElmiSnap.xcodeproj
```

Command line:

```bash
xcodebuild -scheme ElmiSnap -destination 'platform=macOS' build test
```

Re-run `xcodegen generate` after adding or removing source files.

## Architecture

**VIPER** on **AppKit** (UIKit does not run natively on macOS). Every feature is a module under `ElmiSnap/Modules/<Name>/`:

| Piece | Role |
| --- | --- |
| `…Contract.swift` | All protocols of the module |
| View (`…ViewController`) | Dumb AppKit UI; forwards events to the Presenter |
| Interactor | Business logic; depends only on service protocols |
| Presenter | Formats for the View, decides the flow, calls the Router |
| Router | Navigation; talks to other modules only through `AppRouting` |
| Builder | Wires the module (View → Presenter strong, Presenter → View weak) |

```
ElmiSnap/
  App/        main.swift, AppDelegate, AppRouter (composition root), AppRouting
  Core/       AppDependencies, Logger, window helpers
  Entities/   CaptureMode, CaptureRegion, CapturedImage, AppSettings
  Services/   ScreenCapture (ScreenCaptureKit), Hotkey (Carbon), Permission,
              Clipboard, FileStorage, SettingsStore
  Modules/    MenuBar, Capture, Preview, Preferences
ElmiSnapTests/  Presenter tests with mock View / Interactor / Router
```

Services sit behind protocols and are injected through `AppDependencies`; no DI framework.

## License

TBD
