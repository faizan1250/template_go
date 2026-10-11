## 📋 Pull Request Summary

### Description
<!-- Provide a clear and concise description of what this PR introduces or fixes. -->

### Related Issue
Fixes #<!-- issue number -->

---

### Type of Change
- [ ] 🚀 New feature (non-breaking change which adds functionality)
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ⚡ Performance improvement
- [ ] ♻️ Code refactoring (no functional change)
- [ ] 📝 Documentation update
- [ ] 🔧 Build/CI configuration

---

### 🧪 Test-Driven Development (TDD) Checklist
- [ ] **Tests First / Comprehensive Tests**: Unit tests written/updated covering happy path and failure/edge cases.
- [ ] **Test Execution**: Ran `make test` locally; all tests pass without errors.
- [ ] **Data Race Detector**: Ran `go test -race ./...`; zero race conditions detected.
- [ ] **Coverage Threshold**: Ran `make coverage-check`; coverage meets or exceeds the required 80% threshold.

---

### 🛡️ Code Quality & Pre-Push Verification
- [ ] Ran `make fmt` (code formatted according to `gofmt`).
- [ ] Ran `make lint` (`golangci-lint` reports 0 issues).
- [ ] Ran `make vuln` (`govulncheck` detected 0 known vulnerabilities).
- [ ] Ran `make check` locally before pushing.

---

### 🤖 AI / CodeRabbit Review Readiness
- [ ] Follows Effective Go standards and interface segregation.
- [ ] Errors are wrapped with `fmt.Errorf("%w", err)` or checked with `errors.Is`/`errors.As`.
- [ ] No unhandled goroutine leaks, unbuffered channel hangs, or missing context cancellations.
- [ ] PR title adheres to [Conventional Commits](https://www.conventionalcommits.org/) (e.g. `feat: ...`, `fix: ...`).
