# Rust Prototyping and Simplicity Review

## Contents

- Core stance
- Legitimate prototype shortcuts
- Simplicity heuristics
- Transitioning to production
- Review smells
- Sources

## Core stance

- Prefer simple code over reusable-looking code that has not earned its
  abstraction yet.
- Allow more freedom during prototyping, but name the debt clearly.
- Review whether the current stage is exploration, internal tooling, or
  production code before pushing for strict generality.

## Legitimate prototype shortcuts

- Prefer concrete types before generic abstractions.
- Prefer owned data before complex borrowing and lifetime coupling.
- Accept extra cloning when it keeps exploration moving and the hot path
  is not yet proven.
- Inline modules, temporary glue code, `dbg!`, `todo!`, and direct
  instrumentation can be reasonable in prototypes.
- Temporary use of `Rc`, `Arc`, or other ownership simplifications can
  be acceptable when the alternative is stalling on design too early.
- Short-lived scripts and experiments can justify lighter structure than
  long-lived crates.

## Simplicity heuristics

- Optimize for the common case first. Convenience for typical usage is
  often more valuable than maximal generality.
- Allow duplication before abstraction when the real axes of reuse are
  still unclear.
- Prefer straightforward loops, branches, and data structures over
  layered traits and helper types that mostly serve theoretical reuse.
- Treat small performance costs as acceptable when they buy clarity in
  non-hot paths.
- Prefer APIs that are obvious to call over APIs that are maximally
  flexible but cognitively expensive.
- Use lifetimes, traits, and macro machinery when they solve a concrete
  problem, not as a demonstration of Rust fluency.

## Transitioning to production

- Tighten error handling, invariants, and lint policy as code moves from
  prototype to production.
- Revisit convenience clones, shared-mutable ownership, and temporary
  runtime coupling once the problem shape is stable.
- Replace placeholder diagnostics and `todo!` with explicit contracts,
  tests, and documentation before shipping.
- Keep what proved valuable in the prototype; do not rewrite only to
  make the code look more sophisticated.

## Review smells

- Abstractions added before there are multiple real call sites or use
  cases.
- Generic signatures that make simple code harder to understand.
- Lifetime-heavy APIs chosen mainly to avoid small allocations or clones
  in unprofiled code.
- Complex trait hierarchies, macros, or module splitting without a clear
  maintenance payoff.
- Review comments that demand production-grade generality from obvious
  prototype code, or prototype shortcuts from production paths.

## Sources

- Corrode, `On Prototyping`:
  <https://corrode.dev/blog/prototyping/>
- Corrode, `Be Simple`:
  <https://corrode.dev/blog/simple/>
- Corrode, `Do Not Worry About Lifetimes`:
  <https://corrode.dev/blog/lifetimes/>
