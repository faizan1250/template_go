#!/usr/bin/env bash
set -euo pipefail

COVERAGE_FILE="${1:-coverage.out}"
THRESHOLD="${2:-80}"

if [ ! -f "$COVERAGE_FILE" ]; then
    echo "Error: Coverage file '$COVERAGE_FILE' not found."
    exit 1
fi

if [ ! -s "$COVERAGE_FILE" ]; then
    echo "Notice: Coverage file is empty (no Go packages or tests found yet)."
    exit 0
fi

# Extract total coverage percentage, e.g. "85.4%" -> "85.4"
TOTAL_COVERAGE=$(go tool cover -func="$COVERAGE_FILE" 2>/dev/null | grep "^total:" | awk '{print $NF}' | tr -d '%' || true)

if [ -z "$TOTAL_COVERAGE" ]; then
    echo "Error: Could not calculate total coverage."
    exit 1
fi

echo "Total test coverage: ${TOTAL_COVERAGE}% (Threshold: ${THRESHOLD}%)"

# Compare using awk floating-point comparison
PASSED=$(awk -v cov="$TOTAL_COVERAGE" -v thr="$THRESHOLD" 'BEGIN { if (cov >= thr) print "1"; else print "0"; }')

if [ "$PASSED" -eq "1" ]; then
    echo "SUCCESS: Coverage threshold (${THRESHOLD}%) met!"
    exit 0
else
    echo "FAILURE: Coverage ${TOTAL_COVERAGE}% is below required threshold ${THRESHOLD}%!"
    echo "Please write tests for newly added or modified code before pushing."
    exit 1
fi
