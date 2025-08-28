#!/bin/bash
# File: EOFIO12/scripts/reshare_random.sh

# Load config + secrets (for tokens and vars)
. "$(dirname "$0")/../config.conf"
. "$(dirname "$0")/../secret.sh"

# log
LOG_FILE="$(dirname "$0")/../fb/log.txt"

# pick random line
random_line=$(shuf -n 1 "$LOG_FILE")
frame_info=$(echo "$random_line" | awk -F 'https' '{print $1}')
frame_url=$(echo "$random_line" | awk '{print $NF}')
message="Random frame. ${frame_info}"

# --- Auto-detect Page ID from token based on page_name ---
PAGE_ID=$(
  curl -s -G \
    -d "access_token=${FRMENV_FBTOKEN}" \
    "${FRMENV_API_ORIGIN}/${FRMENV_FBAPI_VER}/me/accounts" \
  | jq -r --arg NAME "$page_name" '.data[] | select(.name==$NAME) | .id'
)

if [[ -z "$PAGE_ID" ]]; then
  echo "❌ Could not find Page ID for page_name='${page_name}'."
  exit 1
fi

echo "Using Page ID: $PAGE_ID"

# Share the post link
curl -s -X POST \
    -F "message=${message}" \
    -F "link=${frame_url}" \
    "${FRMENV_API_ORIGIN}/${PAGE_ID}/feed?access_token=${FRMENV_FBTOKEN}" \
    || { echo "❌ Failed to share $frame_url"; exit 1; }

echo "✅ Shared: $frame_info $frame_url"
