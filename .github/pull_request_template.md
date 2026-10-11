## 📋 Pull Request Summary

### Description
<!-- Provide a clear and concise description of what this PR introduces or fixes. -->

### Related Issue
Fixes #<!-- issue number -->

---

### Scope of Changes
- [ ] 🐹 Backend (`apps/backend`)
- [ ] 🟦 Frontend (`apps/frontend`)
- [ ] 📦 Shared Packages (`packages/*`)
- [ ] ⚙️ Tooling / CI / Config

---

### Type of Change
- [ ] 🚀 New feature
- [ ] 🐛 Bug fix
- [ ] ⚡ Performance improvement
- [ ] ♻️ Code refactoring
- [ ] 📝 Documentation update
- [ ] 🔧 Build/CI configuration

---

### 🧪 Test-Driven Development (TDD) Checklist
- [ ] **Tests Written**: Unit tests written covering happy paths and failure/edge cases.
- [ ] **Backend Tests**: `make test-backend` passed (race detector clean).
- [ ] **Backend Coverage**: `make coverage-check-backend` met the required 80% threshold.
- [ ] **Frontend Tests**: `bun run test` passed.

---

### 🛡️ Pre-Push Verification (`make check`)
- [ ] Ran `make fmt-backend` & `bun run format:check`.
- [ ] Ran `make lint-backend` (`golangci-lint` clean).
- [ ] Ran `make vuln-backend` (`govulncheck` detected 0 vulnerabilities).
- [ ] Ran `bun run typecheck` (zero TypeScript errors).
- [ ] Pre-push hook passed cleanly.

---

### 🤖 AI / CodeRabbit Review Readiness
- [ ] **Backend (Go)**: Clean error wrapping (`%w`), proper context propagation, concurrency safe.
- [ ] **Frontend (TS)**: Strict typing (no `any`), modular components, no missing hook dependencies.
- [ ] PR title adheres to [Conventional Commits](https://www.conventionalcommits.org/) (e.g. `feat: ...`, `fix: ...`).
