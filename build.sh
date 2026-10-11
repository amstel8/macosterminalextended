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
cp Resources/* "$app_path/Contents/Resources/"
codesign --force --sign - --identifier dev.local.TerminalCopyOnSelect "$app_path"
"$app_path/Contents/MacOS/TerminalCopyOnSelect" --self-test
printf 'Built: %s\n' "$app_path"
