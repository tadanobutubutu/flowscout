## [c19cdd4] - 2026-06-01
### Merge pull request #19 from tadanobutubutu/dev

fix: remove invalid const from Semantics in workflow detail screen
Removed invalid `const` keyword from a Semantics widget in the workflow detail screen. The Semantics constructor cannot be const because it wraps a non-const child widget (Padding), so the const modifier was moved to the inner Padding widget instead. This is a bug fix that corrects a Dart compile-time error with no functional behavior change.

## [aad56bc] - 2026-06-01
### docs(tzylo): update from PR #17
Updated TZYLO.md with documentation of recent tooling integrations (FlowScout skill definition, ECC configuration, RepoWrit settings) and CI/CD improvements. This is a documentation-only change with no production code modifications.

## [0abf0bf] - 2026-06-01
### Merge pull request #17 from tadanobutubutu/dev

Merge dev into master with completed fixes, ECC bundle, and auto-docs
Merge commit integrating automated developer experience tooling: ECC (Extensible Configuration Curation) bundle, Claude Code skills, Codex agent configurations, and workflow command scaffolds. All changes are metadata and AI agent configuration files (YAML, JSON, markdown) in hidden directories (.claude, .agents, .codex) with zero modifications to production code (Dart, Kotlin, Swift files remain unchanged).

## [2825948] - 2026-06-01
### Merge pull request #14 from tadanobutubutu/dev

fix: resolve FutureBuilder and Column children syntax errors
Fixed syntax errors in FutureBuilder and Column widget declarations in the workflow detail screen by correcting indentation, adding missing builder callback, and properly wrapping children array. These are purely formatting and structural corrections that resolve compilation errors without changing runtime behavior or API surface.

## [fc0cc16] - 2026-05-30
### fix: improve accessibility by adding semantics
Added Semantics widgets throughout the presentation layer to improve accessibility for screen readers. Changed error and loading states to wrap child widgets with Semantics labels, and fixed a Padding widget syntax error in settings_screen.dart. These are internal UI improvements with no user-facing feature changes or API modifications.
