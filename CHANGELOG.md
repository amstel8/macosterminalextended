# Changelog

## 0.3.1

- Grant Accessibility now requests permission through the running helper.
- Added explicit manual-add instructions for background services missing from the Accessibility list.
- Register the hidden helper with Launch Services during installation.
- Added a generated neon-green gear over a terminal icon to the helper and preference pane.

## 0.3.0

- Control + arrows now moves to the beginning/end of the input line.
- Removed all Command + arrow interception and the old Control + arrow tab mapping.
- Added Option + Shift word selection and Control + Shift line selection in Zsh.
- Keyboard selections are copied to the clipboard when copying is enabled.
- Added a native System Preferences pane for Monterey.
- Moved the background helper out of Applications and into Library/Application Support.
- Added a backed-up, idempotent Zsh configuration source block.
- Retained the existing theme colors and added four selection key sequences.

## 0.2.0

- Initial background helper, copy on selection, tab and line shortcuts.
- Universal pkg, iTerm Dark profile, theme backup and login startup.
