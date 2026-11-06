# Validation

Authoring date: November 6, 2026. Host: Windows. Target: macOS 13+.

## Local result

macOS/Swift unavailable on authoring host. CI performs a native release build and tests clock transitions.

## Reproducible checks

The GitHub Actions workflow builds/runs the following on `macos-latest`:

```sh
swift build -c release
swift run -c release BreakReminder --self-test
```

## Manual acceptance

Verify menu visibility, both work presets, pause/resume, snooze, the break panel close button, quit, and behavior after Mac sleep.

A workflow file is not evidence of a passing run. Observed CI run links and source commits are recorded after publication. Native GUI, sound, sleep/resume, and platform permissions require direct target-platform acceptance even when model tests pass.

## Observed CI result

Passed on November 6, 2026: [target-platform build/check](https://github.com/netcodermike/menubar-break-reminder/actions/runs/42199188442).

Verified source commit: `f10bab92fe4bd36f27be7e90458ac46c862bac91`. This evidence identifies the exact tested source; a later documentation-only commit does not change that source.

The commands listed above passed. Native GUI/manual acceptance is not claimed by this CI result.
