#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

NC=$'\e[0m' # No Color
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
ORANGE=$'\x1B[33m'
YELLOW='\033[1;33m'
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'

# Displays Time in mins and seconds
function display_time {
    local T=$1
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    (( D > 0 )) && printf '%d days ' $D
    (( H > 0 )) && printf '%d hours ' $H
    (( M > 0 )) && printf '%d minutes ' $M
    (( D > 0 || H > 0 || M > 0 )) && printf 'and '
    printf '%d seconds\n' $S
}

function up(){
    start=$(date +%s)
    make up
    end=$(date +%s)
    runtime=$((end-start))
    echo -e "${GREEN}Setup Successful | $(display_time $runtime) ${NC}" 
}

function down(){
    start=$(date +%s)
    make down
    end=$(date +%s)
    runtime=$((end-start))
    echo -e "${GREEN}Teardown Successful | $(display_time $runtime) ${NC}" 
}

opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
case $choice in
    up)up $@;;
    down)down $@;;
    *) make help;;
esac
