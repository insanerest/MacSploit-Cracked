#!/bin/bash

PWD="$TMPDIR/Macsploit-Mirror"
APPDIR="/Applications"
BASE_URL="https://raw.githubusercontent.com/DollarNoob/Macsploit-Mirror/main"
PATCH_URL="https://raw.githubusercontent.com/insanerest/Macsploit-Cracked/main"

if [[ -z "$1" ]]; then
    ARCH=$(uname -m)
else
    ARCH="$1"
fi

print_title() {
    clear
    center "\033[1;35m  __  __             _____       _       _ _    \033[0m"
    center "\033[1;35m |  \/  |           / ____|     | |     (_) |   \033[0m"
    center "\033[1;35m | \  / | __ _  ___| (___  _ __ | | ___  _| |_  \033[0m"
    center "\033[1;35m | |\/| |/ _\` |/ __|\___ \| '_ \| |/ _ \| | __| \033[0m"
    center "\033[1;35m | |  | | (_| | (__ ____) | |_) | | (_) | | |_  \033[0m"
    center "\033[1;35m |_|  |_|\__,_|\___|_____/| .__/|_|\___/|_|\__| \033[0m"
    center "\033[1;35m                          | |                   \033[0m"
    center "\033[1;35m                          |_|                   \033[0m"
    echo
}

authenticate() {
    local hwid=$(get_hwid)

    # ! DO NOT TOUCH ! DO NOT TOUCH ! DO NOT TOUCH !
    local whitelist # MUST assign the variable before initializing to prevent $? not working properly
    whitelist=$(curl -s "https://git.raptor.fun/api/whitelist?hwid=$hwid" 2>&1)
    local status=$?
    if [[ "$status" != 0 ]]; then
        center "\033[91mYour network failed to contact MacSploit's servers.\033[0m"
        center "\033[91mPlease connect to a VPN and try again. (Error Code $status)\033[0m"
        echo
        center "\033[33mAlthough you could still install MacSploit,\033[0m"
        center "\033[33myou will not be able to use MacSploit without a VPN.\033[0m"
        center "Do you want to proceed? (Y/N): \c"
        while read -n 1 -s -r answer; do
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                print_title
                return
            elif [[ "$answer" =~ ^[Nn]$ ]]; then
                echo
                echo
                exit
            fi
        done
    fi

    local trial=false
        center "\033[36mWelcome to the MacSploit experience!\033[0m"
        sleep 2
        print_title
        return

    echo
    local cols=$(tput cols)
    local pad=$(((cols - 63) / 2)) # 31 (message) + 32 (key)
    printf "%*s%b\n" "$pad" "" "Please enter your license key: \c"

    read license
    echo

    if [[ ${#license} -ne 32 ]]; then
        if [[ "$trial" == true ]]; then
            center "\033[32mProceeding as free trial.\033[0m"
            sleep 2
            print_title
            return
        else
            center "\033[91mAn invalid key was entered. Please try again.\033[0m"
            echo
            exit
        fi
    fi

    # ! DO NOT TOUCH ! DO NOT TOUCH ! DO NOT TOUCH !
    local resp # MUST assign the variable before initializing to prevent $? not working properly
    resp=$(curl -s "https://git.raptor.fun/api/sellix?key=$license&hwid=$hwid")
    local status=$?
    if [[ "$resp" == "Key Activation Complete!" ]]; then
        center "\033[32mYour license has been activated successfully!\033[0m"
        sleep 2
        print_title
        return
    elif [[ "$resp" == "Invalid Key Entered." ]]; then
        center "\033[91mAn invalid key was entered. Please try again.\033[0m"
        echo
        exit
    elif [[ "$status" != 0 ]]; then
        center "\033[91mYour network failed to contact MacSploit's servers.\033[0m"
        center "\033[91mPlease connect to a VPN and try again. (Error Code $status)\033[0m"
        echo
        center "\033[33mAlthough you could still install MacSploit,\033[0m"
        center "\033[33myou will not be able to use MacSploit without a VPN.\033[0m"
        center "Do you want to proceed? (Y/N): \c"
        while read -n 1 -r answer; do
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                print_title
                return
            elif [[ "$answer" =~ ^[Nn]$ ]]; then
                echo
                echo
                exit
            fi
        done
    else
        center "\033[91mAn unknown error has occurred: $resp.\033[0m"
        center "\033[91mThis is unexpected, please contact support.\033[0m"
        echo
        exit
    fi
}

check_requirements() {
    local os_version=$(sw_vers -productVersion)

    if [[ "$(echo "$os_version" | cut -d. -f1)" -ge 11 ]]; then
        if [[ "$ARCH" == "arm64" ]]; then
            center "✅ \033[1;36mmacOS $os_version\033[0m (Apple Silicon)"
        else
            center "✅ \033[1;36mmacOS $os_version\033[0m (Intel)"
        fi
        echo
        center "============================================================"
        echo
    else
        if [[ "$ARCH" == "arm64" ]]; then
            center "❌ \033[1;31mmacOS $os_version\033[0m (Apple Silicon)"
        else
            center "❌ \033[1;31mmacOS $os_version\033[0m (Intel)"
        fi
        center "\033[91mYour device is not compatible with MacSploit.\033[0m"
        center "\033[91mPlease upgrade to macOS 11.0+ if possible.\033[0m"
        echo
        exit
    fi
}

check_permissions() {
    if [[ -d "$PWD" ]]; then
        local error=$(rm -rf "$PWD" 2>&1)
        local status=$?
        if echo "$error" | grep -q "Permission denied"; then
            center "\033[91mTerminal is unable to access your Temporary folder.\033[0m"
            center "\033[91mThis is unexpected, please contact support.\033[0m"
            echo
            exit
        elif [[ "$status" != 0 ]]; then
            center "\033[91mAn unknown error has occurred: C-00.\033[0m"
            center "\033[91mThis is unexpected, please contact support.\033[0m"
            echo
            exit
        fi
    fi

    local error=$(mkdir "$PWD" 2>&1)
    local status=$?
    if echo "$error" | grep -q "Permission denied"; then
        center "\033[91mTerminal is unable to access your Temporary folder.\033[0m"
        center "\033[91mThis is unexpected, please contact support.\033[0m"
        echo
        exit
    elif [[ "$status" != 0 ]]; then
        center "\033[91mAn unknown error has occurred: C-01.\033[0m"
        center "\033[91mThis is unexpected, please contact support.\033[0m"
        echo
        exit
    fi

    local error=$(rm -f "$HOME/Downloads/ms-version.json" 2>&1)
    local status=$?
    if echo "$error" | grep -q "Permission denied"; then
        if ! can_sudo; then
            center "\033[91mTerminal is unable to access your Downloads folder.\033[0m"
            center "\033[91mPlease enter your password to grant sudo permissions.\033[0m"
            echo
        fi
        sudo rm -f "$HOME/Downloads/ms-version.json"
    elif [[ "$status" != 0 ]]; then
        echo -e "\033[91mAn unknown error has occurred: C-99.\033[0m"
        echo -e "\033[91mThis is unexpected, please contact support.\033[0m"
        echo
        exit
    fi

    local error=$(touch "$HOME/Downloads/ms-version.json" 2>&1)
    local status=$?
    if echo "$error" | grep -q "Operation not permitted"; then
        center "\033[91mTerminal is unable to access your Downloads folder.\033[0m"
        center "\033[91mPlease grant Full Disk Access to Terminal and try again.\033[0m"
        echo
        open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        exit
    elif echo "$error" | grep -q "Permission denied"; then
        if ! can_sudo; then
            center "\033[91mTerminal is unable to access your Downloads folder.\033[0m"
            center "\033[91mPlease enter your password to grant sudo permissions.\033[0m"
            echo
        fi

        local error=$(sudo touch "$HOME/Downloads/ms-version.json" 2>&1)
        local status=$?
        if echo "$error" | grep -q "Permission denied"; then
            center "\033[91mTerminal was unable to access your Downloads folder.\033[0m"
            center "\033[91mPlease contact support for help.\033[0m"
            echo
            exit
        elif echo "$error" | grep -q "is not in the sudoers file."; then
            center "\033[91mTerminal was unable to access your user folder.\033[0m"
            center "\033[91mPlease contact support for help.\033[0m"
            echo
            exit
        elif [[ "$status" != 0 ]]; then
            center "\033[91mAn unknown error has occurred: C-02.\033[0m"
            center "\033[91mThis is unexpected, please contact support.\033[0m"
            echo
            exit
        fi
        sudo chown "$USER" "$HOME/Downloads/ms-version.json"
    elif [[ "$status" != 0 ]]; then
        center "\033[91mAn unknown error has occurred: C-03.\033[0m"
        center "\033[91mThis is unexpected, please contact support.\033[0m"
        echo
        exit
    fi

    local deleted=false
    if [[ -d "/Applications/Roblox.app" ]]; then
        local error=$(rm -rf /Applications/Roblox.app 2>&1)
        local status=$?
        if echo "$error" | grep -q "Permission denied"; then
            if ! can_sudo; then
                center "\033[91mTerminal is unable to access your current Roblox installation.\033[0m"
                center "\033[91mPlease enter your password to grant sudo permissions.\033[0m"
                echo
            fi
            sudo rm -rf /Applications/Roblox.app
        elif [[ "$status" != 0 ]]; then
            center "\033[91mAn unknown error has occurred: C-04.\033[0m"
            center "\033[91mThis is unexpected, please contact support.\033[0m"
            echo
            exit
        fi
        center "\033[37mDeleted existing Roblox installation.\033[0m"
        deleted=true
    fi

    if [[ -d "$HOME/Applications/Roblox.app" ]]; then
        local error=$(rm -rf "$HOME/Applications/Roblox.app" 2>&1)
        local status=$?
        if echo "$error" | grep -q "Permission denied"; then
            if ! can_sudo; then
                center "\033[91mTerminal is unable to access your current Roblox installation.\033[0m"
                center "\033[91mPlease enter your password to grant sudo permissions.\033[0m"
                echo
            fi
            sudo rm -rf "$HOME/Applications/Roblox.app"
        elif [[ "$status" != 0 ]]; then
            center "\033[91mAn unknown error has occurred: C-05.\033[0m"
            center "\033[91mThis is unexpected, please contact support.\033[0m"
            echo
            exit
        fi
        center "\033[37mDeleted existing user branch Roblox installation.\033[0m"
        deleted=true
    fi

    if [[ -d "/Applications/MacSploit.app" ]]; then
        local error=$(rm -rf "/Applications/MacSploit.app" 2>&1)
        local status=$?
        if echo "$error" | grep -q "Permission denied"; then
            if ! can_sudo; then
                center "\033[91mTerminal is unable to access your current MacSploit installation.\033[0m"
                center "\033[91mPlease enter your password to grant sudo permissions.\033[0m"
                echo
            fi
            sudo rm -rf "/Applications/MacSploit.app"
        elif [[ "$status" != 0 ]]; then
            center "\033[91mAn unknown error has occurred: C-06.\033[0m"
            center "\033[91mThis is unexpected, please contact support.\033[0m"
            echo
            exit
        fi
        center "\033[37mDeleted existing MacSploit installation.\033[0m"
        deleted=true
    fi

    if [[ -d "$HOME/Applications/MacSploit.app" ]]; then
        local error=$(rm -rf "$HOME/Applications/MacSploit.app" 2>&1)
        local status=$?
        if echo "$error" | grep -q "Permission denied"; then
            if ! can_sudo; then
                center "\033[91mTerminal is unable to access your current MacSploit installation.\033[0m"
                center "\033[91mPlease enter your password to grant sudo permissions.\033[0m"
                echo
            fi
            sudo rm -rf "$HOME/Applications/MacSploit.app"
        elif [[ "$status" != 0 ]]; then
            center "\033[91mAn unknown error has occurred: C-07.\033[0m"
            center "\033[91mThis is unexpected, please contact support.\033[0m"
            echo
            exit
        fi
        center "\033[37mDeleted existing user branch MacSploit installation.\033[0m"
        deleted=true
    fi

    if [[ "$deleted" == true ]]; then
        echo # Bring minimal beauty
    fi

    if [[ "$ARCH" == "arm64" ]] && ! /usr/bin/pgrep -q oahd; then
        center "\033[91mRosetta is not installed on your system.\033[0m"
        center "\033[91mThis is required since MacSploit runs on top of Rosetta.\033[0m"
        echo
        center "Do you want to install Rosetta? (Y/N): \c"
        while read -n 1 -r answer; do
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                echo
                echo
                softwareupdate --install-rosetta --agree-to-license
                # restart from the start
                print_title
                check_requirements
                check_permissions
            elif [[ "$answer" =~ ^[Nn]$ ]]; then
                echo
                echo
                exit
            fi
        done
    fi
}

check_version() {
    if [[ "$ARCH" == "arm64" ]]; then
        curl -s "$BASE_URL/jq-macos-arm64" -o "$PWD/jq"
    else
        curl -s "$BASE_URL/jq-macos-amd64" -o "$PWD/jq"
    fi
    chmod +x "$PWD/jq"

    local roblox_version_info=$(curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer")
    local roblox_version=$(echo "$roblox_version_info" | "$PWD/jq" -r ".clientVersionUpload")
    center "✅ \033[1;34mRoblox\033[0m | $roblox_version"

    VERSION_INFO=$(curl -s "$BASE_URL/version.json")
    VERSION=$(echo $VERSION_INFO | "$PWD/jq" -r ".clientVersionUpload")

    if [[ "$VERSION" == "$roblox_version" ]]; then
        center "✅ \033[1;35mMacSploit\033[0m | $VERSION"
        sleep 1
    else
        center "❗ \033[1;35mMacSploit\033[0m | \033[33m$VERSION\033[0m"
        center "\033[33mMacSploit is not updated to the latest version of Roblox.\033[0m"
        center "\033[33mThis does not mean MacSploit would not work at all.\033[0m"
        center "\033[33mThanks to update hooks, MacSploit may still function for a few days.\033[0m"
        echo
        center "Do you want to proceed? (Y/N): \c"
        while read -n 1 -r answer; do
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                break
            elif [[ "$answer" =~ ^[Nn]$ ]]; then
                echo
                echo
                exit
            fi
        done
    fi
}

install_roblox() {
    print_title
    center "📥 \033[1;34mDownloading RobloxPlayer...\033[0m"
    echo
    if [[ "$ARCH" == "arm64" ]]; then
        curl -# "https://setup.rbxcdn.com/mac/arm64/$VERSION-RobloxPlayer.zip" -o "$PWD/RobloxPlayer.zip"
    else
        curl -# "https://setup.rbxcdn.com/mac/$VERSION-RobloxPlayer.zip" -o "$PWD/RobloxPlayer.zip"
    fi
    echo

    center "⚙️  \033[1;34mInstalling RobloxPlayer...\033[0m"
    echo

    /usr/bin/unzip -o -q "$PWD/RobloxPlayer.zip" -d "$PWD"
    rm -rf "$PWD/RobloxPlayer.app/Contents/MacOS/Roblox.app"
    rm -rf "$PWD/RobloxPlayer.app/Contents/MacOS/RobloxPlayerInstaller.app"

    local error=$(mv "$PWD/RobloxPlayer.app" "$APPDIR/Roblox.app" 2>&1)
    local status=$?
    if echo "$error" | grep -q "Permission denied"; then
        if ! can_sudo; then
            center "\033[91mTerminal is unable to access your Applications folder.\033[0m"
            center "\033[91mPlease enter your password to grant sudo permissions.\033[0m"
            echo
        fi

        local error=$(sudo mv "$PWD/RobloxPlayer.app" "$APPDIR/Roblox.app" 2>&1)
        local status=$?
        if echo "$error" | grep -q "Permission denied"; then
            center "\033[91mTerminal was unable to access your Applications folder.\033[0m"
            center "\033[91mPlease contact support for help.\033[0m"
            echo
            exit
        elif echo "$error" | grep -q "is not in the sudoers file."; then
            APPDIR="$HOME/Applications"

            local error=$(mv "$PWD/RobloxPlayer.app" "$APPDIR/Roblox.app" 2>&1)
            local status=$?
            if echo "$error" | grep -q "Permission denied"; then
                center "\033[91mTerminal was unable to access your user folder.\033[0m"
                center "\033[91mPlease contact support for help.\033[0m"
                echo
                exit
            elif [[ "$status" != 0 ]]; then
                center "\033[91mAn unknown error has occurred: C-08.\033[0m"
                center "\033[91mThis is unexpected, please contact support.\033[0m"
                echo
                exit
            fi
        elif [[ "$status" != 0 ]]; then
            center "\033[91mAn unknown error has occurred: C-08.\033[0m"
            center "\033[91mThis is unexpected, please contact support.\033[0m"
            echo
            exit
        fi
    elif [[ "$status" != 0 ]]; then
        center "\033[91mAn unknown error has occurred: C-08.\033[0m"
        center "\033[91mThis is unexpected, please contact support.\033[0m"
        echo
        exit
    fi
}

patch_roblox() {
    print_title
    center "📥 \033[1;35mDownloading MacSploit DYLIB...\033[0m"
    echo
    if [[ "$ARCH" == "arm64" ]]; then
        curl -# "$BASE_URL/macsploit_arm64.dylib" -o "$PWD/macsploit.dylib"
    else 
        curl -# "$BASE_URL/macsploit_x86_64.dylib" -o "$PWD/macsploit.dylib"
    fi
    curl -# "$BASE_URL/insert_dylib" -o "$PWD/insert_dylib"
    echo

    center "📥 \033[1;35mDownloading MacSploit Patch...\033[0m"
    echo
    if [[ "$ARCH" == "arm64" ]]; then
        curl -# "$PATCH_URL/interpose_arm64.dylib" -o "$PWD/interpose.dylib"
    else 
        curl -# "$PATCH_URL/interpose_x86_64.dylib" -o "$PWD/interpose.dylib"
    fi
    echo

    center "⚙️  \033[1;35mPatching RobloxPlayer...\033[0m"
    if [[ "$ARCH" == "arm64" ]]; then
        /usr/bin/codesign --remove-signature "$APPDIR/Roblox.app"
    fi

    if ! mv "$PWD/macsploit.dylib" "$APPDIR/Roblox.app/Contents/MacOS/macsploit.dylib"; then
        echo
        center "\033[91mAn unknown error has occurred: C-09.\033[0m"
        center "\033[91mThis is unexpected, please contact support.\033[0m"
        echo
        exit
    fi

    if ! mv "$PWD/interpose.dylib" "$APPDIR/Roblox.app/Contents/MacOS/interpose.dylib"; then
        echo
        center "\033[91mAn unknown error has occurred: C-09.\033[0m"
        center "\033[91mThis is unexpected, please contact support.\033[0m"
        echo
        exit
    fi

    chmod +x "$PWD/insert_dylib"
    local output=$("$PWD/insert_dylib" "$APPDIR/Roblox.app/Contents/MacOS/macsploit.dylib" "$APPDIR/Roblox.app/Contents/MacOS/RobloxPlayer" "$APPDIR/Roblox.app/Contents/MacOS/RobloxPlayer" --overwrite --strip-codesig --all-yes)
    if ! echo "$output" | grep -q "Added LC_LOAD_DYLIB to"; then
        center "\033[91mTerminal was unable to patch RobloxPlayer.\033[0m"
        center "\033[91mThis is usually caused by anti-virus softwares.\033[0m"
        center "\033[91mIf you have one running, please disable it and try again.\033[0m"
        echo
        exit
    fi
    local output=$("$PWD/insert_dylib" "$APPDIR/Roblox.app/Contents/MacOS/interpose.dylib" "$APPDIR/Roblox.app/Contents/MacOS/RobloxPlayer" "$APPDIR/Roblox.app/Contents/MacOS/RobloxPlayer" --overwrite --strip-codesig --all-yes)
    if ! echo "$output" | grep -q "Added LC_LOAD_DYLIB to"; then
        center "\033[91mTerminal was unable to patch RobloxPlayer.\033[0m"
        center "\033[91mThis is usually caused by anti-virus softwares.\033[0m"
        center "\033[91mIf you have one running, please disable it and try again.\033[0m"
        echo
        exit
    fi

    curl -# "$PATCH_URL/rewriter" -o "$PWD/rewriter"
    chmod +x "$PWD/rewriter"
    local output=$("$PWD/rewriter" "$APPDIR/Roblox.app")
    if ! echo "$output" | grep -q "Patch applied successfully"; then
        center "\033[91mTerminal was unable to patch RobloxPlayer.\033[0m"
        center "\033[91mThis is usually caused by anti-virus softwares.\033[0m"
        center "\033[91mIf you have one running, please disable it and try again.\033[0m"
        echo
        exit
    fi

    if [[ "$ARCH" == "arm64" ]]; then
        echo
        center "🖊️  \033[1;36mSigning RobloxPlayer...\033[0m"
        /usr/bin/codesign --force --sign - --timestamp=none "$APPDIR/Roblox.app/Contents/MacOS/macsploit.dylib"
        /usr/bin/codesign --force --sign - --timestamp=none "$APPDIR/Roblox.app/Contents/MacOS/interpose.dylib"
        /usr/bin/codesign -s - "$APPDIR/Roblox.app"
    fi
}

install_macsploit() {
    print_title
    center "📥 \033[1;35mDownloading MacSploit...\033[0m"
    echo
    curl -# "$BASE_URL/MacSploit.zip" -o "$PWD/MacSploit.zip"
    echo

    center "⚙️  \033[1;35mInstalling MacSploit...\033[0m"

    /usr/bin/unzip -o -q "$PWD/MacSploit.zip" -d "$PWD"
    if ! mv "$PWD/MacSploit.app" "$APPDIR/MacSploit.app"; then
        echo
        center "\033[91mAn unknown error has occurred: C-10.\033[0m"
        center "\033[91mThis is unexpected, please contact support.\033[0m"
        echo
        exit
    fi
}

clean_up() {
    print_title
    center "🧹 \033[1;36mCleaning Up...\033[0m"
    echo

    local error=$(echo "$VERSION_INFO" > "$HOME/Downloads/ms-version.json" 2>&1)
    local status=$?
    if echo "$error" | grep -q "Permission denied"; then
        if ! can_sudo; then
            center "\033[91mTerminal is unable to access your Downloads folder.\033[0m"
            center "\033[91mPlease enter your password to grant sudo permissions.\033[0m"
            echo
        fi

        local error=$(sudo echo "$VERSION_INFO" > "$HOME/Downloads/ms-version.json" 2>&1)
        local status=$?
        if echo "$error" | grep -q "Permission denied"; then
            center "\033[91mTerminal was unable to access your Downloads folder.\033[0m"
            center "\033[91mPlease contact support for help.\033[0m"
            echo
            exit
        elif echo "$error" | grep -q "is not in the sudoers file."; then
            center "\033[91mTerminal was unable to access your user folder.\033[0m"
            center "\033[91mPlease contact support for help.\033[0m"
            echo
            exit
        elif [[ "$status" != 0 ]]; then
            center "\033[91mAn unknown error has occurred: C-11.\033[0m"
            center "\033[91mThis is unexpected, please contact support.\033[0m"
            echo
            exit
        fi
    elif [[ "$status" != 0 ]]; then
        center "\033[91mAn unknown error has occurred: C-12.\033[0m"
        center "\033[91mThis is unexpected, please contact support.\033[0m"
        echo
        exit
    fi

    rm -rf "$PWD"

    center '✨ \033[1;32mInstallation Complete!\033[0m'
    echo
}

center() {
    local text="$1"
    local cols=$(tput cols)
    local plaintext=$(echo -e "$text" | sed "s/\x1B\[[0-9;]*m//g")
    local pad=$(((cols - ${#plaintext}) / 2))
    printf "%*s%b\n" "$pad" "" "$text"
}

can_sudo() {
    sudo -n true 2>/dev/null
}

get_hwid() {
    # ChatGPT'd; don't ask how this works
    # basically you grab the IOPlatformUUID then SHA1 it for the HWID
    ioreg -rd1 -c IOPlatformExpertDevice | awk -F\" '/IOPlatformUUID/{print $4}' | tr -d "\n" | shasum | cut -f1 -d " "
}

print_title
authenticate
check_requirements
check_permissions
check_version
install_roblox
patch_roblox
install_macsploit
clean_up
