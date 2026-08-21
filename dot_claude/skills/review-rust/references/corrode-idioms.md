# Corrode Idiomatic Rust Review Notes

## Contents

- Type-driven design
- Ownership and API ergonomics
- Control flow and data flow
- Error handling and defensive programming
- Prototype versus production
- Source map

## Type-driven design

Use these checks when reviewing structs, enums, constructors, builders,
and public APIs.

- Ask whether invalid states are representable. If a value can be
  "misconfigured" by combining fields incorrectly, prefer an enum,
  newtype, state-specific type, or validated constructor.
- Treat related `bool` and `Option` fields as a possible hidden enum.
  If combinations are mutually exclusive or imply a state machine,
  model that in the type system.
- Prefer enums over booleans when the choice has semantic meaning.
  Names such as `bool is_ready` or `bool recurse` often hide a domain
  decision that deserves a named variant.
- Prefer small newtypes when raw `String`, `PathBuf`, integer, or UUID
  values have domain-specific rules.
- Ask where invariants are enforced. If the answer is "callers are
  expected to do the right thing", the API is weak.
- Prefer constructors that validate upfront over methods that accept
  temporarily-invalid values and hope later calls fix them.
- Review partial initialization patterns critically. If a struct is only
  valid after a sequence of calls, consider a builder or typed states.

## Ownership and API ergonomics

Use these checks when reviewing function signatures, traits, modules,
and public types.

- Treat explicit lifetime-heavy APIs as suspicious unless borrowing is
  materially simpler or cheaper than owning data.
- Prefer owned types or reference-counted/shared ownership when that
  removes brittle lifetime coupling at the API boundary.
- Start from concrete types. Only introduce generics, trait objects, or
  dense trait bounds when a real reuse or abstraction pressure exists.
- Review generic signatures for readability. If a caller has to decode
  three trait bounds and two conversion traits to use a helper, the API
  may be overfit.
- Prefer explicit imports over wildcard imports and ad-hoc preludes in
  application code. Ambiguous names make review and maintenance harder.
- Consider `IntoIterator` or iterator-returning APIs when a function
  naturally consumes or produces a sequence.
- Do not force one paradigm. Iterator chains, fluent APIs, visitor-style
  dispatch, or straightforward loops are all fine when they match the
  problem domain.
- Keep module structure simple while code is still taking shape. Review
  premature file splitting or generic abstraction as a maintenance cost.

## Control flow and data flow

Use these checks when reviewing local implementation details.

- Prefer expressions and early returns over placeholder mutation when it
  makes the logic easier to read.
- Prefer immutability by default. Compute values from existing data
  before introducing `mut` state that must be tracked mentally.
- Use iterator chains when they clarify the data transformation. Prefer
  loops when branching, state, or side effects would make the chain less
  readable.
- Question code that clones or allocates only to satisfy a shape that a
  different design could avoid, but do not reject a small clone if it
  buys major clarity.
- Review `match` expressions for exhaustiveness and intent. A broad
  catch-all arm can hide future variants or logic mistakes.

## Error handling and defensive programming

Use these checks when reviewing fallible code and boundary handling.

- Avoid `unwrap` and `expect` in production paths unless the invariant
  is local, obvious, and documented by the message.
- Look for panic surfaces beyond `unwrap`: indexing, slicing, integer
  assumptions, and APIs with hidden failure modes in "safe" code.
- Treat "safe Rust" as memory-safe, not logic-safe. Review for protocol
  mistakes, state bugs, surprising `Drop`, and misuse of standard
  library APIs.
- Consider whether `Result` or `Option` handling can be clearer with
  `let-else`, `match`, combinators, or explicit error conversion instead
  of nested branching.
- Prefer defensive constructors and helper APIs that make misuse hard.
- Consider `#[must_use]` when ignoring a return value would be a bug.
- Prefer explicit field destructuring when the exact shape matters. A
  `..` pattern can silently tolerate fields that future code should
  notice.
- Suggest Clippy lints when they fit the project bar. Useful examples
  include `clippy::wildcard_imports`, `clippy::unwrap_used`,
  `clippy::expect_used`, `clippy::indexing_slicing`, and
  `clippy::manual_assert`.

## Prototype versus production

Use these checks to calibrate the review instead of applying one bar to
every Rust file.

- Accept more shortcuts in prototypes: inline modules, concrete types,
  temporary cloning, reduced error modeling, and occasional `unwrap`
  during exploration.
- Tighten the bar for public APIs, persistence boundaries, network code,
  concurrency, FFI, and anything about to ship.
- If code is prototype-grade, focus findings on what will block turning
  it into production code: missing invariants, unstable API shape,
  panic-heavy error paths, or brittle ownership design.
- Prefer "simplify first, generalize later". Rust makes it easy to
  over-engineer abstractions before the shape of the problem is clear.

## Source map

These notes were distilled from Corrode articles that are especially
useful for Rust review work:

- `Make Illegal States Unrepresentable`:
  <https://corrode.dev/blog/illegal-state/>
- `Compile-Time Invariants in Rust`:
  <https://corrode.dev/blog/compile-time-invariants/>
- `Prefer Enums Over Booleans in Rust APIs`:
  <https://corrode.dev/blog/enums/>
- `Aim for Immutability in Rust`:
  <https://corrode.dev/blog/immutability/>
- `Thinking in Iterators`:
  <https://corrode.dev/blog/iterators/>
- `Thinking in Expressions`:
  <https://corrode.dev/blog/expressions/>
- `Do Not Worry About Lifetimes`:
  <https://corrode.dev/blog/lifetimes/>
- `Don't Unwrap Options: There Are Better Ways`:
  <https://corrode.dev/blog/rust-option-handling-best-practices/>
- `Navigating Rust's Functional and Imperative Paradigms`:
  <https://corrode.dev/blog/paradigms/>
- `Pitfalls of Safe Rust`:
  <https://corrode.dev/blog/pitfalls-of-safe-rust/>
- `Patterns for Defensive Programming in Rust`:
  <https://corrode.dev/blog/defensive-programming/>
- `Don't Use Preludes And Globs`:
  <https://corrode.dev/blog/dont-use-preludes-and-globs/>
- `Be Simple`:
  <https://corrode.dev/blog/simple/>
- `On Prototyping`:
  <https://corrode.dev/blog/prototyping/>
