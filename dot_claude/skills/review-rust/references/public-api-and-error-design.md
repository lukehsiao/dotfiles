# Rust Public API and Error Design Review

## Contents

- Core stance
- Public API surface
- Trait and type design
- Error design
- Semver and compatibility
- Review smells
- Sources

## Core stance

- Treat every public item as a compatibility promise.
- Keep the public surface smaller and more intentional than the
  implementation surface.
- Prefer APIs that are easy to evolve without surprising downstream
  users.

## Public API surface

- Avoid leaking dependency types in public signatures unless the crate is
  willing to make those dependencies part of its long-term contract.
- Prefer private fields on non-trivial structs so invariants and
  representation choices can evolve.
- Keep public enums, traits, and type aliases small and purposeful.
- Be conservative about exposing executor-specific, framework-specific,
  or transport-specific details in public APIs.

## Trait and type design

- Review whether a trait should really be public, object-safe, or
  downstream-implementable.
- Prefer sealed traits when extension by downstream crates is not part
  of the intended contract.
- Prefer standard conversion and collection conventions at boundaries
  when they improve interoperability.
- Avoid over-constraining public structs and types with unnecessary
  trait bounds.

## Error design

- Prefer typed, meaningful error values in library APIs.
- Error types in public `Result<T, E>` returns should implement
  `std::error::Error`, and ideally `Send` and `Sync` when practical.
- Prefer `thiserror` for library-facing error enums when it keeps the
  API explicit. The derive itself does not become part of the public
  API contract.
- Prefer `anyhow` or similar erased error types at application
  boundaries, not in reusable library interfaces.
- Review whether error variants expose enough structure for callers to
  react programmatically without binding them to unstable internals.
- Prefer adding human-readable context at application boundaries rather
  than erasing useful structure in library code.

## Semver and compatibility

- Review semver impact whenever public types, trait methods, variants,
  or bounds change.
- Suggest `#[non_exhaustive]`, sealed traits, or private fields when
  future evolution pressure is obvious.
- Prefer automated API diffing or semver linting when the crate ships
  libraries for external users.
- Use `cargo-semver-checks` for policy-style semver checks and
  `cargo-public-api` for concrete public API diffs.

## Review smells

- Public functions returning dependency-specific errors or transport
  types without intent.
- Traits made public only because they were useful internally.
- Public structs with exposed fields that should really be validated or
  evolved privately.
- Libraries using erased error types where callers need structure.
- Application code building large bespoke error hierarchies with no
  consumer benefit.

## Sources

- Rust API Guidelines, `Future proofing`:
  <https://rust-lang.github.io/api-guidelines/future-proofing.html>
- Rust API Guidelines, `Interoperability`:
  <https://rust-lang.github.io/api-guidelines/interoperability.html>
- Rust API Guidelines, `Flexibility`:
  <https://rust-lang.github.io/api-guidelines/flexibility.html>
- `thiserror` docs:
  <https://docs.rs/thiserror>
- `anyhow::Context` docs:
  <https://docs.rs/anyhow/latest/anyhow/trait.Context.html>
- Corrode, `Long-Term Rust Maintenance`:
  <https://corrode.dev/blog/long-term-rust-maintenance/>
