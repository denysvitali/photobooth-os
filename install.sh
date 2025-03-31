#!/bin/bash
set -e
function log {
	printf '\033[1;36m%s\033[0m\n' "$@" >&2  # bold cyan
}

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <target-ip>"
  exit 1
fi

TARGET=$1

function send_file {
  log "Sending $1 to $TARGET"
  scp "$1" "root@$TARGET:/tmp/$1"
}

send_file "sdcard_update.img.gz"
send_file "sdcard_update.img.gz.sha256"

log "Installing update"
ssh "root@$TARGET" "ab_flash /tmp/sdcard_update.img.gz"
