#!/usr/bin/env bash
# TDD Watcher: automatically runs tests when .go files change
set -e

echo "Starting TDD watcher... monitoring *.go files"
echo "Press Ctrl+C to stop."

LAST_RUN=0

run_tests() {
    clear || true
    echo "=========================================================="
    echo "Running tests at $(date '+%Y-%m-%d %H:%M:%S')..."
    echo "=========================================================="
    if go test -v -race -shuffle=on ./...; then
        echo ""
        echo ">>> ALL TESTS PASSED [GREEN] <<<"
    else
        echo ""
        echo ">>> TESTS FAILED [RED] - Refactor or Fix! <<<"
    fi
    echo "=========================================================="
    echo "Watching for file changes..."
}

# Initial run
run_tests

# Check for inotifywait or fallback to polling
if command -v inotifywait >/dev/null 2>&1; then
    while true; do
        inotifywait -r -q -e modify,create,delete --include '.*\.go$' .
        run_tests
    done
else
    # Universal fallback polling loop
    LAST_HASH=""
    while true; do
        CURRENT_HASH=$(find . -name "*.go" -not -path "*/vendor/*" -exec ls -l --time-style=+%s {} + 2>/dev/null | sha1sum)
        if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
            if [ -n "$LAST_HASH" ]; then
                run_tests
            fi
            LAST_HASH="$CURRENT_HASH"
        fi
        sleep 1
    done
fi
