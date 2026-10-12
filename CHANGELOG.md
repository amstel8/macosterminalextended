# Changelog

## 0.3.2

### Added

- Shift + Return/Enter inserts a newline into Zsh input without submitting the command.
- Option + Left/Right moves by words; Option + Shift selects by words.
- Control + Left/Right moves to line edges; Control + Shift selects to line edges.
- Control + Up/Down moves to the beginning/end of the entire multiline input; Control + Shift selects to those edges.
- Native Monterey System Preferences pane, with a hidden background helper.
- Neon-green gear over a terminal icon, included in the application, settings and repository.
- English feature documentation and AGENTS.md development/release instructions.
- PTY tests for actual movement, selection, multiline insertion and normal Return submission.

### Fixed

- Grant Accessibility now requests permission from the helper and explains manual addition.
- Registers the hidden helper with Launch Services during installation.
- Preserves native Command-arrow shortcuts and the existing Terminal colors and Monaco 12 font.
- Preserves and backs up Zsh configuration and theme settings.

### Distribution

- Universal Intel/Apple Silicon pkg, with SHA-256 checksum.
- Settings are under System Preferences; the service starts at login without menu bar or Dock icons.
- Withdrawn broken 0.3.0 release downloads; 0.3.1 development builds are not published. Use 0.3.2.

## 0.2.0

- Initial background helper, copy on selection, keyboard mappings, dark theme and installer.
