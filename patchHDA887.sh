#!/bin/bash

#
# Bash script to patch AppleHDA (and its plug-in kexts) for Realtek ALC887.
#
# Written by Angel W.
#


#
# Force to kill root privilege to prevent potential errors.
#
sudo -k

#
# Uncomment this line for further debugging.
#
#set -x

#================================= GLOBAL VARS ==================================


#
# Script version info.
#
gScriptVersion="0.1"

#
# Get user id
#
gID=`id -u`

#
# Required zlib files.
#
gResources_xml_zlib=("layout11.xml.zlib" "Platforms.xml.zlib")

#
# Initialize variable with the /System/Library/Extensions and /Library/Extensions directory.
#
gExtensionsDirectory=("/System/Library/Extensions" "/Library/Extensions")

#
# The version info of the running system e.g. '10.12.1'
#
gProductVersion="$(sw_vers -productVersion)"

#
# The build info of the running system e.g. '16B2657'
#
gBuildVersion="$(sw_vers -buildVersion)"

#
# PlistBuddy Command Line Tool location.
#
plistbuddy="/usr/libexec/PlistBuddy -c"


#
#--------------------------------------------------------------------------------
#


function SearchAndReplace()
{
  #
  # Usage:
  #
  # SearchAndReplace <Find> <Replace> <Target binary file>
  #

  local hex2Find="$1"
  local hex2Repl="$2"
  local bin2Patch="$3"
  #
  # Example (After running `sed`):
  # 
  # \x00\x00\x00\x00
  #
  local perl2Find="$(echo "${hex2Find}" | sed 's/.\{2\}/\\\x&/g')"
  local perl2Repl="$(echo "${hex2Repl}" | sed 's/.\{2\}/\\\x&/g')"

  #
  # Counting hex data to be searched.
  #
  local data2Count="$(perl -le "print scalar grep /"${perl2Find}"/, <>;" "${bin2Patch}")"

  if [[ "${data2Count}" -gt 0 ]]; then
    #
    # Found. Whether the length is the same? (hex2Find vs hex2Repl)
    #
    if [[ "${#perl2Find}" == "${#perl2Repl}" ]]; then
      #
      # Same. Whether the data is the same?
      #
      if [[ "${perl2Find}" == "${perl2Repl}" ]]; then
        #
        # Search and Replace are the same. Abort it.
        #
        printf "Search and replace patterns are the same!!! Abort patching.\n"
      else
        #
        # No. Need patching. Patch it.
        #
        perl -pi -e "s|${perl2Find}|${perl2Repl}|g" "${bin2Patch}"
      fi
    else
      #
      # Different. Abort it.
      #
      printf "The length of ${hex2Find} and ${hex2Repl} does NOT match!!! Abort patching.\n"
    fi
  else
    #
    # NOT found. Abort it.
    #
    printf "${hex2Find} NOT found in ${bin2Patch}!!! Abort patching.\n"
  fi
}


#
#--------------------------------------------------------------------------------
#


function _printHeader()
{
  printf "patchHDA887.sh v${gScriptVersion} by Angel W.\n"
  printf "${COLOR_BLUE}Copyright (c) `date "+%Y"` Angel W. All rights reserved.${COLOR_END}\n"
  echo '----------------------------------------------------------------'
  echo
  printf "Running on ${gProductVersion} build ${gBuildVersion}\n"
}


#
#--------------------------------------------------------------------------------
#


function _genInjector()
{
  mkdir -p /tmp/AppleHDA887.kext/Contents/PlugIns
  cd /tmp/AppleHDA887.kext/Contents
  touch Info.plist

  echo '<?xml version="1.0" encoding="UTF-8"?>' >> Info.plist
  echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> Info.plist
  echo '<plist version="1.0">' >> Info.plist
  echo '<dict>' >> Info.plist
  echo '  <key>CFBundleDevelopmentRegion</key>' >> Info.plist
  echo '  <string>English</string>' >> Info.plist
  echo '  <key>CFBundleGetInfoString</key>' >> Info.plist
  echo '  <string>AppleHDA887, Copyright © 2017 Vanilla. All rights reserved.</string>' >> Info.plist
  echo '  <key>CFBundleIdentifier</key>' >> Info.plist
  echo '  <string>org.vanilla.driver.AppleHDA887</string>' >> Info.plist
  echo '  <key>CFBundleInfoDictionaryVersion</key>' >> Info.plist
  echo '  <string>6.0</string>' >> Info.plist
  echo '  <key>CFBundleName</key>' >> Info.plist
  echo '  <string>Realtek 887 Configuation Driver</string>' >> Info.plist
  echo '  <key>CFBundlePackageType</key>' >> Info.plist
  echo '  <string>KEXT</string>' >> Info.plist
  echo '  <key>CFBundleShortVersionString</key>' >> Info.plist
  echo '  <string>1.0.0</string>' >> Info.plist
  echo '  <key>CFBundleVersion</key>' >> Info.plist
  echo '  <string>1.0.0</string>' >> Info.plist
  echo '  <key>IOKitPersonalities</key>' >> Info.plist
  echo '  <dict>' >> Info.plist
  echo '    <key>HDA Hardware Config Resource</key>' >> Info.plist
  echo '    <dict>' >> Info.plist
  echo '      <key>CFBundleIdentifier</key>' >> Info.plist
  echo '      <string>com.apple.driver.AppleHDAHardwareConfigDriver</string>' >> Info.plist
  echo '      <key>HDAConfigDefault</key>' >> Info.plist
  echo '      <array>' >> Info.plist
  echo '        <dict>' >> Info.plist
  echo '          <key>AFGLowPowerState</key>' >> Info.plist
  echo '          <data>AwAAAA==</data>' >> Info.plist
  echo '          <key>CodecID</key>' >> Info.plist
  echo '          <integer>283904135</integer>' >> Info.plist
  echo '          <key>ConfigData</key>' >> Info.plist
  echo '          <data>' >> Info.plist
  echo '          AUccEAFHHUABRx4RAUcfkQFHDAIBtxwgAbcd' >> Info.plist
  echo '          QAG3HiEBtx8CAbcMAgGHHDABhx2QAYceoQGH' >> Info.plist
  echo '          H5EBlxxAAZcdkQGXHoEBlx+SAUcMAg==' >> Info.plist
  echo '          </data>' >> Info.plist
  echo '          <key>FuncGroup</key>' >> Info.plist
  echo '          <integer>1</integer>' >> Info.plist
  echo '          <key>LayoutID</key>' >> Info.plist
  echo '          <integer>11</integer>' >> Info.plist
  echo '        </dict>' >> Info.plist
  echo '      </array>' >> Info.plist
  echo '      <key>IOClass</key>' >> Info.plist
  echo '      <string>AppleHDAHardwareConfigDriver</string>' >> Info.plist
  echo '      <key>IOMatchCategory</key>' >> Info.plist
  echo '      <string>AppleHDAHardwareConfigDriver</string>' >> Info.plist
  echo '      <key>IOProviderClass</key>' >> Info.plist
  echo '      <string>AppleHDAHardwareConfigDriverLoader</string>' >> Info.plist
  echo '    </dict>' >> Info.plist
  echo '  </dict>' >> Info.plist
  echo '  <key>OSBundleRequired</key>' >> Info.plist
  echo '  <string>Root</string>' >> Info.plist
  echo '</dict>' >> Info.plist
  echo '</plist>' >> Info.plist
}


#
#--------------------------------------------------------------------------------
#


function _copyHDA()
{
  cp -RX "${gExtensionsDirectory[0]}/AppleHDA.kext" /tmp/AppleHDA.kext

  #
  # Clean-ups.
  #
  cd /tmp/AppleHDA.kext/Contents
  rm -r _CodeSignature Resources/* version.plist
  cd PlugIns

  local redundantKext=("AppleHDAHALPlugIn.bundle" "AppleHDAHardwareConfigDriver.kext" "AppleMikeyDriver.kext" "DspFuncLib.kext" "IOHDAFamily.kext")
  for rmKext in "${redundantKext[@]}"; do
    rm -r "${rmKext}"
  done

  mv AppleHDAController.kext /tmp
  cd ..
  rm -r PlugIns

  cd /tmp
  mv AppleHDA.kext AppleHDALoader.kext
  mv AppleHDAController.kext AppleHDAControllerLoader.kext

  cd AppleHDAControllerLoader.kext/Contents
  rm -r _CodeSignature version.plist

  cd /tmp
  mv AppleHDALoader.kext AppleHDAControllerLoader.kext /tmp/AppleHDA887.kext/Contents/PlugIns
}


#
#--------------------------------------------------------------------------------
#


function _patchHDA()
{
  #
  # Patch AppleHDA binary.
  #
  cd /tmp/AppleHDA887.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/MacOS
  SearchAndReplace "8419d411" "8708ec10" "AppleHDA"
  SearchAndReplace "41C60600488BBB68" "41C60601488BBB68" "AppleHDA"
  SearchAndReplace "41C6864301000000" "41C6864301000001" "AppleHDA"
  SearchAndReplace "536F756E6420617373657274696F6E20" "00000000000000000000000000000000" "AppleHDA"
  #
  # Patch AppleHDA Info.plist
  #
  cd ..
  $plistbuddy "Set ':CFBundleShortVersionString' 999.99.9" Info.plist
  $plistbuddy "Set ':CFBundleVersion' 999.99.9" ./Info.plist

  #
  # Patch AppleHDAController binary.
  #
  cd /tmp/AppleHDA887.kext/Contents/PlugIns/AppleHDAControllerLoader.kext/Contents/MacOS
  SearchAndReplace "536F756E6420617373657274696F6E20" "00000000000000000000000000000000" "AppleHDAController"

  #
  # Patch AppleHDAController Info.plist
  #
  cd ..
  $plistbuddy "Set ':CFBundleShortVersionString' 999.99.9" Info.plist
  $plistbuddy "Set ':CFBundleVersion' 999.99.9" ./Info.plist

  #
  # Add patched zlib files. Need downloading.
  #
  cd /tmp/AppleHDA887.kext/Contents/PlugIns/AppleHDALoader.kext/Contents/Resources
  for zlib in "${gResources_xml_zlib[@]}"; do
    curl -o "${zlib}" https://raw.githubusercontent.com/PMheart/patchHDA887/master/Zlibs/"${zlib}"
    if [[ $? -ne 0 ]]; then
      exit 1
    fi
  done
}


#
#--------------------------------------------------------------------------------
#


function main()
{
  rm -rf /tmp/*
  _printHeader
  _genInjector
  _copyHDA
  _patchHDA

  clear
  printf '\n\n\nDone.\n'
  read -p "Do you want to copy the patched kext to ${gExtensionsDirectory[1]}? (y/n) " choice01
  case ${choice01} in
    y|Y|"" )
      cp -RX /tmp/AppleHDA887.kext ${gExtensionsDirectory[1]}
      chmod -R 755 ${gExtensionsDirectory[1]}
      chown -R 0:0 ${gExtensionsDirectory[1]}
      touch ${gExtensionsDirectory[0]} && touch ${gExtensionsDirectory[1]}
      kextcache -u /
      ;;
     * )
	  mv /tmp/AppHDA887.kext ~/Desktop
	  ;;
  esac
}

#==================================== START =====================================

clear

if [[ $gID -ne 0 ]]; then
    printf "This script must be run as ROOT!!!\n"
    #
    # Re-run as root with arguments.
    #
    sudo "$0" "$@"
else
    #
    # Root privilege already. Now call main() directly with arguments.
    #
    main "$@"
fi

#================================================================================


exit 0