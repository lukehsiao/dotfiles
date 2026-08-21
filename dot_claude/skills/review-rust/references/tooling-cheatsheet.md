# Rust Tooling Cheatsheet

## Contents

- API and semver
- Supply chain and unsafe
- Maintenance
- Tests and docs
- Build and performance
- Release automation
- Sources

## API and semver

- `cargo semver-checks`
  Use for semver-policy checks on library crates.
- `cargo public-api diff <old>`
  Use for a concrete diff of the public API between versions, tags, or
  commits.

## Supply chain and unsafe

- `cargo deny check`
  Use for license, advisory, and dependency-policy checks.
- `cargo geiger`
  Use for visibility into local and transitive `unsafe` usage.

## Maintenance

- `cargo outdated`
  Use to see which dependencies lag behind available releases.
- `cargo audit`
  Use to check dependencies against the RustSec advisory database.
- `cargo tree`
  Use to inspect the dependency graph and spot duplicates or surprising
  transitive pulls.

## Tests and docs

- `cargo nextest run`
  Use when test scheduling, reporting, or large suites are slowing down
  `cargo test`.
- `cargo doc --open`
  Use to inspect local rustdoc output before publishing.
- `cargo package`
  Use to inspect what will actually be shipped.
- `cargo publish --dry-run`
  Use to verify publishability without pushing a release.

## Build and performance

- `cargo build --timings`
  Use to find where compile and link time is going.
- `cargo check`
  Use for fast local feedback when code generation is unnecessary.
- `cargo llvm-lines`
  Use to spot monomorphization-heavy codegen.

## Release automation

- `release-plz release-pr`
  Use to open or refresh a release-preparation PR.

## Sources

- `cargo-semver-checks`:
  <https://github.com/obi1kenobi/cargo-semver-checks>
- `cargo-public-api`:
  <https://github.com/cargo-public-api/cargo-public-api>
- `cargo-deny`:
  <https://embarkstudios.github.io/cargo-deny/cli/check.html>
- `cargo-geiger`:
  <https://docs.rs/cargo-geiger>
- `cargo-nextest`:
  <https://nexte.st/>
- Cargo Book, `cargo doc`:
  <https://doc.rust-lang.org/cargo/commands/cargo-doc.html>
- Cargo Book, `cargo package`:
  <https://doc.rust-lang.org/cargo/commands/cargo-package.html>
- Cargo Book, `Publishing on crates.io`:
  <https://doc.rust-lang.org/cargo/reference/publishing.html>
- Release-plz:
  <https://release-plz.dev/docs/github/quickstart>
- Corrode, `Tips for Faster Rust Compile Times`:
  <https://corrode.dev/blog/tips-for-faster-rust-compile-times/>
- Corrode, `Tips for Faster CI Builds`:
  <https://corrode.dev/blog/tips-for-faster-ci-builds/>
