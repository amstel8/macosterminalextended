# Archived development notes: 0.3.1

This development build was never published. Install **0.3.2** from
[Releases](https://github.com/amstel8/macosterminalextended/releases/tag/v0.3.2).
See the current [installation instructions](../docs/INSTALLATION.md).

The changes below are included in 0.3.2.

Fixes the Accessibility setup flow for the hidden Extended Terminal service.

- Grant Accessibility now sends a permission request to the helper instead of only opening Privacy settings.
- Displays the exact helper path and instructions for manually adding it when macOS does not list it automatically.
- Registers the installed helper with Launch Services.
- Adds the new terminal icon with a neon-green gear to the helper and System Preferences pane.
