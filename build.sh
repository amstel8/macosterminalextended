#!/bin/zsh
set -eu
cd "${0:A:h}"
app_path="$PWD/build/Extended Terminal.app"
build_arch="${BUILD_ARCH:-$(uname -m)}"
mkdir -p "$app_path/Contents/MacOS" "$app_path/Contents/Resources"
if [[ "${BUILD_UNIVERSAL:-0}" == 1 ]]; then
    for build_arch in x86_64 arm64; do
        xcrun swiftc -O -target "$build_arch-apple-macosx12.0" -framework AppKit -framework ApplicationServices Sources/main.swift -o "build/ExtendedTerminal-$build_arch"
    done
    lipo -create build/ExtendedTerminal-x86_64 build/ExtendedTerminal-arm64 -output "$app_path/Contents/MacOS/TerminalCopyOnSelect"
else
    xcrun swiftc -O -target "$build_arch-apple-macosx12.0" -framework AppKit -framework ApplicationServices Sources/main.swift -o "$app_path/Contents/MacOS/TerminalCopyOnSelect"
fi
cp Info.plist "$app_path/Contents/Info.plist"
ditto Resources "$app_path/Contents/Resources"
iconset_path="$PWD/build/ExtendedTerminal.iconset"
mkdir -p "$iconset_path"
for icon_size in 16 32 128 256 512; do
    sips -s format png -z "$icon_size" "$icon_size" Assets/ExtendedTerminal.png --out "$iconset_path/icon_${icon_size}x${icon_size}.png" > /dev/null
    retina_size=$((icon_size * 2))
    sips -s format png -z "$retina_size" "$retina_size" Assets/ExtendedTerminal.png --out "$iconset_path/icon_${icon_size}x${icon_size}@2x.png" > /dev/null
done
iconutil -c icns "$iconset_path" -o "$app_path/Contents/Resources/AppIcon.icns"
codesign --force --sign - --identifier dev.local.TerminalCopyOnSelect "$app_path"
"$app_path/Contents/MacOS/TerminalCopyOnSelect" --self-test
printf 'Built: %s\n' "$app_path"
pane_path="$PWD/build/Extended Terminal.prefPane"
mkdir -p "$pane_path/Contents/MacOS" "$pane_path/Contents/Resources"
xcrun clang -fobjc-arc -bundle -arch x86_64 -arch arm64 -mmacosx-version-min=12.0 -framework Cocoa -framework PreferencePanes PreferencePane/ExtendedTerminalPane.m -o "$pane_path/Contents/MacOS/ExtendedTerminalPreferences"
cp PreferencePane/Info.plist "$pane_path/Contents/Info.plist"
sips -s format png -z 128 128 Assets/ExtendedTerminal.png --out "$pane_path/Contents/Resources/Terminal.png" > /dev/null
codesign --force --sign - --identifier dev.local.ExtendedTerminal.preferences "$pane_path"
zsh -n Resources/extended-terminal.zsh
