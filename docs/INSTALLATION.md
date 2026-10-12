# Installation and upgrades

## Requirements

- macOS 12 Monterey, Intel or Apple Silicon.
- Apple's Terminal.app; interactive Zsh for keyboard selection.
- Administrator access to install the helper and preference pane.

## Install

1. Download `macosterminalextended-0.3.2.pkg` from [Releases](https://github.com/amstel8/macosterminalextended/releases/latest) and complete the installer.
2. Open **System Preferences → Extended Terminal**.
3. Use **Grant Accessibility** to reveal the hidden helper and open permission settings.
4. Unlock **Security & Privacy → Privacy → Accessibility**. Add the revealed **Extended Terminal.app** and enable its checkbox.
   If it is not listed, click **+**, press **Command + Shift + G**, paste
   `/Library/Application Support/Extended Terminal/Extended Terminal.app`,
   choose **Open**, and enable the green-gear application's checkbox.
   The macOS prompt does not guarantee automatic insertion into this list.
5. Allow Extended Terminal to control Terminal under **Automation** to apply the theme.
6. Open a new Zsh tab to load keyboard selection.

macOS requires you to grant permissions yourself. The package is not Developer ID signed or notarized. The preference pane is validated on Monterey; newer System Settings versions are not validated.

## Installed files

- Helper: `/Library/Application Support/Extended Terminal/Extended Terminal.app`.
- Settings: `/Library/PreferencePanes/Extended Terminal.prefPane`.
- Login startup: `~/Library/LaunchAgents/dev.local.ExtendedTerminal.plist`.
- Shell integration: a marked **BEGIN/END Extended Terminal** block appended to `~/.zshrc`.
- Existing shell configuration backup: `~/.zshrc.extended-terminal-backup-TIMESTAMP`.
- Theme backups: `~/Library/Application Support/Extended Terminal/Backups/`.

No app is installed into Applications. The helper is still an application bundle because macOS uses it as the identity for Accessibility permission.

The iTerm Dark profile preserves Monaco 12 and the original profile colors. It additionally configures the four selection key sequences. The theme applies to open tabs and becomes the default for new and startup windows. Monaco is already included with macOS.

The installer adds login startup and shell configuration for the signed-in user. Other users can enable startup from the preference pane; the shell source block must be added to their own Zsh configuration.

If you use a custom `ZDOTDIR`, source the helper's `Contents/Resources/extended-terminal.zsh` from your active Zsh configuration instead of the default `~/.zshrc`.

## Upgrade from 0.2

The installer migrates the helper out of Applications and removes only the old application with the matching bundle identifier. It preserves settings and updates login startup.

Re-add the hidden helper to Accessibility if access stops working after an update; locally signed builds can have a different code identity.

## Removal

Disable login startup and stop the service in the preference pane. Remove the installed helper and preference pane with administrator access. Remove the marked Extended Terminal block from your Zsh configuration, then open a new shell.

The Terminal profile and backups remain. Select your previous profile in Terminal's settings to restore its appearance.
