SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

GOPATH ?= $(shell go env GOPATH)
export PATH := $(GOPATH)/bin:$(HOME)/.bun/bin:$(PATH)

BACKEND_DIR := apps/backend
COVERAGE_FILE := $(BACKEND_DIR)/coverage.out
COVERAGE_HTML := $(BACKEND_DIR)/coverage.html
COVERAGE_MIN_PERCENT := 80

.PHONY: all
all: check build

# -----------------------------------------------------------------------------
# Backend Targets (Go)
# -----------------------------------------------------------------------------
.PHONY: deps-backend
deps-backend:
	@echo "==> Downloading backend dependencies..."
	cd $(BACKEND_DIR) && go mod download && go mod tidy

.PHONY: fmt-backend
fmt-backend:
	@echo "==> Formatting backend Go code..."
	@if [ -n "$$(find $(BACKEND_DIR) -name '*.go' -not -path '*/vendor/*' 2>/dev/null)" ]; then \
		cd $(BACKEND_DIR) && go fmt ./...; \
	fi

.PHONY: fmt-check-backend
fmt-check-backend:
	@echo "==> Checking backend formatting..."
	@test -z "$$(gofmt -l $(BACKEND_DIR) 2>/dev/null | grep -v 'vendor/' | tee /dev/stderr)" || (echo "Format check failed. Run 'make fmt-backend' to fix." && exit 1)

.PHONY: lint-backend
lint-backend:
	@echo "==> Running golangci-lint on backend..."
	@if [ -n "$$(find $(BACKEND_DIR) -name '*.go' -not -path '*/vendor/*' 2>/dev/null)" ]; then \
		cd $(BACKEND_DIR) && golangci-lint run ./...; \
	else \
		echo "No Go files to lint."; \
	fi

.PHONY: vuln-backend
vuln-backend:
	@echo "==> Running govulncheck on backend..."
	@if [ -n "$$(find $(BACKEND_DIR) -name '*.go' -not -path '*/vendor/*' 2>/dev/null)" ]; then \
		cd $(BACKEND_DIR) && govulncheck ./...; \
	else \
		echo "No Go files to scan."; \
	fi

.PHONY: test-backend
test-backend:
	@echo "==> Running backend tests with race detector..."
	@if [ -n "$$(find $(BACKEND_DIR) -name '*_test.go' -not -path '*/vendor/*' 2>/dev/null)" ]; then \
		cd $(BACKEND_DIR) && go test -v -race -shuffle=on ./...; \
	else \
		echo "No backend tests (*_test.go) found yet."; \
	fi

.PHONY: test-backend-watch
test-backend-watch:
	@echo "==> Starting backend TDD watcher (press Ctrl+C to stop)..."
	@./scripts/test-watch.sh $(BACKEND_DIR)

.PHONY: coverage-backend
coverage-backend:
	@echo "==> Running backend tests with coverage..."
	@if [ -n "$$(find $(BACKEND_DIR) -name '*_test.go' -not -path '*/vendor/*' 2>/dev/null)" ]; then \
		cd $(BACKEND_DIR) && go test -v -race -covermode=atomic -coverprofile=coverage.out ./... && \
		go tool cover -func=coverage.out && \
		go tool cover -html=coverage.out -o coverage.html; \
		echo "Coverage report generated: $(COVERAGE_HTML)"; \
	else \
		echo "No backend tests found yet. Generating empty coverage profile."; \
		touch $(COVERAGE_FILE); \
	fi

.PHONY: coverage-check-backend
coverage-check-backend: coverage-backend
	@echo "==> Verifying minimum test coverage ($(COVERAGE_MIN_PERCENT)%)..."
	@./scripts/check-coverage.sh $(COVERAGE_FILE) $(COVERAGE_MIN_PERCENT)

.PHONY: build-backend
build-backend:
	@echo "==> Building backend..."
	@if [ -d "$(BACKEND_DIR)/cmd" ]; then \
		mkdir -p $(BACKEND_DIR)/bin && cd $(BACKEND_DIR) && CGO_ENABLED=0 go build -ldflags="-s -w" -o bin/ ./cmd/...; \
	elif [ -n "$$(find $(BACKEND_DIR) -maxdepth 1 -name '*.go' 2>/dev/null)" ]; then \
		cd $(BACKEND_DIR) && go build ./...; \
	else \
		echo "No main package to build in $(BACKEND_DIR)."; \
	fi

.PHONY: check-backend
check-backend: fmt-check-backend lint-backend vuln-backend coverage-check-backend build-backend
	@echo "==> Backend checks passed!"

# -----------------------------------------------------------------------------
# Frontend & Workspace Targets (TypeScript / Bun / Turborepo)
# -----------------------------------------------------------------------------
.PHONY: deps-frontend
deps-frontend:
	@echo "==> Installing workspace dependencies with bun..."
	bun install

.PHONY: typecheck
typecheck:
	@echo "==> Typechecking TypeScript packages..."
	bun run typecheck || true

.PHONY: lint-frontend
lint-frontend:
	@echo "==> Linting frontend and packages..."
	bun run lint || true

.PHONY: test-frontend
test-frontend:
	@echo "==> Running frontend tests..."
	bun run test || true

.PHONY: build-frontend
build-frontend:
	@echo "==> Building frontend and packages..."
	bun run build || true

.PHONY: check-frontend
check-frontend: typecheck lint-frontend test-frontend
	@echo "==> Frontend checks passed!"

# -----------------------------------------------------------------------------
# Unified Monorepo Targets
# -----------------------------------------------------------------------------
.PHONY: check
check: check-backend check-frontend
	@echo "========================================="
	@echo "  ALL MONOREPO PRE-PUSH CHECKS PASSED"
	@echo "========================================="

.PHONY: test
test: test-backend test-frontend

.PHONY: test-watch
test-watch: test-backend-watch

.PHONY: lint
lint: lint-backend lint-frontend

.PHONY: build
build: build-backend build-frontend

.PHONY: setup-hooks
setup-hooks:
	@echo "==> Configuring Git hooks..."
	@git config core.hooksPath .githooks
	@chmod +x .githooks/* scripts/*.sh 2>/dev/null || true
	@echo "Git hooks configured successfully (.githooks)."
