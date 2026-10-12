# Usage and troubleshooting

## Settings

Open **System Preferences → Extended Terminal** on Monterey.

You can toggle mouse copying, keyboard shortcuts and selection, and login startup. Buttons grant Accessibility access, apply the theme, start the service, or stop it. The pane displays the service's permission status.

No menu bar or Dock icon is created. The helper is stored under Library/Application Support.

## Shortcuts

| Shortcut | Action |
| --- | --- |
| Control + Left | Start of the input line |
| Control + Right | End of the input line |
| Option + Shift + Left / Right | Extend or shrink Zsh selection by words |
| Control + Shift + Left / Right | Select to the start / end of the input line |

Command + arrows and Command + Shift + arrows are passed through unchanged, preserving Terminal's native shortcuts.

Selection requires a new interactive Zsh tab after installation and the installed Terminal profile. It applies to the editable command line, not scrollback or full-screen programs. The selected region is highlighted by Zsh and copied to the system clipboard when automatic copying is enabled. Backspace or Delete removes the region; ordinary movement clears selection.

Line movement sends Control + A / E. Applications such as vim define their own behavior for these keys.

## Copying

Mouse-select text and release the button, then paste with Command + V. Spaces and newlines are preserved. Empty selections and returning to an existing selection do not overwrite the clipboard.

The helper checks mouse selection every 150 ms. Very brief selections can be missed. To copy identical text again, clear the selection before selecting it again.

## Quick check

1. Activate Terminal and wait half a second.
2. Mouse-select text, release, and paste into TextEdit.
3. Open a new Zsh tab, type a command without Return, and try Control + arrows.
4. Try Option + Shift + arrows and Control + Shift + arrows, then paste into TextEdit.
5. Confirm Command + Shift + arrows still follow Terminal's native behavior.

## Troubleshooting

- **Copying stopped after an update:** remove the old Accessibility entry and add `/Library/Application Support/Extended Terminal/Extended Terminal.app` again using Grant Accessibility.
- **Selection sequences appear as text:** open a new Zsh tab and apply the bundled Terminal profile. Keyboard selection is not installed into SSH hosts or other shells.
- **tmux/vim captures mouse selection:** hold Option to use Terminal's native selection.
- **Control + arrows switches desktops:** check Mission Control shortcuts if macOS intercepts them.
- **The theme was not applied:** allow control of Terminal under Automation and use Apply Terminal theme.
- **An old TC icon remains:** quit the early Terminal Copy on Select prototype from its menu.

## Diagnostics

```sh
"/Library/Application Support/Extended Terminal/Extended Terminal.app/Contents/MacOS/TerminalCopyOnSelect" --probe
```

This reports Accessibility support without printing selected text. Direct shell launches can use the launching terminal's permission rather than the helper's permission.

Selection text is not logged or sent over the network.
