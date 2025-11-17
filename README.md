# MiniMania Desktop Client

MiniMania Desktop Client is a lightweight macOS wrapper around the [minimania.app](https://minimania.app) web experience. It embeds the game inside a `WKWebView` and layers desktop-only quality-of-life automations on top—anti-AFK protections, auto chat helpers, farming macros, zoom presets, and mention highlighting—without needing browser extensions.

## Key Features

- Anti-AFK pulse that periodically simulates focus, mouse activity, and canvas interactions to avoid disconnects.
- Auto Message scheduler with interval control, safe character injection, and on/off feedback tied to the header button.
- Auto Reply keyword listener that injects DOM observers and replies with custom text when incoming chat matches.
- Auto Farming helpers that automate harvest and planting flows, choose seed sources, and sync state with modal controls.
- Mention Highlighter that uses the shared `UserConfig` to highlight chat lines containing the player nickname.
- Zoom Manager with incremental, decremental, and reset actions wired to the header toolbar.
- Players counter that polls the backend service and renders in real time.

## Project Layout

| Path | Purpose |
| --- | --- |
| `main.swift`, `AppDelegate.swift` | App entry point, window/web view bootstrap, feature wiring |
| `Controllers/` | Feature coordinators (auto messaging, reply, farming, zoom, anti-AFK, highlighting) |
| `Views/` | Header toolbar plus modal windows used for feature configuration |
| `Services/JavaScriptInjectionService.swift` | Central place for composing and injecting JavaScript into the loaded page |
| `Models/` | Lightweight config structs shared between the UI and controllers |
| `Extensions/` | `WKNavigationDelegate` and `WKScriptMessageHandler` helpers for observing URL changes |

Each controller depends on `JavaScriptInjectionService` to evaluate sandboxed scripts inside the game canvas, while the header view exposes `NSButton` references that keep the UI state synchronized with controller toggles.

## Requirements

- macOS 13+ (tested on Sonoma)
- Xcode Command Line Tools (for `swiftc` and Cocoa/WebKit frameworks). Install via `xcode-select --install`.

## Build & Run

```bash
./run.sh
```

`run.sh` compiles all Swift sources via `build.sh`, assembles `MiniMania.app` under `build/`, and launches it. To build without running, call `./build.sh` and open the generated app manually (`open build/MiniMania.app`).

## Usage Notes

- The header toolbar (top of the window) exposes buttons for anti-AFK, auto messaging, auto reply, zoom controls, and modals for farming/keyword configuration. Button titles and tint colors reflect the current enablement state.
- Auto Message: open the message modal to author the text, set the interval (minimum 5 seconds), then toggle the feature to start typing/sending loops inside the chat input.
- Auto Reply: set keyword and reply text; when enabled, the controller injects observers and responds whenever incoming chat lines contain the keyword case-insensitively.
- Auto Farming: the modal exposes harvest/plant toggles, seed selection, and source preferences; enabling either option injects observers that interact with the farming UI.
- Mention Highlighting: the `UserConfig` nickname is used by `MentionHighlighterManager` to colorize mentions once per page load automatically.
- Zoom: use the plus/minus/reset buttons to apply CSS zoom within the embedded page.

## Development Tips

- When adding new automations, prefer creating a dedicated controller under `Controllers/` that receives `JavaScriptInjectionService` so that script composition stays centralized.
- Any DOM communication that needs to travel back to Swift can use the script message handler registered in `AppDelegate+WKScriptMessageHandler.swift`.
- Remember to update `build.sh` if you add new top-level directories containing Swift sources.

---

Feel free to adapt the automations to other in-game flows; most logic is isolated inside the controller layer and can be iterated on without touching the main application shell.

