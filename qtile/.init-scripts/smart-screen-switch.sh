#!/usr/bin/env bash

# Smart screen switching that preserves relative pointer position
# Usage: smart-screen-switch.sh [next|prev|0|1|2]

get_pointer_info() {
    xdotool getmouselocation --shell
}

get_screen_geometry() {
    xrandr --query | grep " connected" | while read -r line; do
        if [[ $line =~ ([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+) ]]; then
            echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]} ${BASH_REMATCH[4]}"
        fi
    done
}

find_current_screen() {
    local pointer_x=$1
    local pointer_y=$2
    local screen_index=0

    while IFS=' ' read -r width height x_offset y_offset; do
        if (( pointer_x >= x_offset && pointer_x < x_offset + width && 
              pointer_y >= y_offset && pointer_y < y_offset + height )); then
            echo $screen_index
            return
        fi
        ((screen_index++))
    done < <(get_screen_geometry)

    echo 0
}

get_screen_count() {
    get_screen_geometry | wc -l
}

switch_to_screen() {
    local target_screen=$1

    eval $(get_pointer_info)
    local current_x=$X
    local current_y=$Y

    local current_screen=$(find_current_screen $current_x $current_y)
    local screen_count=$(get_screen_count)

    if [[ "$target_screen" == "next" ]]; then
        target_screen=$(( (current_screen + 1) % screen_count ))
    elif [[ "$target_screen" == "prev" ]]; then
        target_screen=$(( (current_screen - 1 + screen_count) % screen_count ))
    fi

    if (( target_screen >= screen_count )); then
        target_screen=0
    fi

    if (( target_screen == current_screen )); then
        return
    fi

    local screen_info=($(get_screen_geometry | sed -n "$((target_screen + 1))p"))
    local current_info=($(get_screen_geometry | sed -n "$((current_screen + 1))p"))

    if [[ ${#screen_info[@]} -eq 4 && ${#current_info[@]} -eq 4 ]]; then
        local current_width=${current_info[0]}
        local current_height=${current_info[1]}
        local current_x_offset=${current_info[2]}
        local current_y_offset=${current_info[3]}

        local target_width=${screen_info[0]}
        local target_height=${screen_info[1]}
        local target_x_offset=${screen_info[2]}
        local target_y_offset=${screen_info[3]}

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

case "${1:-next}" in
    next|prev|[0-9])
        switch_to_screen "$1"
        ;;
    *)
        echo "Usage: $0 [next|prev|0|1|2]"
        exit 1
        ;;
esac
