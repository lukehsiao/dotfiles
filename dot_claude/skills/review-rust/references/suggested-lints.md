# Suggested Lints for Rust Review

## Contents

- Principles
- Starter policy
- Review guidance
- Sources

## Principles

- Prefer cherry-picked lints over enabling entire `clippy::pedantic` or
  `clippy::restriction` groups. Clippy explicitly recommends selecting
  only the lints that fit the codebase.
- Use `deny` for lints that catch hidden panics, invalid API contracts,
  or non-local maintenance hazards.
- Use `warn` for lints that improve API clarity or idiomatic style but
  may need exceptions.
- Allow narrowly and locally when a crate has a real reason to violate a
  lint. Review the justification, not just the suppression.
- Calibrate by target. Libraries and shared infrastructure usually merit
  a stricter lint bar than prototypes, tests, or one-off binaries.

## Starter policy

Use this as a review baseline, not as a universal preset.

### High-signal defensive lints

- `clippy::indexing_slicing = "deny"`
  Catch implicit panics from direct indexing and slicing.
- `clippy::fallible_impl_from = "deny"`
  Reject `From` impls that can panic and should be `TryFrom`.
- `clippy::wildcard_enum_match_arm = "deny"`
  Prevent `_` arms from hiding future enum variants.
- `clippy::unneeded_field_pattern = "deny"`
  Reject struct patterns that ignore many fields with `..` when the
  match should stay sensitive to structural changes.

### Review-focused warn-level lints

- `clippy::unwrap_used = "warn"`
  Surface panic-heavy code paths for deliberate review.
- `clippy::expect_used = "warn"`
  Force a decision on whether panic is truly the right boundary.
- `clippy::fn_params_excessive_bools = "warn"`
  Push APIs toward named enums or parameter structs.
- `clippy::must_use_candidate = "warn"`
  Highlight return values that are easy to ignore by mistake.
- `clippy::wildcard_imports = "warn"`
  Keep names explicit and reviewable.
- `clippy::match_wildcard_for_single_variants = "warn"`
  Avoid losing exhaustiveness when only one variant is being ignored.
- `clippy::manual_assert = "warn"`
  Prefer `assert!` over `if` plus `panic!` when the intent is an
  assertion.
- `clippy::unnecessary_unwrap = "warn"`
  Prefer `if let`, `match`, or other direct control flow when unwrap
  cannot actually fail.

## Review guidance

- Prefer `deny` for library code and public APIs when violating the lint
  would create non-local maintenance risk.
- Prefer `warn` for application code first, then tighten once the team
  has handled the false positives and intentional exceptions.
- Allow `unwrap_used` and `expect_used` more freely in tests and quick
  prototypes, but still review whether they leak into shipped paths.
- Be cautious with `manual_assert` and other pedantic lints if the crate
  supports older Rust versions; some lints are relatively new.
- If the project already has lint policy, treat these as gaps to review,
  not as a reason to replace existing conventions wholesale.

## Sources

- Corrode, `Patterns for Defensive Programming in Rust`:
  <https://corrode.dev/blog/defensive-programming/>
- Corrode, `Don't Use Preludes And Globs`:
  <https://corrode.dev/blog/dont-use-preludes-and-globs/>
- Clippy overview and group guidance:
  <https://doc.rust-lang.org/stable/clippy/>
- Clippy lint catalog:
  <https://rust-lang.github.io/rust-clippy/master/>
