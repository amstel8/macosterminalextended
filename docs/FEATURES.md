# Features

Extended Terminal enhances Apple's Terminal on macOS 12 Monterey. It runs as a
hidden background helper and provides a native System Preferences pane.

## Keyboard controls

| Shortcut | Behavior |
| --- | --- |
| Control + Left / Right | Move to the beginning / end of the input line |
| Control + Up / Down | Move to the beginning / end of the entire multiline input |
| Option + Left / Right | Move backward / forward by words |
| Option + Shift + Left / Right | Extend or shrink selection by words in Zsh |
| Control + Shift + Left / Right | Select to the beginning / end of the Zsh input line |
| Control + Shift + Up / Down | Select to the beginning / end of the entire Zsh input |
| Shift + Return / Enter | Insert a newline into the Zsh input buffer without submitting it |
| Return / Enter | Submit input normally |

Command-arrow combinations are not intercepted. Terminal's native Command and
Command + Shift shortcuts remain available.

Keyboard selection and multiline insertion work in interactive Zsh under
Terminal.app. Open a new tab after installation. They do not apply to terminal
scrollback, remote shells without the integration, or full-screen applications.

Shift + Enter inserts an actual newline, without adding a continuation backslash.
Press ordinary Enter when you want the shell to execute or parse the buffer.

## Automatic copying

- Mouse selections are copied after you release the mouse button.
- Zsh keyboard selections are copied when automatic copying is enabled.
- Spaces and newlines are preserved.
- Empty selections do not clear the clipboard.
- Returning to Terminal with an existing selection does not overwrite the clipboard.
- Backspace/Delete removes a selected Zsh region; ordinary movement clears selection.

Mouse selection is sampled every 150 ms, so very brief selections may be missed.
Selection text and typed commands are not logged or sent over the network.

## Settings and appearance

Open **System Preferences → Extended Terminal** on Monterey to toggle copying,
keyboard features, and login startup; start/stop the service; grant Accessibility;
or reapply the theme.

The app uses a dark terminal icon with a neon-green gear. No menu bar or Dock icon
is created, and no app is installed into Applications.

The bundled iTerm Dark profile includes Monaco 12, selection and cursor colors,
normal/bold text, background and all 16 ANSI colors. Theme settings are backed up
before application. The existing Zsh configuration is backed up before adding a
marked source block.

The pkg includes universal Intel and Apple Silicon binaries. The preference pane
is validated on macOS 12 Monterey; newer System Settings versions are not validated.

## Required permissions

The helper requires Accessibility for mouse copying and keyboard interception.
Automation access to Terminal is required to apply its profile. macOS requires
the user to grant these permissions; the installer cannot grant them.

If the helper does not appear in Accessibility, use **+ → Command + Shift + G**
and add `/Library/Application Support/Extended Terminal/Extended Terminal.app`.

See [installation](INSTALLATION.md) and [usage](USAGE.md) for details.
