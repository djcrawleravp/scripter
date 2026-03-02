#!/bin/bash

# Package installation optimization with parallel processing and deduplication

# Global package tracking
INSTALLED_PACKAGES_FILE="$HOME/.scripter_installed_packages"
PACKAGE_LOCK_DIR="/tmp/scripter_package_locks"

# Initialize package tracking
init_package_tracking() {
    mkdir -p "$PACKAGE_LOCK_DIR"
    [[ ! -f "$INSTALLED_PACKAGES_FILE" ]] && touch "$INSTALLED_PACKAGES_FILE"
}

# Check if package is already installed
is_package_installed() {
    local package="$1"
    dpkg -l | grep -q "^ii  $package " 2>/dev/null
}

# Mark package as installed in our tracking
mark_package_installed() {
    local package="$1"
    echo "$package" >> "$INSTALLED_PACKAGES_FILE"
    sort -u "$INSTALLED_PACKAGES_FILE" > "${INSTALLED_PACKAGES_FILE}.tmp"
    mv "${INSTALLED_PACKAGES_FILE}.tmp" "$INSTALLED_PACKAGES_FILE"
}

# Check if we previously installed this package
was_package_installed_by_scripter() {
    local package="$1"
    grep -q "^$package$" "$INSTALLED_PACKAGES_FILE" 2>/dev/null
}

# Install packages with optimization
install_packages() {
    local packages=("$@")
    local packages_to_install=()
    local update_needed=false
    
    init_package_tracking
    
    # Filter out already installed packages
    for package in "${packages[@]}"; do
        if is_package_installed "$package"; then
            echo "✓ $package already installed"
        elif was_package_installed_by_scripter "$package"; then
            echo "✓ $package installed by scripter previously"
        else
            packages_to_install+=("$package")
        fi
    done
    
    if [[ ${#packages_to_install[@]} -eq 0 ]]; then
        echo "All packages already available"
        return 0
    fi
    
    # Update package list only if needed
    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        echo "Updating package list..."
        if ! ${SUDO_CMD}apt-get update -qq; then
            echo "Failed to update package list"
            return 1
        fi
    fi
    
    # Install packages in batches for better performance
    local batch_size=10
    for ((i=0; i<${#packages_to_install[@]}; i+=batch_size)); do
        local batch=("${packages_to_install[@]:i:batch_size}")
        
        echo "Installing batch: ${batch[*]}"
        if ${SUDO_CMD}apt-get install -y "${batch[@]}"; then
            for package in "${batch[@]}"; do
                mark_package_installed "$package"
            done
        else
            echo "Failed to install batch: ${batch[*]}"
            return 1
        fi
    done
    
    echo "Successfully installed: ${packages_to_install[*]}"
}

# Parallel package installation for independent packages
install_packages_parallel() {
    local packages=("$@")
    local pids=()
    local temp_files=()
    
    init_package_tracking
    
    # Create temporary files for each package
    for package in "${packages[@]}"; do
        if ! is_package_installed "$package" && ! was_package_installed_by_scripter "$package"; then
            local temp_file=$(mktemp)
            temp_files+=("$temp_file")
            
            # Install package in background
            {
                if ${SUDO_CMD}apt-get install -y "$package" >/dev/null 2>&1; then
                    echo "SUCCESS:$package" > "$temp_file"
                else
                    echo "FAILED:$package" > "$temp_file"
                fi
            } &
            
            pids+=($!)
        fi
    done
    
    # Wait for all installations and collect results
    local failed_packages=()
    for i in "${!pids[@]}"; do
        wait "${pids[i]}"
        local result=$(cat "${temp_files[i]}")
        if [[ "$result" == SUCCESS:* ]]; then
            local package="${result#SUCCESS:}"
            mark_package_installed "$package"
            echo "✓ $package installed successfully"
        else
            local package="${result#FAILED:}"
            failed_packages+=("$package")
            echo "✗ Failed to install $package"
        fi
        rm -f "${temp_files[i]}"
    done
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        echo "Failed packages: ${failed_packages[*]}"
        return 1
    fi
}

# Add repository with error handling
add_repository() {
    local repo_name="$1"
    local repo_url="$2"
    local key_url="$3"
    local key_file="$4"
    
    echo "Adding repository: $repo_name"
    
    # Add GPG key
    if [[ -n "$key_url" ]] && [[ -n "$key_file" ]]; then
        ${SUDO_CMD}mkdir -p /etc/apt/keyrings
        if ! curl -fsSL "$key_url" | ${SUDO_CMD}gpg --dearmor --yes -o "$key_file"; then
            echo "Failed to add GPG key for $repo_name"
            return 1
        fi
    fi
    
    # Add repository
    if [[ -n "$repo_url" ]]; then
        echo "$repo_url" | ${SUDO_CMD}tee "/etc/apt/sources.list.d/${repo_name}.list" >/dev/null
        if [[ $? -ne 0 ]]; then
            echo "Failed to add repository $repo_name"
            return 1
        fi
    fi
    
    echo "Successfully added repository: $repo_name"
    return 0
}

# Clean up package tracking
cleanup_package_tracking() {
    rm -rf "$PACKAGE_LOCK_DIR"
}