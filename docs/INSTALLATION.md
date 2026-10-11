# Installation and upgrades

## Requirements

- macOS 12 Monterey or later, on Intel or Apple Silicon.
- Apple's Terminal.app.
- Administrator access to install into Applications.

## Installation

1. Open the [latest release](https://github.com/amstel8/macosterminalextended/releases/latest).
2. Download and open `macosterminalextended-0.2.0.pkg`.
3. Complete the installer. It installs `/Applications/Extended Terminal.app` and starts it in the background.
4. On Monterey, open **System Preferences → Security & Privacy → Privacy → Accessibility** and enable **Extended Terminal**. If it is missing, add the installed application with the **+** button.
5. Allow Extended Terminal to control **Terminal** when asked. This permission appears under **Automation** and is required to apply the theme.
6. Switch to Terminal, wait half a second, and follow the [usage checks](USAGE.md).

Settings names and locations can differ on newer macOS versions. The installer cannot grant these permissions on your behalf.

The installer is currently distributed without a Developer ID signature or notarization.

## Installed files and changes

- Application: `/Applications/Extended Terminal.app`.
- Login startup for the user signed in during installation: `~/Library/LaunchAgents/dev.local.ExtendedTerminal.plist`.
- Terminal profile: **iTerm Dark**, including Monaco 12, background, selection, cursor, normal and bold text, and all ANSI colors.
- Theme backup: `~/Library/Application Support/Extended Terminal/Backups/`.

The theme applies to open tabs and becomes the default for new and startup windows. Importing a profile can add a numeric suffix to its name.

Monaco is a macOS system font; no font files are installed. SIMBL and changes to macOS security protections are not required.

If no user is signed in during installation, open Extended Terminal manually afterward and enable login startup in its settings.

## Upgrading from the prototype

A **TC** or **TC!** menu bar icon belongs to the early **Terminal Copy on Select** prototype launched from a build directory.

The new application attempts to stop the old process with the same bundle identifier. If the icon remains, choose **Quit** from the old icon's menu, then launch Extended Terminal.

macOS may require you to grant Accessibility permission again after an update. Make sure the allowed application is the copy in `/Applications`, rather than an old build.

## Removal

Open Extended Terminal's settings, disable login startup, quit the application, and delete it from Applications.

The Terminal profile and theme backups remain. Select your previous profile in Terminal's settings to restore its appearance.
