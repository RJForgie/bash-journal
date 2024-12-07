# Minimalist Command-Line Journal

## Overview
Command-line journaling tool that stores all your entries in a single text file with a date-based format. Inspired by [Journal.TXT](https://journaltxt.github.io/).

## Installation
```bash
# Download the script
sudo wget https://raw.githubusercontent.com/RJForgie/bash-journal/refs/heads/main/journal.sh -O /usr/local/bin/jn

# Make executable
sudo chmod +x /usr/local/bin/jn
```

## Usage

### Adding Entries
Add a journal entry with a simple command:
```bash
# Basic entry
jn This is a journal entry about my day

### Viewing Entries

#### Today's Entries
View all entries for the current day:
```bash
jn today
```

#### Last Entry
View the most recent journal entry:
```bash
jn last
```

## Entry Format
Entries are stored in `~/journal.txt` with the following format:
```
year:  2024
month: January
day:   Wed 17
---
Your journal entry text here
```

## Backup
Recommended to periodically backup your `~/journal.txt` file:
```bash
cp ~/journal.txt ~/journal-backup-$(date +%Y%m%d).txt
```

## Troubleshooting
- If entries aren't saving, check write permissions on `~/journal.txt`
- Ensure the script is in your PATH and executable
