# Changelog

Notable changes to SlowQuitApps are recorded here. Older release notes are
available on the [GitHub releases page](https://github.com/dteoh/SlowQuitApps/releases).

## [0.8.2] - 2026-11-16

### Added

- A release script that creates a signed DMG, matching source archive, and SHA-256 checksums.
- A privacy notice explaining the app's local keyboard-event handling.
- Contributor guidance and community conduct expectations.

### Changed

- Set the minimum supported macOS version to macOS 12.
- Capture the target app when Cmd-Q begins, so changing focus during the delay does not redirect the quit action.
- Package the command-line helper in the app's Resources directory for code signing.

### Fixed

- Pass app names to AppleScript as data instead of interpolating them into script source.
- Correct the keyboard-layout resolver's candidate-array bound and release its copied input source.
- Use the modern app-opening API in the login helper.
- Replace the placeholder failing test with a delay preference assertion.

## [0.8.1] - 2020-12-28

- See the [0.8.1 release](https://github.com/dteoh/SlowQuitApps/releases/tag/v0.8.1) for its original notes.
