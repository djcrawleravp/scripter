#!/bin/bash

# Compatibility and Performance Test Script for Scripter
# Tests all major components and validates Debian 13 compatibility

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Import Header directly from local file
if [[ -f "$SCRIPT_DIR/scripts/header.sh" ]]; then
    source "$SCRIPT_DIR/scripts/header.sh"
else
    echo "Error: header.sh not found in $SCRIPT_DIR/scripts/"
    exit 1
fi

script_name "SCRIPTER COMPATIBILITY TEST"

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Test functions
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TESTS_TOTAL++))
    echo ""
    title "Test: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo "✓ PASSED: $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAILED: $test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Start testing
echo "Starting comprehensive compatibility tests..."
echo "Debian Version: $DEBIAN_VERSION ($DEBIAN_CODENAME)"

# Test 1: Cache System
run_test "Cache Directory Creation" "mkdir -p '$HOME/.scripter_cache' && test -d '$HOME/.scripter_cache'"
run_test "Cache Download Function" "type cache_download >/dev/null"

# Test 2: Package Management
run_test "Package Tracking Initialization" "init_package_tracking && test -f '$INSTALLED_PACKAGES_FILE'"
run_test "Package Detection" "is_package_installed 'bash'"  # bash should always be installed
run_test "Package Availability Check" "type check_package_availability >/dev/null"

# Test 3: Process Management
run_test "Printimir Functions Available" "type print_wait >/dev/null"
run_test "Process Cleanup Functions" "type wait_stop >/dev/null"

# Test 4: Debian Version Detection
run_test "Debian Version Detected" "[ -n '$DEBIAN_VERSION' ]"
run_test "Debian Codename Detected" "[ -n '$DEBIAN_CODENAME' ]"

# Test 5: Essential Commands Availability
run_test "curl Available" "command -v curl >/dev/null"
run_test "wget Available" "command -v wget >/dev/null"
run_test "apt Available" "command -v apt >/dev/null"
run_test "dpkg Available" "command -v dpkg >/dev/null"

# Test 6: Script Files Syntax
run_test "Header.sh Syntax" "bash -n '$SCRIPT_DIR/scripts/header.sh'"
run_test "Printimir.sh Syntax" "bash -n '$SCRIPT_DIR/scripts/printimir.sh'"
run_test "Sudero.sh Syntax" "bash -n '$SCRIPT_DIR/scripts/sudero.sh'"

# Test 7: Installer Scripts Syntax
run_test "Debian Autoexpander Syntax" "bash -n '$SCRIPT_DIR/installers/Install-Debian-SDA1-Autoexpander.sh'"
run_test "Windsurf Installer Syntax" "bash -n '$SCRIPT_DIR/installers/Install-WindSurf.sh'"
run_test "Antigravity Installer Syntax" "bash -n '$SCRIPT_DIR/installers/Install-Antigravity.sh'"
run_test "RDP Fixer Syntax" "bash -n '$SCRIPT_DIR/installers/Install-RDP-Fixer.sh'"

# Test 8: Package Repository URLs (connectivity tests)
echo ""
title "Connectivity Tests"

test_url() {
    local url="$1"
    local name="$2"
    
    ((TESTS_TOTAL++))
    if curl -sL --connect-timeout 10 --max-time 30 "$url" >/dev/null 2>&1; then
        echo "✓ PASSED: $name"
        ((TESTS_PASSED++))
        return 0
    else
        echo "✗ FAILED: $name"
        ((TESTS_FAILED++))
        return 1
    fi
}

test_url "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/scripts/header.sh" "GitHub Repository Access"
test_url "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" "Windsurf GPG Key"
test_url "https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg" "Antigravity GPG Key"

# Test 9: Performance Benchmarks
echo ""
title "Performance Benchmarks"

# Cache performance test
start_time=$(date +%s.%N)
cache_download "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/scripts/header.sh" >/dev/null 2>&1
first_download_time=$(echo "$(date +%s.%N) - $start_time" | bc)

start_time=$(date +%s.%N)
cache_download "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/scripts/header.sh" >/dev/null 2>&1
second_download_time=$(echo "$(date +%s.%N) - $start_time" | bc)

echo "First download: ${first_download_time}s"
echo "Cached download: ${second_download_time}s"

if (( $(echo "$second_download_time < $first_download_time * 0.5" | bc -l) )); then
    echo "✓ PASSED: Cache provides significant speed improvement"
    ((TESTS_PASSED++))
else
    echo "✗ FAILED: Cache not providing expected performance improvement"
    ((TESTS_FAILED++))
fi
((TESTS_TOTAL++))

# Test 10: Debian 13 Specific Checks
if [[ "$DEBIAN_VERSION" == "13" ]] || [[ "$DEBIAN_CODENAME" == "trixie" ]]; then
    echo ""
    title "Debian 13 (Trixie) Specific Tests"
    
    # Check for Trixie-specific package availability
    run_test "cloud-guest-utils Available" "apt-cache show cloud-guest-utils >/dev/null 2>&1"
    run_test "systemd User Services Available" "systemctl --user --version >/dev/null 2>&1"
    run_test "GNOME Shell Integration Available" "command -v gsettings >/dev/null 2>&1"
fi

# Final Results
echo ""
title "TEST RESULTS"
echo "Total Tests: $TESTS_TOTAL"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}🎉 All tests passed! System is ready for scripter.${RESET}"
    exit 0
else
    echo -e "${C_RED_BOLD}⚠️  $TESTS_FAILED test(s) failed. Please review issues above.${RESET}"
    exit 1
fi