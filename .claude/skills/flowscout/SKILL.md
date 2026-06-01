```markdown
# flowscout Development Patterns

> Auto-generated skill from repository analysis

## Overview

This skill teaches the core development patterns, coding conventions, and common workflows used in the `flowscout` repository. The project is primarily written in Swift, with a focus on maintainable code, clear commit practices, and robust localization and documentation support. While no major framework is detected, the repository emphasizes accessibility, internationalization, and continuous integration.

---

## Coding Conventions

### File Naming

- Use **camelCase** for file names.
  - Example: `homeScreen.swift`, `workflowDetailScreen.swift`

### Imports

- Use **relative import paths**.
  - Example:
    ```swift
    import "../utils/helper"
    ```

### Exports

- Use **default exports**.
  - Example:
    ```swift
    public class HomeScreen { ... }
    ```

### Commit Messages

- Follow **conventional commit** patterns.
- Prefixes include: `chore`, `feat`, `fix`, `security`.
- Example:
  ```
  feat: add dark mode toggle to settings screen
  fix: resolve crash when loading workflows with missing data
  ```

---

## Workflows

### Update GitHub Actions Workflow

**Trigger:** When you need to change CI/CD pipeline logic, triggers, or formatting enforcement.  
**Command:** `/update-ci-workflow`

1. Edit one or more files in `.github/workflows/` (e.g., `build.yml`, `deploy-pages.yml`, `release-agent.yml`).
2. Optionally update related config files or scripts if needed.
3. Commit with a message referencing `workflow`, `build`, `deploy`, or `release`.

**Example:**
```yaml
# .github/workflows/build.yml
on:
  push:
    branches: [ main ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      # ... more steps
```

---

### Update .gitignore for Secrets or Platform

**Trigger:** When you need to add new ignore rules for secrets, build artifacts, or platform-specific files.  
**Command:** `/update-gitignore`

1. Edit `.gitignore` to add or adjust patterns.
2. Optionally add or remove files that are now ignored or tracked.
3. Commit with a message referencing `security`, `fix`, or `platform`.

**Example:**
```
# .gitignore
*.xcuserstate
*.env
.DS_Store
```

---

### Add or Update Localization Files

**Trigger:** When you want to add support for a new language or update translations.  
**Command:** `/add-language`

1. Create or edit files in `lib/src/localization/` (e.g., `app_en.arb`, `app_ja.arb`, etc.).
2. Optionally update translation configuration (`crowdin.yml`, `.github/translatabot.yml`).
3. Commit with a message referencing `language`, `localization`, or `translation`.

**Example:**
```json
// lib/src/localization/app_es.arb
{
  "welcome": "Bienvenido",
  "logout": "Cerrar sesión"
}
```

---

### Update Documentation and README

**Trigger:** When you want to document new features, update compliance checklists, or restructure README files.  
**Command:** `/update-docs`

1. Edit documentation files (`docs/*.md`, `README.md`, `CONTRIBUTING.md`, etc.).
2. Optionally update `LICENSE` or other meta files.
3. Commit with a message referencing `docs`, `README`, or `checklist`.

**Example:**
```markdown
# Accessibility & UX Checklist

- [x] All interactive elements are keyboard accessible
- [ ] Color contrast meets WCAG 2.1 AA
```

---

### Fix Accessibility in Presentation Layer

**Trigger:** When you need to improve or fix accessibility in the app UI.  
**Command:** `/fix-a11y`

1. Edit files in `lib/src/presentation/` (e.g., `home_screen.dart`, `settings_screen.dart`).
2. Commit with a message referencing `a11y`, `accessibility`, or `fix`.

**Example:**
```swift
// homeScreen.swift
button.accessibilityLabel = "Start workflow"
```

---

## Testing Patterns

- **Test files** follow the `*.test.*` naming pattern.
- The testing framework is currently **unknown**.
- Place tests alongside the code or in a dedicated test directory.
- Example:
  ```
  workflowManager.test.swift
  ```

---

## Commands

| Command             | Purpose                                                        |
|---------------------|----------------------------------------------------------------|
| /update-ci-workflow | Update or fix CI/CD GitHub Actions workflow files              |
| /update-gitignore   | Adjust .gitignore for secrets or platform-specific files       |
| /add-language       | Add or update localization (ARB) files for new languages       |
| /update-docs        | Update documentation, README, or checklists                    |
| /fix-a11y           | Implement or fix accessibility features in the presentation UI |

```