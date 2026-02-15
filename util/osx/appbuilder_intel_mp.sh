#!/bin/bash
#
# ================================================================
#  AttractPlus macOS App Bundler (Intel / MacPorts Edition)
# ================================================================
#
#  This script creates a fully self‑contained, portable macOS .app
#  bundle for AttractPlus on Intel macOS systems using MacPorts.
#
#  Features:
#    • Recursively resolves all dylib dependencies
#    • Copies all required libraries into the .app bundle
#    • Rewrites install names to @loader_path/../libs/
#    • Produces a bundle that runs on Intel AND ARM64 (via Rosetta)
#    • Produces a bundle suitable for codesigning + notarization
#
# ---------------------------------------------------------------
#  BEFORE YOU RUN IT
# ---------------------------------------------------------------
#
#  Make the script executable:
#
#      chmod +x appbuilder_intel_mp.sh
#
# ---------------------------------------------------------------
#  EXPECTED DIRECTORY STRUCTURE
# ---------------------------------------------------------------
#
#  <basedir>/
#     attractplus              ← the compiled executable
#     config/                  ← configuration directory
#     obj/sfml/install/lib/    ← SFML dylibs (audio, graphics, etc.)
#     util/osx/                ← icons, plist, launch.sh, Info.plist
#
# ---------------------------------------------------------------
#  HOW TO RUN THE SCRIPT
# ---------------------------------------------------------------
#
#      ./appbuilder_intel_mp.sh <output_dir> <basedir> <sign?>
#
#  Example:
#
#      ./appbuilder_intel_mp.sh $HOME/buildattract $HOME/buidattract/attractplus yes
#
#  Arguments:
#      output_dir   Directory where the .app bundle will be created
#      basedir      Directory containing the AttractPlus executable
#      sign?        "yes" to ad‑hoc sign, "no" to skip signing
#
# ---------------------------------------------------------------
#  HELP
# ---------------------------------------------------------------
#
#      ./appbuilder_intel_mp.sh --help
#
# ================================================================

shopt -s globstar
set -e

# ---------------------------------------------------------------
#  HELP FLAG
# ---------------------------------------------------------------
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  echo ""
  echo "Usage:"
  echo "  ./appbuilder_intel_mp.sh <output_dir> <basedir> <sign?>"
  echo ""
  echo "Example:"
  echo "  ./appbuilder_intel_mp.sh $HOME/buildattract $HOME/buidattract/attractplus yes"
  echo ""
  echo "Arguments:"
  echo "  output_dir   Directory where the .app bundle will be created"
  echo "  basedir      Directory containing the AttractPlus executable"
  echo "  sign?        \"yes\" to ad‑hoc sign, \"no\" to skip signing"
  echo ""
  echo "Before running:"
  echo "  chmod +x appbuilder_intel_mp.sh"
  echo ""
  exit 0
fi

echo "STEP 1 - PREPARE BUNDLE FOLDERS (MACPORTS)"

buildpath=${1:-"artifacts"}
basedir=${2:-"am"}
signapp=${3:-"no"}

echo "Build Path: $buildpath"
echo "Base Dir:  $basedir"
echo "Sign App:  $signapp"

bundlehome="$buildpath/Attract Mode Plus.app"
bundlecontent="$bundlehome/Contents"
bundlemacos="$bundlecontent/MacOS"
bundleres="$bundlecontent/Resources"
bundlelibs="$bundlecontent/libs"
bundleshare="$bundlecontent/share/attractplus"

rm -rf "$bundlehome"
mkdir -p "$bundlemacos" "$bundleres" "$bundlelibs" "$bundleshare"

src_exe="$basedir/attractplus"
if [[ ! -f "$src_exe" ]]; then
  echo "Error: Executable $src_exe does not exist!"
  exit 1
fi

echo "STEP 2 - COPY EXECUTABLE AND ASSETS"

cp -a "$src_exe" "$bundlemacos/attractplus"
cp -a "$basedir/config/" "$bundleshare"
cp -a "$basedir/util/osx/attractplus.icns" "$bundleres/"
cp -a "$basedir/util/osx/AppIcon.icns" "$bundleres/" 2>/dev/null || true
cp -a "$basedir/util/osx/Assets.car" "$bundleres/" 2>/dev/null || true
cp -a "$basedir/util/osx/launch.sh" "$bundlemacos/"

chmod +x "$bundlemacos"/*

echo "STEP 3 - PREPARE INFO.PLIST"

LASTTAG=$(git -C "$basedir" describe --tag --abbrev=0)
VERSION=$(git -C "$basedir" describe --tag | sed 's/-[^-]\{8\}$//')
BUNDLEVERSION=${VERSION//[v-]/.}; BUNDLEVERSION=${BUNDLEVERSION#"."}
SHORTVERSION=${LASTTAG//v/}

sed -e "s/%%SHORTVERSION%%/${SHORTVERSION}/" \
    -e "s/%%BUNDLEVERSION%%/${BUNDLEVERSION}/" \
    "$basedir/util/osx/Info.plist" > "$bundlecontent/Info.plist"

echo "STEP 4 - RESOLVE AND COLLECT LIBRARIES (MACPORTS)"

VISITED=()
RESOLVED=()

in_array() {
  local needle="$1"; shift
  for x in "$@"; do
    [[ "$x" == "$needle" ]] && return 0
  done
  return 1
}

resolve_links() {
  local file="$1"
  [[ ! -f "$file" ]] && return
  in_array "$file" "${VISITED[@]}" && return

  VISITED+=("$file")

  local links
  links=$(otool -L "$file" | tail -n +2 | awk '{print $1}')

  while IFS= read -r lib; do
    [[ -z "$lib" ]] && continue

    local resolved=""

    # Skip system libs
    case "$lib" in
      /usr/lib/*|/System/*)
        continue
        ;;
    esac

    # Direct absolute path
    if [[ -z "$resolved" && -f "$lib" ]]; then
      resolved="$lib"
    fi

    # Any MacPorts library
    if [[ -z "$resolved" && "$lib" == *"/opt/local/"* ]]; then
      [[ -f "$lib" ]] && resolved="$lib"
    fi

    # FFmpeg inside MacPorts libexec
    if [[ -z "$resolved" && "$lib" == *"/libexec/ffmpeg"* ]]; then
      [[ -f "$lib" ]] && resolved="$lib"
    fi

    # Locally built SFML inside build tree
    if [[ -z "$resolved" && "$lib" == *"/obj/sfml/install/lib/"* ]]; then
      [[ -f "$lib" ]] && resolved="$lib"
    fi

    # Handle @loader_path
    if [[ -z "$resolved" && "$lib" == @loader_path/* ]]; then
      local dir
      dir=$(dirname "$file")
      local candidate="$dir/${lib#@loader_path/}"
      [[ -f "$candidate" ]] && resolved="$candidate"
    fi

    # Handle @rpath
    if [[ -z "$resolved" && "$lib" == @rpath/* ]]; then
      local rpaths
      rpaths=$(otool -l "$file" | awk '
        $1 == "cmd" && $2 == "LC_RPATH" {r=1}
        r && $1 == "path" {print $2; r=0}
      ')
      for rpath in $rpaths; do
        local candidate="$rpath/${lib#@rpath/}"
        [[ -f "$candidate" ]] && resolved="$candidate" && break
      done
    fi

    # Fallback: resolve SFML by filename if @rpath did not resolve it
    if [[ -z "$resolved" && "$lib" == @rpath/libsfml-* ]]; then
      local sfml_name="${lib#@rpath/}"
      local sfml_path="$basedir/obj/sfml/install/lib/$sfml_name"
      if [[ -f "$sfml_path" ]]; then
        resolved="$sfml_path"
      fi
    fi

    if [[ -n "$resolved" ]] && ! in_array "$resolved" "${RESOLVED[@]}"; then
      RESOLVED+=("$resolved")
      resolve_links "$resolved"
    fi
  done <<< "$links"
}

bundle_exe="$bundlemacos/attractplus"
resolve_links "$bundle_exe"

echo "STEP 5 - COPY LIBRARIES INTO BUNDLE"

for lib in "${RESOLVED[@]}"; do
  lib_name=$(basename "$lib")
  dest="$bundlelibs/$lib_name"
  if [[ ! -f "$dest" ]]; then
    echo "Copying $lib -> $dest"
    cp -L "$lib" "$dest"
  fi
done

echo "STEP 6 - REWRITE LIBRARY INSTALL NAMES"

for lib in "$bundlelibs"/*.dylib "$bundlelibs"/*.so; do
  [[ ! -f "$lib" ]] && continue
  lib_name=$(basename "$lib")

  install_name_tool -id "@loader_path/../libs/$lib_name" "$lib" 2>/dev/null || true

  deps=$(otool -L "$lib" | tail -n +2 | awk '{print $1}')
  while IFS= read -r dep; do
    [[ -z "$dep" ]] && continue

    case "$dep" in
      /usr/lib/*|/System/*)
        continue
        ;;
    esac

    dep_base=$(basename "$dep")
    new_ref="@loader_path/../libs/$dep_base"

    if [[ -f "$bundlelibs/$dep_base" ]]; then
      install_name_tool -change "$dep" "$new_ref" "$lib" 2>/dev/null || true
      if [[ "$dep" == @rpath/* || "$dep" == @loader_path/* ]]; then
        install_name_tool -change "$dep" "$new_ref" "$lib" 2>/dev/null || true
      fi
    fi
  done <<< "$deps"
done

echo "STEP 7 - PATCH EXECUTABLE LINKS"

install_name_tool -add_rpath "@executable_path/../libs" "$bundle_exe" 2>/dev/null || true

exe_deps=$(otool -L "$bundle_exe" | tail -n +2 | awk '{print $1}')
while IFS= read -r dep; do
  [[ -z "$dep" ]] && continue

  case "$dep" in
    /usr/lib/*|/System/*)
      continue
      ;;
  esac

  dep_base=$(basename "$dep")
  new_ref="@loader_path/../libs/$dep_base"

  if [[ -f "$bundlelibs/$dep_base" ]]; then
    install_name_tool -change "$dep" "$new_ref" "$bundle_exe" 2>/dev/null || true
    if [[ "$dep" == @rpath/* || "$dep" == @loader_path/* ]]; then
      install_name_tool -change "$dep" "$new_ref" "$bundle_exe" 2>/dev/null || true
    fi
  fi
done <<< "$exe_deps"

echo "STEP 8 - RENAME BUNDLE"

newappname="$buildpath/Attract-Mode Plus v${SHORTVERSION}.app"
mv "$bundlehome" "$newappname"
bundlehome="$newappname"

echo "STEP 9 - OPTIONAL AD-HOC SIGNING"

if [[ "$signapp" == "yes" ]]; then
  for lib in "$bundlehome/Contents/libs/"*; do
    [[ -f "$lib" ]] && codesign --force -s - "$lib"
  done
  codesign --force -s - "$bundlehome/Contents/MacOS/attractplus"
  codesign --force -s - "$bundlehome"
fi

echo "ALL DONE (MACPORTS BUNDLE)"
