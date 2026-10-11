# macosterminalextended

**Extended Terminal** adds copy on selection, keyboard shortcuts, and a complete dark profile to Apple's Terminal.app. It runs in the background without a menu bar or Dock icon.

[Download the installer](https://github.com/amstel8/macosterminalextended/releases/latest) · [Installation](docs/INSTALLATION.md) · [Usage and troubleshooting](docs/USAGE.md)

## Features

- Copy selected text when you release the mouse.
- **Control + Left / Right** switches to the previous / next tab.
- **Command + Left / Right** moves to the beginning / end of the shell input line.
- Copying and shortcuts only apply while Terminal.app is active.
- Includes the iTerm Dark profile with **Monaco 12**, selection and cursor colors, background, text colors, and the full 16-color ANSI palette.
- Includes login startup, a settings window, and a backup before applying the theme.

## Install

Download `macosterminalextended-0.2.0.pkg` from [Releases](https://github.com/amstel8/macosterminalextended/releases/latest) and run it. The universal application supports **Intel and Apple Silicon on macOS 12 or later**.

Grant **Accessibility** access to Extended Terminal. Allow it to control Terminal under **Automation** to apply the theme. macOS requires you to grant these permissions yourself.

Open **Extended Terminal** from Applications or Spotlight to access settings. Closing the settings window leaves the background service running.

If a **TC** icon remains in the menu bar, the early **Terminal Copy on Select** prototype is still running. Quit it from its menu; the installed Extended Terminal does not create this icon.

See the [installation guide](docs/INSTALLATION.md) for permissions, upgrades, installed files, and removal.

## Build

Requires Xcode Command Line Tools. No third-party dependencies.

```sh
zsh build.sh        # Application for the current architecture
zsh build-pkg.sh    # Universal installer for Intel and Apple Silicon
```

The application is built under `build/Extended Terminal.app`. The installer and its SHA-256 checksum are written to `dist/`.

The build runs 11 selection checks and 8 shortcut mapping checks. GUI behavior requires Accessibility access. The package is locally built, without a Developer ID signature or notarization.

The application's bundle identifier is retained from the initial prototype for upgrade compatibility.

## Limits

Selection is checked every 150 ms. Very brief selections may be missed. Returning to Terminal with an existing selection does not overwrite the clipboard.

Command + arrow shortcuts send Control + A / E. They target standard zsh/bash command editing; applications such as vim define their own behavior for these keys.

Selection text is not written to logs or sent over the network.

See [usage and troubleshooting](docs/USAGE.md) and the [changelog](CHANGELOG.md).
