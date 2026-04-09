SHELL := /bin/bash

REQUIRED_CMDS = openssl tor curl awk cat tr wc cut uniq sed

.PHONY: help lint syntax deps-check validate ci

help:
	@printf "Available targets:\n  validate   - run lint, syntax and deps-check\n  lint       - run shellcheck (requires shellcheck)\n  syntax     - bash -n insta.sh\n  deps-check - verify runtime dependencies\n  run-safe   - simulate script execution (no network)\n  ci         - same as validate (for CI)\n"

lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "❌ shellcheck not found — install with: brew install shellcheck (macOS) or apt-get install shellcheck (Linux)"; exit 1; }
	@shellcheck insta.sh

syntax:
	@bash -n insta.sh && echo "✔ bash syntax: OK"

deps-check:
	@missing=0; \
	for cmd in $(REQUIRED_CMDS); do \
	  if command -v $$cmd >/dev/null 2>&1; then echo "✔ $$cmd"; else echo "❌ $$cmd (missing)"; missing=1; fi; \
	done; \
	if [ -f default-passwords.lst ]; then echo "✔ default-passwords.lst present"; else echo "⚠ default-passwords.lst missing"; fi; \
	if [ $$missing -eq 1 ]; then exit 1; fi

validate: lint syntax deps-check
	@echo "✔ validate: all checks passed"

run-safe:
	@echo "⚠ run-safe: simulated execution — NO network calls will be made"
	@./simulate.sh

ci: validate
	@echo "(CI) all checks passed"