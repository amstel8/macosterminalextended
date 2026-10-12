Fixes the Accessibility setup flow for the hidden Extended Terminal service.

- Grant Accessibility now sends a permission request to the helper instead of only opening Privacy settings.
- Displays the exact helper path and instructions for manually adding it when macOS does not list it automatically.
- Registers the installed helper with Launch Services.
- Adds the new terminal icon with a neon-green gear to the helper and System Preferences pane.

Install the pkg, use Grant Accessibility, and enable the helper in Accessibility.
If it is missing, unlock the list, click **+**, press **Command + Shift + G**,
and paste `/Library/Application Support/Extended Terminal/Extended Terminal.app`.

All copy, Zsh selection, keyboard navigation, theme, and login-startup features from 0.3.0 remain.
