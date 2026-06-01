## [0.1.0] - 2026-06-01

### Added

- Merge dev into master with a11y fixes and Tagline configuration ([#9](https://github.com/tadanobutubutu/flowscout/pull/9))
- Merge dev into master with completed fixes, ECC bundle, and auto-docs ([#17](https://github.com/tadanobutubutu/flowscout/pull/17))

### Fixed

- resolve FutureBuilder and Column children syntax errors ([#14](https://github.com/tadanobutubutu/flowscout/pull/14))
- remove invalid const from Semantics in workflow detail screen ([#19](https://github.com/tadanobutubutu/flowscout/pull/19))
- add const to chevron Icon to satisfy prefer_const_constructors ([#21](https://github.com/tadanobutubutu/flowscout/pull/21))
- resolve const constructor issues in home_screen ([#22](https://github.com/tadanobutubutu/flowscout/pull/22))

### Changed

- [translatabot] Add configuration file ([#1](https://github.com/tadanobutubutu/flowscout/pull/1))
- auto-update documentation (fc0cc16) ([#7](https://github.com/tadanobutubutu/flowscout/pull/7))
- eliminate small width SizedBoxes to resolve a11y touch target size warnings ([#20](https://github.com/tadanobutubutu/flowscout/pull/20))

## [2825948] - 2026-06-01
### Merge pull request #14 from tadanobutubutu/dev

fix: resolve FutureBuilder and Column children syntax errors
Fixed syntax errors in FutureBuilder and Column widget declarations in the workflow detail screen by correcting indentation, adding missing builder callback, and properly wrapping children array. These are purely formatting and structural corrections that resolve compilation errors without changing runtime behavior or API surface.

## [fc0cc16] - 2026-05-30
### fix: improve accessibility by adding semantics
Added Semantics widgets throughout the presentation layer to improve accessibility for screen readers. Changed error and loading states to wrap child widgets with Semantics labels, and fixed a Padding widget syntax error in settings_screen.dart. These are internal UI improvements with no user-facing feature changes or API modifications.
