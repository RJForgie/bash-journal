#!/bin/bash

# Define the journal file location
JOURNAL_FILE="$HOME/journal.txt"

# Function to get current date in specified format
get_formatted_date() {
    year=$(date +%Y)
    month=$(date +%B)
    day=$(date +"%a %d")
    echo ""
    echo "year:  $year"
    echo "month: $month"
    echo "day:   $day"
    echo "---"
}

# Function to create or append journal entry
add_journal_entry() {
    local entry="$1"
    local today=$(date +%Y-%m-%d)

    # Check if journal file exists
    if [ ! -f "$JOURNAL_FILE" ]; then
        touch "$JOURNAL_FILE"
    fi

    # Check the last date entry in the file
    last_date=$(grep -n "year:" "$JOURNAL_FILE" | tail -n 1)
    
    # If no previous entries or last entry is not today, add date header
    if [ -z "$last_date" ] || ! grep -q "$(date +"%Y"): *$(date +%Y)" "$JOURNAL_FILE"; then
        get_formatted_date >> "$JOURNAL_FILE"
    else
        # If entries exist for today, add a blank line before new entry
        echo "" >> "$JOURNAL_FILE"
    fi

    # Append the entry
    echo "$entry" >> "$JOURNAL_FILE"
    echo "Entry added to journal"
}

view_today() {
    # Using macOS date syntax
    local today_pattern=$(date +"year:  %Y\nmonth: %B\nday:   %a %d")
    local next_day_pattern=$(date -v+1d +"year:  %Y\nmonth: %B\nday:   %a %d")

    if [ -f "$JOURNAL_FILE" ]; then
        # Using gsed if available (brew install gnu-sed), otherwise fallback to awk
        if command -v gsed &> /dev/null; then
            gsed -n "/$today_pattern/,/---/p" "$JOURNAL_FILE"
        else
            awk -v today="$today_pattern" -v next_day="$next_day_pattern" '
                BEGIN { found = 0; print_block = 0 }
                $0 ~ today { found = 1; print_block = 1; print $0; next }
                print_block == 1 && $0 ~ /^---$/ { print $0; print_block = 0; next }
                print_block == 1 { print $0 }
                $0 ~ next_day { exit }
            ' "$JOURNAL_FILE"
        fi
    else
        echo "Journal file not found"
    fi
}

view_last_entry() {
    if [ -f "$JOURNAL_FILE" ]; then
        # Using gtac if available (brew install coreutils), otherwise use tail -r
        if command -v gtac &> /dev/null; then
            gtac "$JOURNAL_FILE" | awk '
                BEGIN { block_started = 0; printed_lines = 0 }
                /^year:/ { 
                    if (block_started) exit;
                    block_started = 1;
                    print $0;
                    next;
                }
                block_started && printed_lines < 10 && $0 != "" {
                    print $0;
                    printed_lines++;
                }
                /^---$/ { block_started = 0 }
            '
        else
            tail -r "$JOURNAL_FILE" | awk '
                BEGIN { block_started = 0; printed_lines = 0 }
                /^year:/ { 
                    if (block_started) exit;
                    block_started = 1;
                    print $0;
                    next;
                }
                block_started && printed_lines < 10 && $0 != "" {
                    print $0;
                    printed_lines++;
                }
                /^---$/ { block_started = 0 }
            '
        fi
    else
        echo "Journal file not found"
    fi
}

case "$1" in
    "")
        echo "Usage: jn <entry>   - Add a new journal entry"
        echo "       jn today     - View today's entries"
        echo "       jn last      - View the last entry"
        exit 1
        ;;
    "today")
        view_today
        ;;
    "last")
        view_last_entry
        ;;
    *)
        add_journal_entry "$*"
        ;;
esac
