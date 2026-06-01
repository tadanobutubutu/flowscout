---
name: update-gitignore-for-secrets-or-platform
description: Workflow command scaffold for update-gitignore-for-secrets-or-platform in flowscout.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /update-gitignore-for-secrets-or-platform

Use this workflow when working on **update-gitignore-for-secrets-or-platform** in `flowscout`.

## Goal

Strengthen or adjust .gitignore to prevent sensitive files or platform-specific files from being tracked.

## Common Files

- `.gitignore`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Edit .gitignore to add or adjust patterns
- Optionally add or remove files that are now ignored or tracked
- Commit with a message referencing security, fix, or platform

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.