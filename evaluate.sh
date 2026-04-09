#!/usr/bin/env bash
set -euo pipefail

# Safe evaluation script — does NOT execute the brute-force logic.
# Runs linting, bash-syntax check and runtime-dependency verification.

echo "==> Running project validation (lint + syntax + deps)"
make validate

echo "==> Done"