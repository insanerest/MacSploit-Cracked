#!/bin/bash

LOGFILE="$HOME/macsploit-install.log"
rm "$LOGFILE"

log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $*" | tee -a "$LOGFILE"
}

# Exit on any unhandled error
set -o errexit
set -o pipefail

# Trap unexpected exits
trap 'log "ERROR on line $LINENO: Command \"${BASH_COMMAND}\" failed"; exit 1' ERR
trap '
    log "Script terminated."
    echo -e "\n\n\n\n\n ########## DEBUG INFO #########"
    while IFS= read -r line; do
        echo "$line"
    done < "$LOGFILE"
' EXIT

# Validates a command exists before running
require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log "FATAL: Required command '$1' is missing."
        exit 1
    fi
}

# Validates last command success
check() {
    if [ $? -ne 0 ]; then
        log "ERROR: $1 failed."
        exit 1
    fi
}

# Safe file download wrapper
download() {
    local url="$1"
    local out="$2"

    curl -fsSL "$url" -o "$out"
    if [ $? -ne 0 ]; then
        log "ERROR: Download failed for $url"
        exit 1
    fi
    log "Downloaded: $url"
}




main() {
    clear
    log "==== Starting installer ===="

    # Validate required commands exist
    require_cmd curl
    require_cmd unzip
    require_cmd arch
    require_cmd codesign
    require_cmd mv

    echo -e "Welcome to the MacSploit Experience!"
    echo -e "Install Script Version 3.0"

    architecture=$(arch)
    log "Detected architecture: $architecture"

    curl -s "https://git.abyssdigital.xyz/main/jq-macos-amd64" -o "./jq"
    [ -f jq ] || (log "Missing jq binary" && exit 1)
    chmod +x ./jq

    echo -e "Downloading Latest Roblox..."
    [ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip
    local robloxVersionInfo=$(curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer")
    local versionInfo=$(curl -s "https://git.abyssdigital.xyz/main/version.json")
    if ! echo "$versionInfo" | grep -q "clientVersionUpload"; then
        log "ERROR: version.json is invalid or corrupted."
        exit 1
    fi
    if ! echo "$versionInfo" | grep -q "channel"; then
        log "ERROR: versionInfo is invalid or corrupted."
        exit 1
    fi
    if ! echo "$robloxVersionInfo" | grep -q "clientVersionUpload"; then
        log "ERROR: robloxVersionInfo is invalid or corrupted."
        exit 1
    fi
    log "Version info validated."
    
    local mChannel=$(echo $versionInfo | ./jq -r ".channel")
    local version=$(echo $versionInfo | ./jq -r ".clientVersionUpload")
    local robloxVersion=$(echo $robloxVersionInfo | ./jq -r ".clientVersionUpload")
    
    if [ "$architecture" == "arm64" ]
    then
        if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
        then
            log "Curling: http://setup.rbxcdn.com/mac/arm64/$robloxVersion-RobloxPlayer.zip"
            #curl "http://setup.rbxcdn.com/mac/arm64/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
        else
            log "Curling: http://setup.rbxcdn.com/mac/arm64/$version-RobloxPlayer.zip"
            #curl "http://setup.rbxcdn.com/mac/arm64/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
        fi
    else
        if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
        then
            log "Curling: http://setup.rbxcdn.com/mac/$robloxVersion-RobloxPlayer.zip"
            curl "http://setup.rbxcdn.com/mac/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
        else
            log "Curling: http://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip"
            curl "http://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
        fi
    fi
    [ -f RobloxPlayer.zip ] || (log "Missing RobloxPlayer.zip" && exit 1)
    
    echo -n "Installing Latest Roblox... "
    [ -d "./Applications/Roblox.app" ] && rm -rf "./Applications/Roblox.app"
    [ -d "/Applications/Roblox.app" ] && rm -rf "/Applications/Roblox.app"

    unzip -o -q "./RobloxPlayer.zip" || (log "Unzip failed" && exit 1)
    mv ./RobloxPlayer.app /Applications/Roblox.app
    rm ./RobloxPlayer.zip
    echo -e "Done."

    echo -e "Downloading MacSploit..."
    log "Curling: https://git.abyssdigital.xyz/main/macsploit.zip"
    curl "https://git.abyssdigital.xyz/main/macsploit.zip" -o "./MacSploit.zip"

    echo -n "Installing MacSploit... "
    unzip -o -q "./MacSploit.zip" || (log "Unzip failed" && exit 1)
    echo -e "Done."

    echo -n "Updating Dylib..."
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
    then
        if [ "$architecture" == "arm64" ]
        then
            log "Curling: https://git.abyssdigital.xyz/preview/arm/macsploit.dylib"
            curl -Os "https://git.abyssdigital.xyz/preview/arm/macsploit.dylib"
        else
            log "Curling: https://git.abyssdigital.xyz/preview/main/macsploit.dylib"
            curl -Os "https://git.abyssdigital.xyz/preview/main/macsploit.dylib"
        fi
    else
        if [ "$architecture" == "arm64" ]
        then
            log "Curling: https://git.abyssdigital.xyz/arm/macsploit.dylib"
            curl -Os "https://git.abyssdigital.xyz/arm/macsploit.dylib"
        else
            log "Curling: https://git.abyssdigital.xyz/main/macsploit.dylib"
            curl -Os "https://git.abyssdigital.xyz/main/macsploit.dylib"
        fi
    fi

    [ -f macsploit.dylib ] || (log "Missing macsploit.dylib" && exit 1)
    
    echo -e " Done."
    echo -e "Patching Roblox..."

    if [ "$architecture" == "arm64" ]
    then
        codesign --remove-signature /Applications/Roblox.app
    fi

    echo -e "Downloading Patcher"
    curl -L "https://github.com/insanerest/MacSploit-Cracked/raw/refs/heads/main/interpose.dylib" -o "interpose.dylib"
    curl -L "https://github.com/insanerest/MacSploit-Cracked/raw/refs/heads/main/rewriter" -o "rewriter"
    chmod +x rewriter

    mv ./macsploit.dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
    ./rewriter
    mv ./interpose.dylib "/Applications/Roblox.app/Contents/MacOS/interpose.dylib"
    ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
    mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/interpose.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
    mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    rm -r "/Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app"
    rm ./insert_dylib

    if [ "$architecture" == "arm64" ]
    then
        codesign -s "-" /Applications/Roblox.app
        echo -e " Done."
    fi

    echo -n "Installing MacSploit App... "
    [ -d "./Applications/MacSploit.app" ] && rm -rf "./Applications/MacSploit.app"
    [ -d "/Applications/MacSploit.app" ] && rm -rf "/Applications/MacSploit.app"
    mv ./MacSploit.app /Applications/MacSploit.app
    rm ./MacSploit.zip
    
    touch ~/Downloads/ms-version.json
    echo $versionInfo > ~/Downloads/ms-version.json
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
    then
        cat <<< $(./jq '.channel = "previewb"' ~/Downloads/ms-version.json) > ~/Downloads/ms-version.json
    fi
    
    rm ./jq
    rm ./hwid
    echo -e "Done."
    echo -e "Install Complete! Developed by Nexus42 and Cracked by Insanerest!!"
    echo -e "\n\n\n\n\n ########## DEBUG INFO #########"
    cat "$LOGFILE"
    exit
}

main
