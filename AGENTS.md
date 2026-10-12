# Repository instructions

## Project and layout

Extended Terminal extends Apple's Terminal.app on macOS 12 Monterey.
The hidden Swift helper provides mouse copying and Control-arrow interception.
The Objective-C preference pane lives in System Preferences. Zsh widgets provide
keyboard selection and multiline input. The project builds universal Intel/Apple
Silicon binaries and a pkg installer.

- `Sources/main.swift`: helper, Accessibility, clipboard, event tap, and service state.
- `PreferencePane/`: native Monterey preference pane and its bundle metadata.
- `Resources/`: Terminal profile, theme application, Zsh integration and vendored code.
- `Assets/ExtendedTerminal.png`: generated icon; preserve alpha and green gear.
- `packaging/`: installer scripts, welcome page, and release notes.
- `tests/`: actual PTY/ZLE tests and preference-pane load smoke test.
- `docs/`: English installation, usage and feature documentation; Russian counterparts under `docs/ru/`.

## Implementation rules

1. Keep English as the default documentation language. Maintain `README.ru.md`
   and Russian installation, usage and feature documentation under `docs/ru/`.
   Add reciprocal language links and keep both versions consistent when changing
   documented behavior. Keep repository instructions, changelog and release notes
   in English unless the user requests translations.
2. Keep the helper out of Applications. It belongs under
   `/Library/Application Support/Extended Terminal/Extended Terminal.app`.
3. Keep settings under `/Library/PreferencePanes/Extended Terminal.prefPane`.
   Do not add a menu bar or Dock icon.
4. Preserve the helper bundle identifier and preference domain
   `dev.local.TerminalCopyOnSelect`. Changing either needs a migration plan.
5. Use supported Accessibility APIs. Do not grant permissions through TCC database
   edits, disable SIP, or introduce private API injection. The user grants access.
6. A locally signed update can invalidate Accessibility grants. Verify the installed
   helper's actual access and explain manual addition when needed. Opening Privacy
   settings alone does not request permission: the helper must receive `access`.
7. Keep the event tap limited to active Terminal and exact modifier combinations.
   Command-arrow shortcuts must pass through unchanged.
8. Preserve all appearance settings when changing `keyMapBoundKeys`. The `.terminal`
   file is a binary property list; use a plist parser rather than text replacements.
9. Run Zsh integration only in interactive Zsh with `TERM_PROGRAM=Apple_Terminal`.
   Preserve shell configuration, back it up, and use one marked source block.
   Never inject commands into a live user shell merely to reload widgets.
10. Preserve vendored copyright and MIT license notices. Do not log or transmit
    clipboard contents or typed commands.

## Build and verification

Requires Xcode Command Line Tools. Python is used only for development tests.

```sh
zsh build.sh
python3 tests/check_shell_selection.py
sh -n packaging/scripts/postinstall
zsh build-pkg.sh
```

The build runs helper self-tests. The PTY test checks real ZLE state, including
word movement, selection, multiline insertion and command submission behavior.
It must not change the user's clipboard. For pane changes, compile and run:

```sh
xcrun clang -fobjc-arc -framework Cocoa -framework PreferencePanes tests/check_pane.m -o build/check-pane
build/check-pane "$PWD/build/Extended Terminal.prefPane"
```

Verify both bundle signatures and the pkg's contents before publishing. Some
sandbox environments block ImageIO codecs used by sips/iconutil; request the
appropriate escalation instead of replacing the image or bypassing permissions.
GUI tests require the installed helper's permission; shell launches can inherit
the launching terminal's TCC identity and are not equivalent.

## Releases

The current requested release is **0.3.2**. Keep the short app version, pkg version,
asset filename, documentation and release notes consistent. Keep `CFBundleVersion`
monotonic when replacing a published release build.

1. Update `CHANGELOG.md`, `docs/FEATURES.md`, and `packaging/RELEASE-v0.3.2.md`.
2. Build `dist/macosterminalextended-0.3.2.pkg` and `dist/SHA256SUMS`.
3. Check the checksum and make sure build artifacts are ignored by Git.
4. Commit and push sources. Ensure tag `v0.3.2` identifies the packaged source.
5. Publish/update the GitHub release with the pkg, checksum, and English notes.
6. Replacing an existing tag or release asset needs explicit user authorization.
7. After verifying 0.3.2 is published, withdraw broken releases 0.3.0 and 0.3.1
   if present. The user explicitly requests removing those release downloads;
   retain source tags unless separately asked to remove them.

Do not publish or install a new build just because a user asks for an explanation.
For authorized profile-only local fixes, prefer applying the profile without
re-signing the already trusted helper.
