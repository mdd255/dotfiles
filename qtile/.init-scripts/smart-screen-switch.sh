#!/usr/bin/env bash

# Smart screen switching that preserves relative pointer position
# Usage: smart-screen-switch.sh [next|prev|0|1|2]

declare -a SCREEN_DATA
declare SCREEN_COUNT

cache_screen_data() {
    local geometry_output
    geometry_output=$(xrandr --query | grep " connected")

    SCREEN_DATA=()
    SCREEN_COUNT=0

    while read -r line; do
        if [[ $line =~ ([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+) ]]; then
            SCREEN_DATA[SCREEN_COUNT]="${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]} ${BASH_REMATCH[4]}"
            ((SCREEN_COUNT++))
        fi
    done <<< "$geometry_output"
}

get_pointer_info() {
    xdotool getmouselocation --shell
}

find_current_screen() {
    local pointer_x=$1
    local pointer_y=$2
    local screen_index=0

    for ((i=0; i<SCREEN_COUNT; i++)); do
        local screen_info=(${SCREEN_DATA[i]})
        local width=${screen_info[0]}
        local height=${screen_info[1]}
        local x_offset=${screen_info[2]}
        local y_offset=${screen_info[3]}

        if (( pointer_x >= x_offset && pointer_x < x_offset + width &&
                pointer_y >= y_offset && pointer_y < y_offset + height )); then
            echo $i
            return
        fi
    done

    echo 0
}

switch_to_screen() {
    local target_screen=$1

    eval $(get_pointer_info)
    local current_x=$X
    local current_y=$Y

    local current_screen=$(find_current_screen $current_x $current_y)

    if [[ "$target_screen" == "next" ]]; then
        target_screen=$(( (current_screen + 1) % SCREEN_COUNT ))
    elif [[ "$target_screen" == "prev" ]]; then
        target_screen=$(( (current_screen - 1 + SCREEN_COUNT) % SCREEN_COUNT ))
    fi

    if (( target_screen >= SCREEN_COUNT )); then
        target_screen=0
    fi

    if (( target_screen == current_screen )); then
        return
    fi

    local current_info=(${SCREEN_DATA[current_screen]})
    local target_info=(${SCREEN_DATA[target_screen]})

    if [[ ${#current_info[@]} -eq 4 && ${#target_info[@]} -eq 4 ]]; then
        local current_width=${current_info[0]}
        local current_height=${current_info[1]}
        local current_x_offset=${current_info[2]}
        local current_y_offset=${current_info[3]}

        local target_width=${target_info[0]}
        local target_height=${target_info[1]}
        local target_x_offset=${target_info[2]}
        local target_y_offset=${target_info[3]}

        local rel_x=$(( (current_x - current_x_offset) * 100 / current_width ))
        local rel_y=$(( (current_y - current_y_offset) * 100 / current_height ))

        local new_x=$(( target_x_offset + (rel_x * target_width / 100) ))
        local new_y=$(( target_y_offset + (rel_y * target_height / 100) ))

        qtile cmd-obj -o cmd -f next_screen
        xdotool mousemove $new_x $new_y
    else
        qtile cmd-obj -o cmd -f next_screen
    fi
}

cache_screen_data

case "${1:-next}" in
    next|prev|[0-9])
        switch_to_screen "$1"
        ;;
    *)
        echo "Usage: $0 [next|prev|0|1|2]"
        exit 1
        ;;
esac
