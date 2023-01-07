#!/bin/bash

# How to use
# source "path/to/this/file"
# assemble-to-ics -h

assemble-to-ics() {
    #local sp="${BASH_SOURCE[0]}"
    local sp
    sp=$(realpath $0)
    sp="${sp%/*}"
    local timezoneFolder="${sp}/timezone"
    local timezone="${timezoneFolder}/america-toronto.txt"
    local output
    output="${sp}/$(date --iso-8601)-output.ics"
    local selectedCalendarList=("${sp}/plant/quebec/3b/")
    local verbose=0
    help() {
        echo "Build calendar. Path start from script's directory (${sp})"
        echo "-z: select timezone (default: ${timezone})"
        echo "-o: output file (default: ${output})"
        echo "-s: list of selected calendars. Can use regex (TODO: not working). (default: ${selectedCalendarList[*]}). repeat -s for every element. Example: assemble-to-ics -s path/1 -s path/2/ex.txt"
        echo "-v: verbose"
    }
    local sArg=0
    while getopts "z:o:s:vh" opt; do
        case $opt in
            s) #selected calendars
                if [ "$sArg" -eq 0 ]; then
                    sArg=1
                    selectedCalendarList=()
                fi
                selectedCalendarList=( "${selectedCalendarList[@]}" "$OPTARG" )
                ;; 
            o) # output file
                output="$OPTARG"
                ;;
            z) #Timezone
                timezone="$OPTARG"
                ;;
            v) verbose=1
                ;;
            h)
                help
                return 0
                ;;
            ?) echo "invalid option -$OPTARG" >&2
                help
                return 1
                ;;
        esac
    done
    if [ ! -f "$timezone" ]; then
        echo "Timezone file: $timezone doesn't exist."
        return 1
    fi
    local i=1
    local filename="${output%.*}"
    local ext="${output##*.}"
    local rename="$output"
    while [ -f "$rename" ] ; do
        rename="$filename-${i}.${ext}"
        i=$((i+1))
    done
    output="$rename"

    cat "$timezone" > "$output"
    local filelist=()
       
    for e in "${selectedCalendarList[@]}"
    do
        
        if [ -f "${sp}/$e" ]; then
            filelist=("${filelist[@]}" "${sp}/$e")
        elif [ -d "${sp}/$e" ]; then
            filelist=("${filelist[@]}" $(ls -d "${sp}/${e%/}/"*))
        fi
    done
    if [ "$verbose" ]; then
        echo "${filelist[*]}"
    fi
    for file in "${filelist[@]}"
    do
        cat "$file" >> "$output"
    done
    echo "END:VCALENDAR" >> "$output"
                
}

_getFilesInFolder() {
#todo
    echo "todo"
}    

    

