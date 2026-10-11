# Go Project Template & Professional CI/CD Workflow

A production-ready Golang project template equipped with an automated CI/CD pipeline, Test-Driven Development (TDD) local gates, Git pre-push hooks, and CodeRabbit AI Pull Request reviews.

---

## 🛠️ Workflow Architecture

```
                    LOCAL WORKFLOW                                 GITHUB WORKFLOW
 ┌──────────────────────────────────────────────────┐   ┌─────────────────────────────────────────┐
 │                                                  │   │                                         │
 │  1. Write Test (RED) -> Implement (GREEN)        │   │  5. Push Branch & Open PR               │
 │     $ make test-watch                            │   │     $ git push -u origin feat/...       │
 │                                                  │   │                                         │
 │  2. Pre-Commit Hook (.githooks/pre-commit)       │   │  6. GitHub Actions CI                   │
 │     - Checks code formatting                     │   │     - Golangci-lint                     │
 │     - Blocks leaking .env / secrets              │   │     - Govulncheck (CVE scan)            │
 │                                                  │   │     - Go Test -race & Coverage (>= 80%) │
 │  3. Quality Verification                         │   │     - Binary Build Check                │
 │     $ make check                                 │   │                                         │
 │                                                  │   │  7. CodeRabbit AI Review                │
 │  4. Pre-Push Hook (.githooks/pre-push)           │   │     - Automated senior AI code review   │
 │     - Auto-verifies tests, lint, coverage >= 80% │   │     - Enforces Go best practices & TDD  │
 │     - Rejects push if any check fails!           │   │                                         │
 │                                                  │   │  8. Merge to `main` (Branch Protected)  │
 └──────────────────────────────────────────────────┘   └─────────────────────────────────────────┘
```

---

## 🚀 Quick Start (Local Setup)

### 1. Activate Git Hooks
Enable the local pre-commit and pre-push quality gates:
```bash
make setup-hooks
```

### 2. Available Make Commands

| Command | Description |
| :--- | :--- |
| `make test` | Run tests with race detector and test shuffling (`-race -shuffle=on`) |
| `make test-watch` | **TDD Loop**: Continuously watches `.go` files and runs tests instantly on save |
| `make coverage` | Generates coverage profile and visual HTML report (`coverage.html`) |
| `make coverage-check` | Enforces minimum test coverage threshold (default: **80%**) |
| `make lint` | Runs `golangci-lint` with strict Go rules |
| `make vuln` | Scans dependencies for known vulnerabilities (`govulncheck`) |
| `make fmt` | Formats all Go source files |
| `make check` | **Complete Pre-Push Gate**: formats, lints, scans vulnerabilities, checks coverage, builds |
| `make build` | Builds production binary with stripped debug symbols (`-ldflags="-s -w"`) |

---

## 🔄 Test-Driven Development (TDD) Routine

1. **Start the TDD test watcher**:
   ```bash
   make test-watch
   ```
2. **Red Phase**: Write your unit test in `*_test.go` first. The watcher will detect the change and report test failure.
3. **Green Phase**: Write minimal implementation code to pass the test. The watcher will turn green.
4. **Refactor Phase**: Clean up code and abstractions while tests remain green.
5. **Coverage & Quality Gate**:
   ```bash
   make check
   ```

---

## 🛡️ Git Hooks Enforcement

- **`pre-commit`**:
  - Automatically verifies code formatting (`gofmt`).
  - Blocks accidental commits containing `.env`, `.pem`, `.key`, or sensitive files.
- **`pre-push`**:
  - Automatically executes `make check` before allowing `git push`.
  - **Fails and rejects the push** if any test fails, if any data race exists, or if test coverage is below 80%.

---

## 🤖 CodeRabbit AI Integration

The repository includes a ready-to-use `.coderabbit.yaml` configured for:
- Senior Staff Go Engineer persona.
- Automatic review of all Pull Requests opened against `main`.
- Deep checks for:
  - Error wrapping (`fmt.Errorf("%w", err)`).
  - Concurrency safety (goroutine leaks, race conditions, mutex locking).
  - Interface design & clean architecture.
  - TDD compliance (verifies tests accompany modified business logic).

### How to Enable CodeRabbit:
1. Visit [CodeRabbit.ai](https://coderabbit.ai/) or the [GitHub Marketplace CodeRabbit App](https://github.com/marketplace/coderabbitai).
2. Click **Install** and select this repository (`template_go` or any future project).
3. CodeRabbit automatically detects `.coderabbit.yaml` and starts reviewing every PR you open!

---

## 🔒 GitHub Branch Protection (Main Branch)

To enforce that you and contributors **must** raise PRs and cannot push directly to `main`:

1. On GitHub, navigate to **Settings** > **Branches**.
2. Click **Add branch protection rule** (or **Add branch ruleset**).
3. Set **Branch name pattern**: `main`.
4. Enable the following settings:
   - ✅ **Require a pull request before merging**
     - Require approvals: `1` (or your preferred count)
     - Dismiss stale pull request approvals when new commits are pushed
   - ✅ **Require status checks to pass before merging**
     - Require branches to be up to date before merging
     - Search and check required jobs:
       - `Lint & Formatting`
       - `Security & Vulnerabilities`
       - `Tests & Coverage`
       - `Build Verification`
   - ✅ **Do not allow bypassing the above settings** (enforces rule for admins too).
5. Click **Save Changes**.

---

## 📦 Continuous Delivery (CD) Releases

When ready to publish a release:
```bash
git tag v1.0.0
git push origin v1.0.0
```
GitHub Actions (`.github/workflows/cd.yml`) will automatically compile cross-platform production binaries (`linux/amd64`, `linux/arm64`, `darwin/amd64`, `darwin/arm64`, `windows/amd64`), compute SHA256 checksums, and publish a GitHub Release with release notes!
