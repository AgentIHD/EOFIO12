#!/bin/bash
# File: EOFIO12/scripts/reshare_random.sh

# Load config + secrets (for tokens and vars)
. "$(dirname "$0")/../config.conf"
. "$(dirname "$0")/../secret.sh"

# Log file (frames already posted)
LOG_FILE="$(dirname "$0")/../fb/log.txt"

# Pick one random line from log.txt
random_line=$(shuf -n 1 "$LOG_FILE")

# Extract info
frame_info=$(echo "$random_line" | awk -F 'https' '{print $1}')
frame_url=$(echo "$random_line" | awk '{print $NF}')

# Craft message
message="Random frame. ${frame_info}"

# Share the old post link to Page feed
response=$(
  curl -s -w "\n%{http_code}" -X POST \
    -F "message=${message}" \
    -F "link=${frame_url}" \
    "${FRMENV_API_ORIGIN}/me/feed?access_token=${FRMENV_FBTOKEN}"
)

# Split response and HTTP status
body=$(echo "$response" | head -n 1)
status=$(echo "$response" | tail -n 1)

if [[ "$status" != "200" ]]; then
  echo "❌ Failed to share $frame_url"
  echo "Facebook response: $body"
  exit 1
fi

echo "✅ Shared: $frame_info $frame_url"
