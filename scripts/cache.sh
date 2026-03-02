#!/bin/bash

# Cache management for scripter libraries
CACHE_DIR="$HOME/.scripter_cache"
CACHE_EXPIRY=86400  # 24 hours in seconds

# Initialize cache directory
init_cache() {
    mkdir -p "$CACHE_DIR"
}

# Get cache file path for a URL
get_cache_path() {
    local url="$1"
    local filename=$(echo "$url" | sed 's|^.*/||' | sed 's/[^a-zA-Z0-9._-]/_/g')
    echo "$CACHE_DIR/$filename"
}

# Check if cache is valid (exists and not expired)
is_cache_valid() {
    local cache_file="$1"
    local current_time=$(date +%s)
    
    if [[ ! -f "$cache_file" ]]; then
        return 1
    fi
    
    local cache_time=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
    local age=$((current_time - cache_time))
    
    [[ $age -lt $CACHE_EXPIRY ]]
}

# Download and cache a URL
cache_download() {
    local url="$1"
    local cache_file=$(get_cache_path "$url")
    
    init_cache
    
    if is_cache_valid "$cache_file"; then
        cat "$cache_file"
        return 0
    fi
    
    # Download with timeout and retry
    local content
    if content=$(curl -sL --connect-timeout 10 --max-time 30 --retry 2 "$url" 2>/dev/null); then
        echo "$content" > "$cache_file"
        echo "$content"
        return 0
    else
        # If download fails but we have old cache, use it
        if [[ -f "$cache_file" ]]; then
            cat "$cache_file"
            return 0
        fi
        return 1
    fi
}

# Clear cache
clear_cache() {
    rm -rf "$CACHE_DIR"
    init_cache
}

# Cache status
cache_status() {
    if [[ ! -d "$CACHE_DIR" ]]; then
        echo "Cache not initialized"
        return
    fi
    
    local cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
    local cache_files=$(find "$CACHE_DIR" -type f 2>/dev/null | wc -l)
    
    echo "Cache directory: $CACHE_DIR"
    echo "Cache size: $cache_size"
    echo "Cached files: $cache_files"
    
    # Show cache ages
    echo ""
    echo "Cache ages:"
    find "$CACHE_DIR" -type f -exec stat -c "%n %Y" {} \; 2>/dev/null | while read -r file mtime; do
        local age=$(($(date +%s) - mtime))
        local hours=$((age / 3600))
        local filename=$(basename "$file")
        printf "  %-30s %d hours ago\n" "$filename" "$hours"
    done
}