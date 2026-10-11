# Usage and troubleshooting

## Settings and background operation

Open **Extended Terminal** from Applications or Spotlight.

The settings window lets you independently enable copying, keyboard shortcuts, and login startup. It also provides buttons to apply the theme again, open permission settings, or quit.

Closing the window leaves the application running. Extended Terminal does not create a menu bar or Dock icon. Clipboard and keyboard actions only affect the active Terminal.app.

## Copy on selection

Select text with the mouse and release the button. The text is copied to the system clipboard; paste normally with **Command + V**.

Spaces and newlines are preserved. Empty selections and returning to Terminal with an existing selection do not overwrite the clipboard.

Selection is checked every 150 ms. Very brief selections may be missed. To copy the same text again, clear the selection before selecting it again.

## Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| Control + Left | Previous tab |
| Control + Right | Next tab |
| Command + Left | Beginning of the input line |
| Command + Right | End of the input line |

Tab shortcuts send Terminal's standard Control + Shift + Tab / Control + Tab.

Line movement sends Control + A / Control + E and targets standard zsh/bash command editing. Inside vim and other programs, these keys follow the application's own bindings.

## Quick check

1. Activate Terminal and wait half a second.
2. Select text, release the mouse, and paste it into TextEdit.
3. Open two tabs and check Control + arrow navigation.
4. Type a command without pressing Return and check Command + arrow movement.

## Troubleshooting

- **Copying does not work:** check the copying toggle and Accessibility permission for the installed application. If necessary, remove the old permission entry and add `/Applications/Extended Terminal.app` again.
- **tmux or vim captures mouse selection:** hold Option to use Terminal's native selection.
- **Keyboard shortcuts do not work:** check the shortcuts toggle and permission status in the settings window. Restart Extended Terminal after granting access.
- **Control + arrows switches desktops:** check for a conflict under system keyboard shortcuts → Mission Control. Disable those conflicting system shortcuts if macOS intercepts them.
- **The theme was not applied:** allow control of Terminal under Automation, then use the apply-theme button in Extended Terminal's settings.
- **The TC icon is still visible:** quit the old Terminal Copy on Select prototype using its menu.

## Accessibility diagnostics

The following prints whether Terminal exposes selected text, without printing the text itself:

```sh
"/Applications/Extended Terminal.app/Contents/MacOS/TerminalCopyOnSelect" --probe
```

When launched directly from a shell, Accessibility permission may belong to the launching terminal rather than the application. This check does not replace checking the installed application's permission.

Selection text is not logged or sent over the network.
