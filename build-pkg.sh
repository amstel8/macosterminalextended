#!/bin/zsh
set -eu
cd "${0:A:h}"
BUILD_UNIVERSAL=1 zsh build.sh
mkdir -p dist
stage_dir=$(mktemp -d "$PWD/build/pkg-stage.XXXXXX")
mkdir -p "$stage_dir/root/Library/Application Support/Extended Terminal" "$stage_dir/root/Library/PreferencePanes" "$stage_dir/scripts"
ditto "build/Extended Terminal.app" "$stage_dir/root/Library/Application Support/Extended Terminal/Extended Terminal.app"
ditto "build/Extended Terminal.prefPane" "$stage_dir/root/Library/PreferencePanes/Extended Terminal.prefPane"
cp packaging/scripts/postinstall "$stage_dir/scripts/postinstall"
chmod 755 "$stage_dir/scripts/postinstall"
pkgbuild --analyze --root "$stage_dir/root" "$stage_dir/components.plist"
/usr/libexec/PlistBuddy -c 'Set :0:BundleIsRelocatable false' "$stage_dir/components.plist"
/usr/libexec/PlistBuddy -c 'Set :0:BundleHasStrictIdentifier true' "$stage_dir/components.plist"
/usr/libexec/PlistBuddy -c 'Add :1:BundleIsRelocatable bool false' "$stage_dir/components.plist"
/usr/libexec/PlistBuddy -c 'Add :1:BundleHasStrictIdentifier bool true' "$stage_dir/components.plist"
pkgbuild --root "$stage_dir/root" --component-plist "$stage_dir/components.plist" --scripts "$stage_dir/scripts" --identifier dev.local.ExtendedTerminal.installer --version 0.3.2 --install-location / "$stage_dir/ExtendedTerminal-component.pkg"
cat > "$stage_dir/distribution.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="2">
<title>Extended Terminal</title>
<welcome file="Welcome.html" mime-type="text/html"/>
<options customize="never" require-scripts="false" hostArchitectures="x86_64,arm64"/>
<allowed-os-versions><os-version min="12.0"/></allowed-os-versions>
<domains enable_localSystem="true" enable_currentUserHome="false" enable_anywhere="false"/>
<choices-outline><line choice="default"/></choices-outline>
<choice id="default" title="Extended Terminal"><pkg-ref id="dev.local.ExtendedTerminal.installer"/></choice>
<pkg-ref id="dev.local.ExtendedTerminal.installer" version="0.3.2" onConclusion="none">ExtendedTerminal-component.pkg</pkg-ref>
</installer-gui-script>
XML
productbuild --distribution "$stage_dir/distribution.xml" --resources packaging --package-path "$stage_dir" 'dist/macosterminalextended-0.3.2.pkg'
(
    cd dist
    LC_ALL=C shasum -a 256 macosterminalextended-0.3.2.pkg > SHA256SUMS
)
printf 'Package: %s\n' "$PWD/dist/macosterminalextended-0.3.2.pkg"
