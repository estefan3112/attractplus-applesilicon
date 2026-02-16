#!/bin/bash
#
# ================================================================
#  AttractPlus macOS App Builder (Intel / MacPorts Edition)
# ================================================================
#
#  This script builds AttractPlus on Intel Macs with an underlying
#  MacPorts install. After building the binary, it requires the 
#  appbuilder_intel_mp.sh script to produce an ad-hoc signed, self
#  contained app bundle with all the dylibs in it.
#
# ---------------------------------------------------------------
#  BEFORE YOU RUN IT
# ---------------------------------------------------------------
#
#  Make the script executable:
#
#      chmod +x self_build_macos_intel_mp.sh
#
# ---------------------------------------------------------------
#  HOW TO RUN THE SCRIPT
# ---------------------------------------------------------------
#
#      ./self_build_macos_intel_mp.sh
#

if [[ -n "$1" ]]
then
    branch="-b $1"
else
    branch=""
fi

export PKG_CONFIG_PATH=/opt/local/libexec/ffmpeg8/lib/pkgconfig:/opt/local/lib/pkgconfig:/opt/local/share/pkgconfig
export PATH=/opt/local/bin:$PATH

# uncomment the following line for legacy MacOS support - 10.15 is oldest possible - probably only relevant for Intel
# MACOSX_DEPLOYMENT_TARGET=10.15

echo Creating Folders
rm -Rf $HOME/buildattract
mkdir $HOME/buildattract

echo Cloning attractplus
git clone $branch http://github.com/oomek/attractplus $HOME/buildattract/attractplus

cd $HOME/buildattract/attractplus

LASTTAG=$(git describe --tag --abbrev=0)
VERSION=$(git describe --tag | sed 's/-[^-]\{8\}$//')
BUNDLEVERSION=${VERSION//[v-]/.}; BUNDLEVERSION=${BUNDLEVERSION#"."}
SHORTVERSION=${LASTTAG//v/}

NPROC=$(getconf _NPROCESSORS_ONLN)

echo Building attractplus
export LDFLAGS="$LDFLAGS -Wl,-headerpad_max_install_names"
make clean
eval make -j${NPROC} STATIC=0 VERBOSE=1 USE_SYSTEM_SFML=0 prefix=..


bash util/osx/appbuilder_intel_mp.sh $HOME/buildattract $HOME/buildattract/attractplus yes