#!/bin/bash
set -e
KIOSK_URL="http://127.0.0.1:8000/index.html"

trap 'kill $(jobs -p)' EXIT

export XDG_RUNTIME_DIR=/home/kiosk/xdg-runtime
sway &
export DISPLAY=:0
chromium \
	--kiosk "$KIOSK_URL" \
	--enable-features=OverlayScrollbar,OverlayScrollbarFlashAfterAnyScrollUpdate,OverlayScrollbarFlashWhenMouseEnter \
	--disable-features="OverscrollHistoryNavigation" \
	--disk-cache-dir=/dev/null \
	--disable-pinch \
	--enable-logging=stderr \
	--v=stderr
