#!/bin/bash

# watch.sh
# Lightweight live-reload helper for the MiniMania client.
# Watches Swift sources and rebuilds + relaunches the app whenever code changes.

set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="MiniMania"
WATCH_TARGETS=(
    main.swift
    AppDelegate.swift
    Controllers
    Views
    Models
    Services
    Extensions
    Info.plist
    build.sh
)

if ! command -v fswatch >/dev/null 2>&1; then
    echo "Error: fswatch is required for live reload. Install via:"
    echo "  brew install fswatch"
    exit 1
fi

EXISTING_TARGETS=()
for target in "${WATCH_TARGETS[@]}"; do
    if [ -e "$target" ]; then
        EXISTING_TARGETS+=("$target")
    fi
done

if [ ${#EXISTING_TARGETS[@]} -eq 0 ]; then
    echo "No watchable targets were found."
    exit 1
fi

function stop_app() {
    if pgrep -x "$APP_NAME" >/dev/null 2>&1; then
        echo "Stopping running $APP_NAME instance..."
        osascript -e "tell application \"$APP_NAME\" to quit" >/dev/null 2>&1 || true
        sleep 1
    fi
}

function build_and_run() {
    echo "[$(date '+%H:%M:%S')] Rebuilding..."
    if ./build.sh; then
        stop_app
        echo "Launching $APP_NAME..."
        open "build/$APP_NAME.app"
    else
        echo "Build failed. Waiting for next change..."
    fi
}

echo "Starting live watcher for: ${EXISTING_TARGETS[*]}"
echo "Press Ctrl+C to stop."

build_and_run

fswatch -or "${EXISTING_TARGETS[@]}" | while read -r _; do
    build_and_run
done


