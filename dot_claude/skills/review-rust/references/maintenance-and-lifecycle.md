# Rust Maintenance and Lifecycle Review

## Contents

- Core stance
- Dependency policy
- API and architecture stability
- Toolchain and release discipline
- Documentation and testing
- Unsafe and boundary hygiene
- Review smells
- Sources

## Core stance

- Favor boring, stable technology for long-lived Rust codebases.
- Prefer decisions that make the crate easy to update, document, test,
  and release over decisions that are locally clever.
- Review long-term maintenance cost, not just whether the code works
  today.

## Dependency policy

- Keep the dependency graph small. Prefer `std` or small focused crates
  when they are good enough.
- Prefer mature crates with stable releases and clear maintenance
  signals over fashionable or experimental dependencies.
- Review whether default features are accidentally pulling in heavy or
  unnecessary functionality. Prefer `default-features = false` and opt
  back in deliberately.
- Avoid pinning exact versions unless there is a concrete breakage or
  compatibility reason.
- Suggest dependency maintenance tooling when missing:
  `cargo outdated`, `cargo tree`, `cargo audit`, and automated update
  bots.

## API and architecture stability

- Keep the core domain logic framework-agnostic where practical.
- Be conservative about exposing `async` in public APIs. Runtime-coupled
  public interfaces can be expensive to maintain.
- Keep public APIs small and intentional. Every exposed type or trait is
  maintenance surface.
- Review semver risk explicitly when changing public types, enum
  variants, trait bounds, or error types.
- Prefer low coupling and high cohesion across crates and modules.
- Suggest `cargo-semver-checks` when the project ships public crates and
  compatibility matters.

## Toolchain and release discipline

- Prefer stable Rust for long-lived production code unless nightly is a
  deliberate and justified dependency.
- Update the toolchain regularly instead of letting many releases pile
  up.
- Review edition lag as maintenance debt. Edition migration should be
  deliberate and tested, not indefinite.
- Prefer reproducible CI and release builds.
- Favor automated, repeatable release flows over ad hoc manual steps.
- Suggest making releases boring: frequent CI runs, scripted release
  steps, and regular maintenance windows.

## Documentation and testing

- Treat documentation as part of the API contract, not as cleanup work.
- Prefer `missing_docs` and doctests for library-facing crates when that
  matches the project's bar.
- Review whether examples in docs are likely to stay correct. Tools such
  as `doc-comment` can help keep README snippets executable.
- Treat tests as executable documentation of behavior and invariants.
- Keep test suites easy to run locally. Slow or fragile tests create
  maintenance drag and hide regressions.

## Unsafe and boundary hygiene

- Minimize `unsafe` and contain it behind small safe APIs with explicit
  invariants.
- Review whether `unsafe` code is documented with the assumptions that
  make it sound.
- Review boundary types carefully: deserialization, FFI, filesystem,
  networking, and persistence code tend to accumulate maintenance risk.
- Suggest `cargo-geiger` when the project needs visibility into local
  and transitive `unsafe`.

## Review smells

- New dependencies added for narrow convenience with little enduring
  value.
- Public APIs that unnecessarily commit callers to a runtime,
  framework, or internal representation.
- Heavy default features enabled without evidence they are needed.
- Release or compatibility policy left implicit.
- Libraries with weak docs, no doctests, or examples that are likely to
  rot.
- `unsafe` blocks with no local safety comment or invariant statement.

## Sources

- Corrode, `Long-Term Rust Maintenance`:
  <https://corrode.dev/blog/long-term-rust-maintenance/>
- Corrode, `On Prototyping`:
  <https://corrode.dev/blog/prototyping/>
- Corrode, `Pitfalls of Safe Rust`:
  <https://corrode.dev/blog/pitfalls-of-safe-rust/>
