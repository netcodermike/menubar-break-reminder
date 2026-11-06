# Menu Bar Break Reminder

Keep a focus/break countdown in the menu bar, pause it, snooze reminders, and display a small break panel.

[![Build and verify](https://github.com/netcodermike/menubar-break-reminder/actions/workflows/verify.yml/badge.svg)](https://github.com/netcodermike/menubar-break-reminder/actions/workflows/verify.yml)

**Language:** Swift · **Platform:** macOS 13+ · **App type:** Native macOS menu bar utility

First-release learning implementation, with explicit scope below. This is one independently runnable app, not a placeholder in a combined repository.

## Features

- Menu bar countdown for focus and break periods.
- 25/50-minute work presets, five-minute breaks, pause/resume, and snooze.
- Floating break panel with a sound cue.
- A pure clock model tested without opening the application UI.

## Requirements

macOS 13+ and Xcode command-line tools supporting Swift 5.9+. AppKit is required. No packages.

## Quick start

```sh
git clone https://github.com/netcodermike/menubar-break-reminder.git
cd menubar-break-reminder
swift build
swift run BreakReminder
# Quit through the menu bar item when finished.
```

Commands run from the repository root. Lines marked for a particular operating system apply only there. Language tools are prerequisites, not installed by the app. Close desktop windows normally; terminal/server apps stop with Ctrl+C unless their usage notes say otherwise.

## Example workflow

Launch and locate the Focus countdown in the menu bar. Pause, wait, and resume; the remaining time should stay unchanged while paused. Snooze should show five minutes of work. For quick manual testing locally, temporarily reduce model defaults in a development copy, then verify break panel and automatic return to work.

## Architecture, configuration, and data

`Sources/BreakReminder/App.swift` contains a value-type BreakClock and an AppKit application delegate. The application entry point runs on Swift's main actor. A one-second Timer updates the status item from wall-clock deadlines, rather than decrementing counters. When a focus deadline expires the clock enters a five-minute break and shows a panel. When the break expires it returns to focus automatically. Snooze starts a five-minute work period. NSApplication uses accessory activation policy, so there is no Dock icon. The app writes no files, makes no network requests, and requests no notification permission.

## Verification

Build with the quick-start command where needed, then run:

```sh
swift run BreakReminder --self-test
```

Manual acceptance: Verify menu visibility, both work presets, pause/resume, snooze, the break panel close button, quit, and behavior after Mac sleep.

See [validation record](docs/VALIDATION.md) for observed checks and their limits. CI results verify only what the workflow runs; they do not establish native GUI correctness or production readiness.

## Limitations and next steps

No launch-at-login installation, signed app bundle, persistent settings, calendar integration, notification-center delivery, or activity monitoring. Relaunch resets the timer. A sleeping Mac crosses deadlines only when the app wakes/ticks and starts the next phase from that tick; it does not replay missed cycles. Closing the break panel hides it but does not cancel the break. Reminder visibility and sound depend on the current desktop/audio environment.

## Troubleshooting

Install Xcode command-line tools if swift or the SDK is unavailable. Look in the menu bar rather than the Dock. A terminal-only session can run --self-test but cannot show the UI. Choose Quit from the status menu to stop the process. --self-test must be passed after the executable name.

## Source map

- `Package.swift`
- `Sources/BreakReminder/App.swift`

## Development and license

Read [contributing](CONTRIBUTING.md) before changing the app, and [security/privacy](SECURITY.md) before supplying private data. Use synthetic fixtures for tests. No telemetry, paid API key, or account is required by the app itself. Dependencies, when present, are stated in Requirements.

[MIT license](LICENSE), copyright 2026 netcodermike.
