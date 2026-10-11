#!/usr/bin/env bash
# TDD Watcher: automatically runs tests when .go files change
set -e

TARGET_DIR="${1:-apps/backend}"
if [ ! -d "$TARGET_DIR" ]; then
    TARGET_DIR="."
fi

echo "Starting TDD watcher... monitoring *.go files in '$TARGET_DIR'"
echo "Press Ctrl+C to stop."

run_tests() {
    clear || true
    echo "=========================================================="
    echo "Running tests in $TARGET_DIR at $(date '+%Y-%m-%d %H:%M:%S')..."
    echo "=========================================================="
    if (cd "$TARGET_DIR" && go test -v -race -shuffle=on ./...); then
        echo ""
        echo ">>> ALL TESTS PASSED [GREEN] <<<"
    else
        echo ""
        echo ">>> TESTS FAILED [RED] - Refactor or Fix! <<<"
    fi
    echo "=========================================================="
    echo "Watching for file changes in $TARGET_DIR..."
}

# Initial run
run_tests

# Polling watch loop
LAST_HASH=""
while true; do
    CURRENT_HASH=$(find "$TARGET_DIR" -name "*.go" -not -path "*/vendor/*" -exec ls -l --time-style=+%s {} + 2>/dev/null | sha1sum)
    if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
        if [ -n "$LAST_HASH" ]; then
            run_tests
        fi
        LAST_HASH="$CURRENT_HASH"
    fi
    sleep 1
done
