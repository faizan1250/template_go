# Full-Stack Monorepo Template (Go + TypeScript + Turborepo)

A production-ready monorepo combining **Golang** (backend) and **TypeScript** (frontend/packages) orchestrated with **Turborepo** and **Bun**, featuring automated CI/CD path filtering, TDD local gates, Git pre-push hooks, and CodeRabbit AI reviews.

---

## 📁 Monorepo Structure

```
.
├── apps/
│   ├── backend/              # 🐹 Go Backend Service
│   │   ├── cmd/              # Application entry points
│   │   ├── internal/         # Private application code
│   │   ├── .golangci.yml     # Strict Go linter configuration
│   │   ├── Taskfile.yml      # Go task runner
│   │   └── go.mod            # Go module definition
│   │
│   └── frontend/             # 🟦 TypeScript Frontend (Next.js / Vite / React)
│
├── packages/                 # 📦 Shared TypeScript packages & configs
├── .github/
│   ├── workflows/
│   │   ├── backend-ci.yml    # CI triggered ONLY on backend changes
│   │   ├── frontend-ci.yml   # CI triggered ONLY on frontend changes
│   │   ├── pr-review.yml     # PR standards & TDD compliance review
│   │   └── cd.yml            # Automated cross-platform release pipeline
│   └── pull_request_template.md
│
├── .coderabbit.yaml          # AI Code Reviewer configured for Go & TypeScript
├── Makefile                  # Root monorepo orchestrator
├── package.json              # Bun / Turborepo workspaces configuration
└── turbo.json                # Turborepo pipeline configuration
```

---

## 🚀 Quick Start

### 1. Install & Setup Hooks
```bash
bun install
make setup-hooks
```

### 2. Everyday Commands

#### 🐹 Backend (Go)
| Command | Description |
| :--- | :--- |
| `make test-backend-watch` | **TDD Loop**: Watches `apps/backend` and re-runs tests instantly on save |
| `make test-backend` | Run backend tests with race detector (`-race -shuffle=on`) |
| `make coverage-backend` | Generates HTML coverage report (`apps/backend/coverage.html`) |
| `make coverage-check-backend` | Enforces minimum backend coverage threshold (**80%**) |
| `make lint-backend` | Runs `golangci-lint` inside `apps/backend` |
| `make vuln-backend` | Runs `govulncheck` to detect CVEs in Go dependencies |
| `make fmt-backend` | Formats all Go code |
| `make build-backend` | Compiles backend binaries |

#### 🟦 Frontend & Workspaces (TypeScript / Turborepo / Bun)
| Command | Description |
| :--- | :--- |
| `bun run dev` | Starts development servers via Turborepo |
| `bun run build` | Builds all apps and packages |
| `bun run typecheck` | Runs `tsc --noEmit` across all workspaces |
| `bun run lint` | Runs linter across all workspaces |
| `bun run test` | Runs tests across all workspaces |

#### 🛡️ Unified Quality Gates
| Command | Description |
| :--- | :--- |
| `make check` | Runs **all** backend & frontend verification checks before push |
| `make test` | Runs both backend and frontend tests |
| `make lint` | Runs both backend and frontend linters |
| `make build` | Builds both backend and frontend |

---

## ⚡ Smart CI/CD with Path Filtering

To save CI time and resources, GitHub Actions runs only what you changed:
* **`backend-ci.yml`**: Runs only when files in `apps/backend/**` change.
* **`frontend-ci.yml`**: Runs only when files in `apps/frontend/**`, `packages/**`, or `package.json` change.
* **`pr-review.yml`**: Verifies Conventional Commits in PR titles and ensures tests accompany code changes.

---

## 🤖 CodeRabbit AI Review

Configured in [`.coderabbit.yaml`](file:///home/faizan/template_go/.coderabbit.yaml):
- **Backend (Go)**: Reviews concurrency safety, error wrapping (`%w`), table-driven tests, and clean architecture.
- **Frontend (TypeScript)**: Reviews strict typing (no `any`), React hook rules, memoization, and test coverage.
