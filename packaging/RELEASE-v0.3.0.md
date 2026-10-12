# Archived release notes: 0.3.0

This broken release has been withdrawn. Install **0.3.2** from
[Releases](https://github.com/amstel8/macosterminalextended/releases/tag/v0.3.2).
See the current [installation instructions](../docs/INSTALLATION.md).

The historical notes below describe 0.3.0.

Extended Terminal 0.3.0 adds Zsh selection and moves settings into System Preferences on Monterey.

- Control + Left / Right: start / end of the shell input line.
- Option + Shift + arrows: select by words in Zsh.
- Control + Shift + arrows: select to the start / end of the Zsh input line.
- Command + arrows and Command + Shift + arrows retain native Terminal behavior.
- Keyboard selections are copied when automatic copying is enabled.
- Native Extended Terminal preference pane; hidden helper under Library/Application Support.
- The installer backs up existing Zsh configuration and appends one marked source block.
- Existing mouse copy, login startup, theme colors, Monaco 12 and theme backups remain.

Keyboard selection affects Zsh's editable input line, not scrollback, SSH sessions without the integration, or full-screen applications. The preference pane is validated on macOS 12 Monterey; newer System Settings versions are not validated.

Validation: 11 mouse selection checks, 9 shortcut checks, an actual ZLE selection test in a PTY, and successful dynamic loading of the preference pane and settings view.

The helper is locally signed, without Developer ID or notarization. After updating, re-add it in Accessibility if macOS rejects the changed code identity.

[Installation](https://github.com/amstel8/macosterminalextended/blob/main/docs/INSTALLATION.md) · [Usage](https://github.com/amstel8/macosterminalextended/blob/main/docs/USAGE.md)
