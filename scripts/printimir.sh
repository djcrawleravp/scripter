#!/bin/bash

# --- VARIABLES AND COLORS ---
PRINTIMIR_PID=""
C_GREEN='\033[0;32m'
C_RED_BOLD='\033[1;31m'
C_RESET='\033[0m'

# --- PHRASE GENERATOR ENGINE ---
_generate_phrase() {
    local ACTION="$1"
    local MESSAGE="$2"

    local EDIBLE=("guarapito" "moco chinchi" "chuflay" "cuñapé" "pan de arroz" "salteña" "asadito" "bolito" "cheruje")
    local DUDE=("broder" "peji" "mijito" "mijita" "viejito" "socio" "hija" "oe")

    local RANDOM_EDIBLE=${EDIBLE[$((RANDOM % ${#EDIBLE[@]}))]}
    local RANDOM_DUDE=${DUDE[$((RANDOM % ${#DUDE[@]}))]}
    local PHRASE

    case "$ACTION" in
        wait)
            PHRASE=(
                "Hold my $RANDOM_EDIBLE..."
                "Take it easy $RANDOM_DUDE, almost there..."
                "Perate a u..."
                "One ratito please..."
                "Will you accept this $RANDOM_EDIBLE while we wait?"
            )
            ;;
        done)
            PHRASE=(
                "Mic drop..."
                "$RANDOM_DUDE, this will make you drop that $RANDOM_EDIBLE!"
                "Ready the chicken!"
                "The process is chalinga, you're gonna make the estrenito!"
                "At last parió the Donkey"
                "Yastá $RANDOM_DUDE!"
            )
            ;;
        error)
            PHRASE=(
                "Sorry $RANDOM_DUDE"
                "Va disculpar"
                "We're fried"
                "A la mierda la plata de las empanadas"
            )
            ;;
        *)
            echo "$ACTION $MESSAGE"
            return 0
            ;;
    esac

    local FINAL_OUTPUT=${PHRASE[$((RANDOM % ${#PHRASE[@]}))]}

    if [ -n "$MESSAGE" ] && [ "$ACTION" != "wait" ]; then
        FINAL_OUTPUT=$(echo "$FINAL_OUTPUT" | sed 's/\.*$//')
        if [ "$ACTION" == "error" ]; then
            FINAL_OUTPUT="${FINAL_OUTPUT}: ${MESSAGE}"
        else
            FINAL_OUTPUT="${FINAL_OUTPUT}, ${MESSAGE}..."
        fi
    fi

    FINAL_OUTPUT=$(echo "$FINAL_OUTPUT" | perl -pe 's/^([a-z])/\U$1/i; s/\. ([a-z])/. \U$1/g')
    echo "$FINAL_OUTPUT"
}

_wait_loop() {
    local count=0
    while true; do
        printf "\r\033[K%s" "$(_generate_phrase wait)"
        sleep 5
        ((count++))
        # Safety timeout after 10 minutes (120 * 5 seconds)
        if [[ $count -gt 120 ]]; then
            break
        fi
    done
}

# --- PUBLIC FUNCTIONS ---
print_wait() {
    _wait_loop &
    PRINTIMIR_PID=$!
}

wait_stop() {
    if [[ -n "$PRINTIMIR_PID" ]]; then
        # Kill entire process group to ensure cleanup
        kill -TERM "$PRINTIMIR_PID" 2>/dev/null
        # Wait a moment for graceful termination
        sleep 0.5
        # Force kill if still running
        kill -KILL "$PRINTIMIR_PID" 2>/dev/null
        # Clean up any zombie processes
        wait "$PRINTIMIR_PID" 2>/dev/null
        printf "\r\033[K"
        PRINTIMIR_PID=""
    fi
}

print_done() {
    local OUTPUT=$(_generate_phrase done "$1")
    echo -e "${C_GREEN}${OUTPUT}${C_RESET}"
}

print_error() {
    local OUTPUT=$(_generate_phrase error "$1")
    echo -e "${C_RED_BOLD}${OUTPUT}${C_RESET}"
}

run_step() {
    local error_msg="$1"
    shift
    local cmd="$@"
    local timeout=300  # 5 minutes default timeout

    print_wait
    
    # Run command with timeout in background
    eval "$cmd" > /dev/null 2>&1 &
    local cmd_pid=$!
    
    # Wait for command to complete or timeout
    local elapsed=0
    while kill -0 "$cmd_pid" 2>/dev/null; do
        sleep 1
        ((elapsed++))
        if [[ $elapsed -ge $timeout ]]; then
            kill -TERM "$cmd_pid" 2>/dev/null
            sleep 1
            kill -KILL "$cmd_pid" 2>/dev/null
            wait "$cmd_pid" 2>/dev/null
            wait_stop
            print_error "$error_msg (timeout after ${timeout}s)"
            echo ""
            exit 1
        fi
    done
    
    # Check command result
    if wait "$cmd_pid"; then
        wait_stop
        print_done
        echo ""
    else
        wait_stop
        print_error "$error_msg"
        echo ""
        exit 1
    fi
}