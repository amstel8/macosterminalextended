First public release of Extended Terminal for macOS 12 Monterey and later.

## Features

- Copy selected text when you release the mouse.
- Control + Left / Right: previous / next Terminal tab.
- Command + Left / Right: beginning / end of the shell input line.
- Complete iTerm Dark profile with Monaco 12, background, selection, cursor, and ANSI colors.
- Background operation without a menu bar or Dock icon.
- Login startup, settings, and a backup before applying the theme.

## Installation

Download and run **macosterminalextended-0.2.0.pkg**. It includes a universal application for Intel and Apple Silicon.

Grant Extended Terminal **Accessibility** access and allow it to control Terminal under **Automation** to apply the theme. Open Extended Terminal from Applications to access settings.

See the [installation guide](https://github.com/amstel8/macosterminalextended/blob/main/docs/INSTALLATION.md) and [usage guide](https://github.com/amstel8/macosterminalextended/blob/main/docs/USAGE.md).

The package is locally built without Developer ID signing or notarization. The SHA-256 checksum is attached as **SHA256SUMS**.

## Validation

- 11 selection logic checks and 8 keyboard mapping checks.
- Both architectures, application signature, installer contents, and script syntax checked.
- All 35 theme settings match the original Terminal profile.
- Copying confirmed by the user on macOS 12.7.6; keyboard shortcuts require a live Terminal check after granting access.

Command + arrow shortcuts send Control + A / E. Applications such as vim define their own behavior for these keys.
