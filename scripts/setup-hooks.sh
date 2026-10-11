#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Configuring Git hooks path to '$REPO_ROOT/.githooks'..."
git -C "$REPO_ROOT" config core.hooksPath .githooks

echo "==> Setting executable permissions on hooks and scripts..."
chmod +x "$REPO_ROOT"/.githooks/* "$REPO_ROOT"/scripts/*.sh 2>/dev/null || true

echo "==> Git hooks successfully installed and active!"
echo "    - Pre-commit: Verifies formatting and blocks committing secrets/.env"
echo "    - Pre-push: Runs full test suite, race detector, linter, and coverage check"
