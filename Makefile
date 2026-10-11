SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Go environment and tools
GOPATH ?= $(shell go env GOPATH)
export PATH := $(GOPATH)/bin:$(PATH)

COVERAGE_FILE := coverage.out
COVERAGE_HTML := coverage.html
COVERAGE_MIN_PERCENT := 80

.PHONY: all
all: check build

# -----------------------------------------------------------------------------
# Dependency & Tool Setup
# -----------------------------------------------------------------------------
.PHONY: deps
deps:
	@echo "==> Downloading dependencies..."
	go mod download
	go mod tidy

.PHONY: tools
tools:
	@echo "==> Installing development tools..."
	@which golangci-lint >/dev/null 2>&1 || go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@which govulncheck >/dev/null 2>&1 || go install golang.org/x/vuln/cmd/govulncheck@latest
	@echo "Tools ready."

# -----------------------------------------------------------------------------
# Formatting & Linting
# -----------------------------------------------------------------------------
.PHONY: fmt
fmt:
	@echo "==> Formatting code..."
	@if [ -n "$$(find . -name '*.go' -not -path '*/vendor/*' 2>/dev/null)" ]; then \
		go fmt ./...; \
	fi

.PHONY: fmt-check
fmt-check:
	@echo "==> Checking code format..."
	@test -z "$$(gofmt -l . | grep -v 'vendor/' | tee /dev/stderr)" || (echo "Format check failed. Run 'make fmt' to fix." && exit 1)

.PHONY: lint
lint:
	@echo "==> Running golangci-lint..."
	@if [ -n "$$(find . -name '*.go' -not -path '*/vendor/*' 2>/dev/null)" ]; then \
		golangci-lint run ./...; \
	else \
		echo "No Go files to lint."; \
	fi

.PHONY: vuln
vuln:
	@echo "==> Running govulncheck..."
	@if [ -n "$$(find . -name '*.go' -not -path '*/vendor/*' 2>/dev/null)" ]; then \
		govulncheck ./...; \
	else \
		echo "No Go files to scan."; \
	fi

# -----------------------------------------------------------------------------
# Testing & TDD Loop
# -----------------------------------------------------------------------------
.PHONY: test
test:
	@echo "==> Running tests with race detector..."
	@if [ -n "$$(find . -name '*_test.go' -not -path '*/vendor/*' 2>/dev/null)" ]; then \
		go test -v -race -shuffle=on ./...; \
	else \
		echo "No tests found yet."; \
	fi

.PHONY: test-fast
test-fast:
	@echo "==> Running fast tests..."
	@if [ -n "$$(find . -name '*_test.go' -not -path '*/vendor/*' 2>/dev/null)" ]; then \
		go test ./...; \
	else \
		echo "No tests found yet."; \
	fi

.PHONY: test-watch
test-watch:
	@echo "==> Starting TDD test watcher (press Ctrl+C to stop)..."
	@./scripts/test-watch.sh

.PHONY: coverage
coverage:
	@echo "==> Running tests with coverage..."
	@if [ -n "$$(find . -name '*_test.go' -not -path '*/vendor/*' 2>/dev/null)" ]; then \
		go test -v -race -covermode=atomic -coverprofile=$(COVERAGE_FILE) ./...; \
		go tool cover -func=$(COVERAGE_FILE); \
		go tool cover -html=$(COVERAGE_FILE) -o $(COVERAGE_HTML); \
		echo "Coverage report generated: $(COVERAGE_HTML)"; \
	else \
		echo "No tests found yet. Generating empty coverage profile."; \
		touch $(COVERAGE_FILE); \
	fi

.PHONY: coverage-check
coverage-check: coverage
	@echo "==> Verifying minimum test coverage ($(COVERAGE_MIN_PERCENT)%)..."
	@./scripts/check-coverage.sh $(COVERAGE_FILE) $(COVERAGE_MIN_PERCENT)

# -----------------------------------------------------------------------------
# Build
# -----------------------------------------------------------------------------
.PHONY: build
build:
	@echo "==> Building application..."
	@if [ -d "./cmd" ]; then \
		mkdir -p bin && CGO_ENABLED=0 go build -ldflags="-s -w" -o bin/ ./cmd/...; \
	elif [ -n "$$(find . -maxdepth 1 -name '*.go' 2>/dev/null)" ]; then \
		go build ./...; \
	else \
		echo "No main/source package to compile yet."; \
	fi

.PHONY: clean
clean:
	@echo "==> Cleaning build artifacts..."
	rm -rf bin/ $(COVERAGE_FILE) $(COVERAGE_HTML)

# -----------------------------------------------------------------------------
# Pre-Push & Local CI Verification
# -----------------------------------------------------------------------------
.PHONY: check
check: fmt-check lint vuln coverage-check build
	@echo "========================================="
	@echo "  ALL PRE-PUSH CHECKS PASSED SUCCESSFULLY"
	@echo "========================================="

.PHONY: setup-hooks
setup-hooks:
	@echo "==> Configuring Git hooks..."
	@git config core.hooksPath .githooks
	@chmod +x .githooks/* scripts/*.sh 2>/dev/null || true
	@echo "Git hooks configured successfully (.githooks)."
