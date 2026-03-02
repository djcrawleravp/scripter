#!/bin/bash

# Debian version detection
detect_debian_version() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DEBIAN_VERSION="$VERSION_ID"
        DEBIAN_CODENAME="$VERSION_CODENAME"
    else
        DEBIAN_VERSION=$(cat /etc/debian_version 2>/dev/null | cut -d. -f1)
        DEBIAN_CODENAME="unknown"
    fi
    
    export DEBIAN_VERSION DEBIAN_CODENAME
}

# Package availability check
check_package_availability() {
    local package="$1"
    local alternative="$2"
    
    if apt-cache show "$package" >/dev/null 2>&1; then
        echo "$package"
    elif [[ -n "$alternative" ]] && apt-cache show "$alternative" >/dev/null 2>&1; then
        echo "$alternative"
    else
        echo "$package"  # Return original as fallback
    fi
}

# Initialize cache and detect system
detect_debian_version

RAW_BASE="https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main"
SCRIPTS="$RAW_BASE/scripts"
INSTALLERS="$RAW_BASE/installers"

# Cache management functions (inline to avoid circular dependency)
CACHE_DIR="$HOME/.scripter_cache"
CACHE_EXPIRY=86400

init_cache() { mkdir -p "$CACHE_DIR"; }

get_cache_path() {
    local url="$1"
    local filename=$(echo "$url" | sed 's|^.*/||' | sed 's/[^a-zA-Z0-9._-]/_/g')
    echo "$CACHE_DIR/$filename"
}

is_cache_valid() {
    local cache_file="$1"
    local current_time=$(date +%s)
    [[ -f "$cache_file" ]] && [[ $((current_time - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $CACHE_EXPIRY ]]
}

cache_download() {
    local url="$1"
    local cache_file=$(get_cache_path "$url")
    
    init_cache
    if is_cache_valid "$cache_file"; then
        cat "$cache_file"
        return 0
    fi
    
    local content
    if content=$(curl -sL --connect-timeout 10 --max-time 30 --retry 2 "$url" 2>/dev/null); then
        echo "$content" > "$cache_file"
        echo "$content"
    elif [[ -f "$cache_file" ]]; then
        cat "$cache_file"
    else
        return 1
    fi
}

# Import Libraries with caching
eval "$(cache_download "$SCRIPTS/sudero.sh")"
eval "$(cache_download "$SCRIPTS/printimir.sh")"

# Import package optimization (inline for performance)
INSTALLED_PACKAGES_FILE="$HOME/.scripter_installed_packages"
PACKAGE_LOCK_DIR="/tmp/scripter_package_locks"

init_package_tracking() {
    mkdir -p "$PACKAGE_LOCK_DIR"
    [[ ! -f "$INSTALLED_PACKAGES_FILE" ]] && touch "$INSTALLED_PACKAGES_FILE"
}

is_package_installed() {
    local package="$1"
    dpkg -l | grep -q "^ii  $package " 2>/dev/null
}

mark_package_installed() {
    local package="$1"
    echo "$package" >> "$INSTALLED_PACKAGES_FILE"
    sort -u "$INSTALLED_PACKAGES_FILE" > "${INSTALLED_PACKAGES_FILE}.tmp"
    mv "${INSTALLED_PACKAGES_FILE}.tmp" "$INSTALLED_PACKAGES_FILE"
}

was_package_installed_by_scripter() {
    local package="$1"
    grep -q "^$package$" "$INSTALLED_PACKAGES_FILE" 2>/dev/null
}

install_packages() {
    local packages=("$@")
    local packages_to_install=()
    
    init_package_tracking
    
    for package in "${packages[@]}"; do
        if ! is_package_installed "$package" && ! was_package_installed_by_scripter "$package"; then
            packages_to_install+=("$package")
        fi
    done
    
    if [[ ${#packages_to_install[@]} -eq 0 ]]; then
        return 0
    fi
    
    ${SUDO_CMD}apt-get update -qq && ${SUDO_CMD}apt-get install -y "${packages_to_install[@]}"
    
    for package in "${packages_to_install[@]}"; do
        mark_package_installed "$package"
    done
}

# Text Styles
BOLD_WHITE="\e[1;97m"
BOLD_YELLOW="\e[1;33m"
RESET="\e[0m"

# Title Counter
TITLE_COUNT=0

# Script Name
script_name() {
    clear
    local name="$1"
    echo -e "${BOLD_WHITE}----------------------------------------"
    echo "        INSTALLING $name             "
    echo -e "----------------------------------------${RESET}"
}

# Titles
title() {
    ((TITLE_COUNT++))
    local texto="${TITLE_COUNT}. $1"
    local largo=${#texto}
    local linea=$(printf '%*s' "$largo" | tr ' ' '-')
    echo -e "\n${BOLD_YELLOW}${texto}"
    echo -e "${linea}-${RESET}"
}

# NVM Bridge
npm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    command npm "$@"
}