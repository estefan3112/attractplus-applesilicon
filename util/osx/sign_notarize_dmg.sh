#!/bin/bash
#
# Sign an Attract-Mode Plus app bundle with a Developer ID certificate,
# pack it into a styled DMG (background, volume icon, Applications link),
# notarize the DMG with Apple and staple the ticket to it.
#
# Usage:  sign_notarize_dmg.sh [folder containing the .app] [arch label]
#         e.g. sign_notarize_dmg.sh artifacts arm64
#
# On GitHub Actions these come from the repository secrets:
#   MACOS_CERTIFICATE      base64 of the "Developer ID Application" .p12 export
#   MACOS_CERTIFICATE_PWD  password chosen when exporting the .p12
#   APPLE_ID               Apple ID e-mail of the developer account
#   APPLE_TEAM_ID          10-character Team ID
#   APPLE_APP_PASSWORD     app-specific password from appleid.apple.com
#
# On your own Mac, instead:
#   SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"   (certificate from your login keychain)
#   NOTARY_PROFILE="name"   (a profile saved earlier with: xcrun notarytool store-credentials)
#   or APPLE_ID / APPLE_TEAM_ID / APPLE_APP_PASSWORD as above
#   Install create-dmg (brew install create-dmg) for the styled DMG.

set -euo pipefail

artifacts="${1:-artifacts}"
arch="${2:-$(uname -m)}"
osxdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # util/osx: background.png, VolumeIcon.icns

app=$(find "$artifacts" -maxdepth 1 -type d -name "*.app" | head -n 1)
if [[ -z "$app" ]]; then
	echo "ERROR: no .app bundle found in $artifacts"
	exit 1
fi
appfile=$(basename "$app")               # "Attract-Mode Plus v3.2.3.app"
appname="${appfile%.app}"                # "Attract-Mode Plus v3.2.3"
version="${appname##* v}"                # "3.2.3"
dmg="$artifacts/Attract-Mode-Plus-v${version}-macOS-${arch}.dmg"
echo "App bundle: $app"

tmp=$(mktemp -d)
keychain=""
cleanup() {
	if [[ -n "$keychain" ]]; then security delete-keychain "$keychain" 2>/dev/null || true; fi
	rm -rf "$tmp"
}
trap cleanup EXIT


echo "STEP 1 - SIGNING IDENTITY"

if [[ -n "${MACOS_CERTIFICATE:-}" ]]; then
	# GitHub Actions: put the certificate into a temporary keychain that is deleted afterwards
	keychain="$tmp/signing.keychain-db"
	kcpass=$(openssl rand -base64 24)
	echo "$MACOS_CERTIFICATE" | base64 --decode > "$tmp/cert.p12"
	security create-keychain -p "$kcpass" "$keychain"
	security set-keychain-settings -lut 21600 "$keychain"
	security unlock-keychain -p "$kcpass" "$keychain"
	security import "$tmp/cert.p12" -k "$keychain" -P "$MACOS_CERTIFICATE_PWD" -T /usr/bin/codesign
	security set-key-partition-list -S apple-tool:,apple: -s -k "$kcpass" "$keychain" > /dev/null
	# shellcheck disable=SC2046  # the existing keychain list is meant to be split into words
	security list-keychains -d user -s "$keychain" $(security list-keychains -d user | tr -d '"')
	identity=$(security find-identity -v -p codesigning "$keychain" | awk '/Developer ID Application/ {print $2; exit}')
else
	identity="${SIGN_IDENTITY:?Set MACOS_CERTIFICATE (GitHub) or SIGN_IDENTITY (your Mac)}"
fi

if [[ -z "$identity" ]]; then
	echo "ERROR: no 'Developer ID Application' certificate found. Was the .p12 exported with its private key?"
	exit 1
fi
echo "Using identity: $identity"


echo "STEP 2 - CHECK THE BUNDLE IS SELF-CONTAINED"

# Libraries still pointing into Homebrew/MacPorts only work on Macs that have them installed
if otool -L "$app"/Contents/MacOS/attractplus "$app"/Contents/libs/* \
	| grep -E '^[[:space:]]+(/opt/homebrew|/usr/local|/opt/local)/'; then
	echo "ERROR: the bundle still uses the libraries listed above from outside the app."
	exit 1
fi
echo "OK - all libraries are inside the bundle"


echo "STEP 3 - CODE SIGNING"

sign() {
	codesign --force --timestamp --options runtime --sign "$identity" "$@"
}

# Inside out: first every Mach-O file in the bundle (bundled libraries and the
# attractplus program), then the bundle itself, which also seals launch.sh,
# Info.plist and the resources.
while IFS= read -r -d '' f; do
	if file -b "$f" | grep -q "Mach-O"; then
		echo "Signing ${f#"$app"/}"
		sign "$f"
	fi
done < <(find "$app/Contents" -type f -print0)

sign "$app"
codesign --verify --deep --strict --verbose=2 "$app"


echo "STEP 4 - BUILD DMG"

mkdir -p "$tmp/dmg"
ditto "$app" "$tmp/dmg/$appfile"
rm -f "$dmg"

plain_dmg() {
	ln -s /Applications "$tmp/dmg/Applications"
	hdiutil create -volname "$appname" -srcfolder "$tmp/dmg" -fs HFS+ -format UDZO -ov "$dmg"
}

if command -v create-dmg > /dev/null && [[ -f "$osxdir/background.png" ]]; then
	# Window layout matches background.png (640x320): app icon left of the arrow,
	# Applications folder to the right of it.
	if ! create-dmg \
		--volname "$appname" \
		--volicon "$osxdir/VolumeIcon.icns" \
		--background "$osxdir/background.png" \
		--window-pos 200 120 \
		--window-size 640 350 \
		--icon-size 96 \
		--icon "$appfile" 110 210 \
		--hide-extension "$appfile" \
		--app-drop-link 330 210 \
		"$dmg" "$tmp/dmg"; then
		# Styling needs Finder scripting, which occasionally times out on build machines
		echo "::warning::Styled DMG failed - creating a plain DMG instead"
		rm -f "$dmg"
		plain_dmg
	fi
else
	echo "create-dmg not installed - creating a plain DMG"
	plain_dmg
fi

codesign --force --timestamp --sign "$identity" "$dmg"


echo "STEP 5 - NOTARIZE AND STAPLE"

if [[ -n "${NOTARY_PROFILE:-}" ]]; then
	creds=(--keychain-profile "$NOTARY_PROFILE")
else
	creds=(--apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID" --password "$APPLE_APP_PASSWORD")
fi

result=$(xcrun notarytool submit "$dmg" "${creds[@]}" --wait --timeout 30m --output-format json)
echo "$result"
status=$(plutil -extract status raw - <<< "$result")
subid=$(plutil -extract id raw - <<< "$result")

if [[ "$status" != "Accepted" ]]; then
	echo "ERROR: notarization status is '$status'. Apple's log:"
	xcrun notarytool log "$subid" "${creds[@]}" || true
	exit 1
fi

xcrun stapler staple "$dmg"
xcrun stapler validate "$dmg"
spctl --assess --type open --context context:primary-signature --verbose=2 "$dmg"

echo "DONE: $dmg"
