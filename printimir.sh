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

    local EDIBLE=("guarapo" "moco chinchi" "chuflay" "cuñapé" "pan de arroz" "asadito" "bolito" "cheruje")
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
                "Will you accept this $RANDOM_EDIBLE while you wait?"
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
    while true; do
        printf "\r\033[K%s" "$(_generate_phrase wait)"
        sleep 5
    done
}

# --- PUBLIC FUNCTIONS ---
print_wait() {
    _wait_loop &
    PRINTIMIR_PID=$!
}

wait_stop() {
    if [ -n "$PRINTIMIR_PID" ]; then
        kill $PRINTIMIR_PID 2>/dev/null
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

    print_wait
    if eval "$cmd" > /dev/null 2>&1; then
        wait_stop
        print_done
    else
        wait_stop
        print_error "$error_msg"
        exit 1
    fi
}