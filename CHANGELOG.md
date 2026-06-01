## [2825948] - 2026-06-01
### Merge pull request #14 from tadanobutubutu/dev

fix: resolve FutureBuilder and Column children syntax errors
Fixed syntax errors in FutureBuilder and Column widget declarations in the workflow detail screen by correcting indentation, adding missing builder callback, and properly wrapping children array. These are purely formatting and structural corrections that resolve compilation errors without changing runtime behavior or API surface.

## [fc0cc16] - 2026-05-30
### fix: improve accessibility by adding semantics
Added Semantics widgets throughout the presentation layer to improve accessibility for screen readers. Changed error and loading states to wrap child widgets with Semantics labels, and fixed a Padding widget syntax error in settings_screen.dart. These are internal UI improvements with no user-facing feature changes or API modifications.
