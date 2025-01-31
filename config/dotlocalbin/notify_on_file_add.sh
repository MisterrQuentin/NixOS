#!/usr/bin/env bash
# Path to your help directories
BIMMER_HELP_DIR="$HOME/Nextcloud-public/bimmer_docs/computer_help"
JEDWICK_HELP_DIR="$HOME/Nextcloud-public/Jedwick/computer_help"

# Initialize last file and time variables
last_file=""
last_time=0

inotifywait -m -r -e create,modify "$BIMMER_HELP_DIR" "$JEDWICK_HELP_DIR" |
while read -r directory events filename; do
    current_time=$(date +%s)
    
    if [ -n "$filename" ]; then
        # For create events, ignore numeric files
        if [[ $events == *"CREATE"* ]] && ! [[ $filename =~ ^[0-9]+$ ]]; then
            case "$directory" in
                *"bimmer_docs"*)
                    notify-send "${filename} added to Bimmer's help"
                    ;;
                *"Jedwick"*)
                    notify-send "${filename} added to Jedwick's help"
                    ;;
            esac
        # For modify events, add debounce check
        elif [[ $events == *"MODIFY"* ]]; then
            # Only show notification if it's been more than 2 seconds since last notification for this file
            if [ "$filename" != "$last_file" ] || [ $((current_time - last_time)) -gt 1 ]; then
                case "$directory" in
                    *"bimmer_docs"*)
                        notify-send "${filename} modified in Bimmer's help"
                        ;;
                    *"Jedwick"*)
                        notify-send "${filename} modified in Jedwick's help"
                        ;;
                esac
                last_file="$filename"
                last_time=$current_time
            fi
        fi
    fi
done
