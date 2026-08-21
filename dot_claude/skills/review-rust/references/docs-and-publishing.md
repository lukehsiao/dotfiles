# Rust Docs and Publishing Review

## Contents

- Core stance
- Rustdoc quality
- Docs.rs and metadata
- Package and publish verification
- Review smells
- Sources

## Core stance

- Treat documentation as part of the API contract.
- Review publishability before release day, not during release day.
- Prefer automated checks for docs and packaging whenever the crate is
  intended for reuse.

## Rustdoc quality

- Prefer `cargo doc --open` in local review loops for library-facing
  crates.
- Prefer doctests and examples that exercise the documented surface.
- Review intra-doc links and rustdoc-specific lints when docs rely on
  cross-references.
- Prefer documenting public APIs where callers need behavior,
  invariants, error conditions, or examples to use them correctly.

## Docs.rs and metadata

- Review whether docs.rs build settings need explicit metadata in
  `[package.metadata.docs.rs]`.
- Prefer crate metadata that makes the published artifact discoverable
  and trustworthy.
- Review whether the crate docs explain feature flags, optional runtime
  integrations, and examples that matter to first-time users.

## Package and publish verification

- Prefer `cargo package` to inspect the packaged tarball contents.
- Prefer `cargo publish --dry-run` before any real publish.
- Review that README, license files, examples, and generated sources are
  included or excluded intentionally.
- Review whether CI verifies packaging and docs alongside tests and
  lints.

## Review smells

- Public APIs with little or no rustdoc despite non-obvious behavior.
- Examples that likely do not compile or reflect current feature flags.
- Missing docs.rs metadata for crates with special doc build needs.
- Release flows that publish without a dry run or package inspection.
- Important package files unintentionally missing from the published
  crate.

## Sources

- Cargo Book, `cargo doc`:
  <https://doc.rust-lang.org/cargo/commands/cargo-doc.html>
- Cargo Book, `cargo package`:
  <https://doc.rust-lang.org/cargo/commands/cargo-package.html>
- Cargo Book, `Publishing on crates.io`:
  <https://doc.rust-lang.org/cargo/reference/publishing.html>
- Rustdoc Book:
  <https://doc.rust-lang.org/rustdoc/>
- Rustdoc Book, `Linking to items by name`:
  <https://doc.rust-lang.org/rustdoc/write-documentation/linking-to-items-by-name.html>
- docs.rs, `Metadata`:
  <https://docs.rs/about/metadata>
- Rust API Guidelines, `Documentation`:
  <https://rust-lang.github.io/api-guidelines/documentation.html>
