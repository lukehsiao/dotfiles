# Idiomatic Control Flow and Functional Style

## Contents

- Core stance
- Choose the right control-flow shape
- Option and Result handling
- Iterator style
- Match style
- Review smells
- Sources

## Core stance

- Treat Rust as expression-oriented, but do not force a functional style
  when a loop or explicit branch is clearer.
- Prefer the shape that matches the problem domain. Corrode's guidance is
  explicit on this point: simple `for` loops are fine, and iterator-heavy
  code is not automatically better.
- Prefer control flow that keeps the happy path obvious and pushes error
  handling or exceptional cases to the boundary.

## Choose the right control-flow shape

- Use `match` when multiple variants are semantically important, when
  exhaustiveness matters, or when each arm carries real business logic.
- Use `if let` when exactly one pattern matters and the fallback path is
  trivial.
- Use `let-else` when the success path should stay in the surrounding
  scope and the failure path should diverge early with `return`, `break`,
  or `continue`.
- Use let chains when a series of dependent pattern matches and boolean
  checks forms one readable condition. Check the edition first: chaining
  `let` expressions in `if` and `while` conditions requires Rust 2024.
- Use `while let` when consuming or draining a stream-like source until a
  pattern stops matching.
- Prefer expression forms over temporary mutable placeholders when the
  expression stays readable. If the expression becomes clever, back out.

## Option and Result handling

- Prefer `let-else` for the common "extract or return early" case. It
  keeps the happy path visually dominant and avoids nested branches.
- Prefer `match` when both success and failure branches need real logic
  or when the review depends on exhaustiveness.
- Prefer combinators such as `map`, `and_then`, `filter`,
  `map_or_else`, and `ok_or_else` for short, local transformations.
- Stop chaining combinators once the code hides control flow, ownership,
  or error conversion. Switch to `match` or `let-else` before the reader
  needs to simulate types in their head.
- Review `unwrap` and `expect` as explicit panic boundaries, not just
  convenience. They can be justified, but they should be deliberate.
- In application code, `anyhow::Context` can be a pragmatic boundary
  choice. In library code, prefer preserving concrete error structure
  unless erasure is intentional.

## Iterator style

- Prefer iterators when the code is fundamentally a data transformation,
  selection, search, aggregation, or pipeline.
- Prefer loops when the code is stateful, side-effect driven, branching
  heavily, or easier to explain step by step.
- Prefer iterator methods that communicate intent directly:
  `map`, `filter`, `find`, `any`, `all`, `sum`, `collect`, and
  `try_fold` are often clearer than hand-written bookkeeping.
- Avoid collecting early just to keep using iterator-style operations.
  Collect at the boundary where ownership or container shape is actually
  needed.
- Avoid dense iterator chains with side effects or ownership gymnastics.
  A readable loop is more idiomatic than a clever pipeline.

## Match style

- Prefer exhaustive variant handling when reviewing public enums or
  dependency enums that may grow over time.
- Be cautious with `_` arms on non-local enums; they can turn future API
  changes into silent logic bugs.
- Use match guards sparingly. They are useful, but a dense guard can make
  exhaustiveness and branch intent harder to review.
- Match on place expressions when practical so borrows and lifetimes stay
  simpler and less temporary.

## Review smells

- Mutation that exists only because an expression form was not used.
- Iterator chains that are harder to read than the equivalent loop.
- Nested `if let` blocks that would read better as `let-else`, `match`,
  or let chains.
- `match` statements with one meaningful arm and a throwaway `_` arm.
- Combinator chains that obscure ownership, allocation, or error
  propagation.
- Broad wildcard matches that weaken future-proofing.

## Sources

- Corrode, `Thinking in Iterators`:
  <https://corrode.dev/blog/iterators/>
- Corrode, `Thinking in Expressions`:
  <https://corrode.dev/blog/expressions/>
- Corrode, `Navigating Programming Paradigms in Rust`:
  <https://corrode.dev/blog/paradigms/>
- Corrode, `Don't Unwrap Options: There Are Better Ways`:
  <https://corrode.dev/blog/rust-option-handling-best-practices/>
- The Rust Book, `Concise Control Flow with if let and let...else`:
  <https://doc.rust-lang.org/book/ch06-03-if-let.html>
- The Rust Edition Guide, `let chains in if and while`:
  <https://doc.rust-lang.org/edition-guide/rust-2024/let-chains.html>
- The Rust Reference, `If expressions`:
  <https://doc.rust-lang.org/reference/expressions/if-expr.html>
- The Rust Reference, `Match expressions`:
  <https://doc.rust-lang.org/reference/expressions/match-expr.html>
