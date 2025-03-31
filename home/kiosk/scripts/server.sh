#!/bin/bash
set -e
cd /home/kiosk/photobooth-server && exec ./bin/photobooth-server -l 0.0.0.0:8080
