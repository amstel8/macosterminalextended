Extended Terminal 0.3.2 includes the complete keyboard controls, working Accessibility setup, and the new neon-green gear icon.

## Features

- Automatic copying of mouse and Zsh keyboard selections.
- Control + arrows: beginning/end of the input line.
- Option + arrows: backward/forward by words.
- Option + Shift + arrows: select words in Zsh.
- Control + Shift + arrows: select to the line edges in Zsh.
- Control + Up/Down moves to the beginning/end of the entire multiline input; add Shift to select to those edges.
- **Shift + Enter: insert a newline without submitting the command.** Ordinary Enter still submits normally.
- Native Command-arrow combinations are preserved.
- System Preferences pane on Monterey, hidden helper, and login startup.
- Full iTerm Dark profile with Monaco 12, all profile colors, and theme backups.
- Terminal icon with a neon-green gear, also displayed on the preference pane.

## Fixes and packaging

- Grant Accessibility requests access through the helper and includes manual-add instructions.
- Registers the helper with Launch Services.
- Adds the missing Option-arrow movement bindings.
- Backs up and preserves existing Zsh configuration.
- Includes English feature documentation, changelog and AGENTS.md development instructions.

Install **macosterminalextended-0.3.2.pkg**, grant Accessibility to the hidden helper, and open a **new Zsh tab**. Settings are under **System Preferences → Extended Terminal**.

The pkg contains universal Intel/Apple Silicon binaries. The preference pane is validated on macOS 12 Monterey; newer System Settings versions are not validated. Keyboard selection and multiline insertion apply to the editable Zsh command line, not scrollback or full-screen programs.

The package is locally signed without Developer ID or notarization; updates can require a renewed Accessibility grant. SHA256SUMS is attached.

Validation includes 11 helper selection checks, 13 shortcut checks, actual PTY/ZLE tests for movement, selection, multiline insertion and ordinary Enter submission, plus preference-pane loading and bundle signature checks.

The broken 0.3.0 release is removed from downloads. The 0.3.1 development build was not published. Use 0.3.2.

[Feature documentation](https://github.com/amstel8/macosterminalextended/blob/main/docs/FEATURES.md) · [Installation](https://github.com/amstel8/macosterminalextended/blob/main/docs/INSTALLATION.md) · [Changelog](https://github.com/amstel8/macosterminalextended/blob/main/CHANGELOG.md)
