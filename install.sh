#!/bin/bash

main() {
    clear
    echo -e "Welcome to the MacSploit Experience!"
    echo -e "Install Script Version 3.0"
    local architecture=$(arch)

    if [ "$architecture" == "arm64" ]
    then
        echo -e "Detected ARM64 Architecture."
    fi

    curl -s "https://git.abyssdigital.xyz/main/jq-macos-amd64" -o "./jq"
    chmod +x ./jq

    echo -e "Downloading Latest Roblox..."
    [ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip
    local robloxVersionInfo=$(curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer")
    local versionInfo=$(curl -s "https://git.abyssdigital.xyz/main/version.json")
    
    local mChannel=$(echo $versionInfo | ./jq -r ".channel")
    local version=$(echo $versionInfo | ./jq -r ".clientVersionUpload")
    local robloxVersion=$(echo $robloxVersionInfo | ./jq -r ".clientVersionUpload")
    
    if [ "$architecture" == "arm64" ]
    then
        if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
        then
            curl "http://setup.rbxcdn.com/mac/arm64/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
        else
            curl "http://setup.rbxcdn.com/mac/arm64/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
        fi
    else
        if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
        then
            curl "http://setup.rbxcdn.com/mac/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
        else
            curl "http://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
        fi
    fi
    
    echo -n "Installing Latest Roblox... "
    [ -d "./Applications/Roblox.app" ] && rm -rf "./Applications/Roblox.app"
    [ -d "/Applications/Roblox.app" ] && rm -rf "/Applications/Roblox.app"

    unzip -o -q "./RobloxPlayer.zip"
    mv ./RobloxPlayer.app /Applications/Roblox.app
    rm ./RobloxPlayer.zip
    echo -e "Done."

    echo -e "Downloading MacSploit..."
    curl "https://git.abyssdigital.xyz/main/macsploit.zip" -o "./MacSploit.zip"

    echo -n "Installing MacSploit... "
    unzip -o -q "./MacSploit.zip"
    echo -e "Done."

    echo -n "Updating Dylib..."
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
    then
        if [ "$architecture" == "arm64" ]
        then
            curl -Os "https://git.abyssdigital.xyz/preview/arm/macsploit.dylib"
        else
            curl -Os "https://git.abyssdigital.xyz/preview/main/macsploit.dylib"
        fi
    else
        if [ "$architecture" == "arm64" ]
        then
            curl -Os "https://git.abyssdigital.xyz/arm/macsploit.dylib"
        else
            curl -Os "https://git.abyssdigital.xyz/main/macsploit.dylib"
        fi
    fi
    
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
    mv ./interpose.dylib "/Applications/Roblox.app/Contents/MacOS/interpose.dylib"
    ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
    mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/interpose.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
    mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    rm -r "/Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app"
    rm ./insert_dylib

    ./rewriter
    codesign --force --deep --sign - "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"

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
    exit
}

main
