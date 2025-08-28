#!/bin/bash
# File: EOFIO12/scripts/reshare_random.sh

# Load config + secrets (for tokens and vars)
. "$(dirname "$0")/../config.conf"
. "$(dirname "$0")/../secret.sh"

# log
LOG_FILE="$(dirname "$0")/../fb/log.txt"

# random
random_line=$(shuf -n 1 "$LOG_FILE")

frame_info=$(echo "$random_line" | awk -F 'https' '{print $1}')
frame_url=$(echo "$random_line" | awk '{print $NF}')

# msg
message="Random frame. ${frame_info}"

# Share the post link
curl -sfLX POST \
    -F "message=${message}" \
    -F "link=${frame_url}" \
    "${FRMENV_API_ORIGIN}/me/feed?access_token=${FRMENV_FBTOKEN}" \
    || { echo "Failed to share $frame_url"; exit 1; }

echo "Shared: $frame_info $frame_url"
