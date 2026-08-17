---
name: nullables
description: Nullables — testing technique alternative to using mocking libraries. Use when writing unit tests, when code touches external I/O or state (HTTP, databases, files, clock, random) anywhere in its dependency chain, when making a system testable, or when tests are slow or flaky. Also use when the user mentions "nullables", "createNull", "testing without mocks", "embedded stub", "output tracking", "sociable tests", or wants to remove or replace mocks, spies, and test doubles.
---

# Nullables: Testing Without Mocks

Nullables are production code with an off switch: classes with external I/O anywhere in their dependencies offer `create()` (real) and `createNull()` (I/O disabled, everything else runs normally). Tests are narrow (focused on one class), sociable (dependencies run for real), and state-based (assert outputs and state, never method calls). Don't use mocking libraries or DI frameworks — Nullables make them unnecessary.

## Fit and tradeoffs

The payoff: narrow tests with the coverage of end-to-end tests. Structural refactorings don't break them, because object interactions are implementation details, not asserted behavior. Error paths cost one configuration argument, and no mocking or DI framework has to be configured. Both speed wins are real and separate: Shore's benchmark of one test case puts a nulled test at 0.00093ms against 0.082ms on testdouble.js and 0.36ms on sinon, and the sociable coverage then removes the end-to-end test that ran 44ms.

The costs, to name before converting anything:

- Production code changes. Infrastructure classes gain factories, trackers, and an embedded stub that exist mostly for tests. Whether an off switch belongs in production code is the deciding question. A team that answers no can put the stub in a test-only file instead, at the cost of more complicated dependency management and no nulled instances in production.
- Hand-written stubs. One per technology, and grown by recording what the real library does under narrow integration tests, because the behavior a stub has to match (header casing, async timing) is the behavior you find by running it. Reusable, but not free.
- Sociable failures. One real bug can turn several tests red. The failing set points at the shared code; that is the overlap doing its job, but it surprises teams used to isolated mocks.

Adoption is incremental: mocks and Nullables coexist in the same suite and even the same test, so convert where testing hurts and skip code that is already easy to maintain ([migration.md](references/migration.md)). Two kinds of third-party code stay unwrapped, for different reasons: pervasive, stable platform code (the core language) isn't worth isolating, and UI frameworks are simply very costly to wrap. Everything that does I/O gets wrapped.

## The cut

Stub at the lowest point — the third-party edge — never your own code:

```
OrderService  →  PaymentClient  →  HttpClient  →  third-party lib
  app code       high-level        low-level       ✂ stubbed when nulled
                 wrapper           wrapper
```

- `PaymentClient` is a high-level wrapper: it abstracts one *service* and speaks domain language.
- `HttpClient` is a low-level wrapper: it abstracts one *technology* and is generic and highly reusable.
- The low-level wrapper holds the fork: `create()` wires the real library (node http, RestTemplate); `createNull()` wires an embedded stub — your code, returning canned data, doing no I/O.
- Everything left of the cut is your code and runs for real in tests.

With mocks, you only mock code you own; with Nullables, you only stub code you *don't* own. Only the bottom layer has a stub — one per technology. Everything above runs real in tests, so a bug anywhere in your code turns tests red. Mocking your own classes breaks that chain: mocked code never runs, and its bugs hide behind green tests.

An invented internal seam is the same break in disguise: cutting at `rows() → List<Row>` instead of the driver puts your mapping loop below the seam, where nulled tests never run it. The test: any parsing, mapping, or normalization you wrote must sit *above* the cut. When the third-party API is a chain of objects, mirror it — one stub class can play the whole chain (see the low-level wrapper files).

A vendor SDK is a legitimate edge. The low-level wrapper files say to go all the way down, which forbids stubbing your own convenience layer; it does not require bypassing a third-party client to re-drive its protocol yourself. The `stripe` package is code you don't own, so stub the SDK object and let your wrapper's request building and response parsing run above it. Reach past an SDK to the transport underneath only when several wrappers share that transport and you want a single low-level wrapper for it.

## Two channels, plus events

Every class that talks to infrastructure anywhere in its dependencies offers the same two factory methods:

```javascript
Clock.create()                            // production: the real system clock
Clock.createNull({ now: "2024-01-01" })   // test: frozen time, no external state
```

Tests interact with a nulled instance through three moves:

- **Reads** — configure what the world answers, as `createNull(...)` parameters in the caller's domain terms: `PaymentClient.createNull({ approved: false })`, `DieRoller.createNull([3, 5, 1])`. A single value repeats forever; a list is consumed in order, then fails fast. An error is just another configured response: `createNull([{ error: "boom" }])`.
- **Writes** — observe what the code sent, as domain data (track the data, not the rendered string):

  ```javascript
  const emails = emailer.trackOutput();
  await service.register("a@b.com");
  assert.deepEqual(emails.data, [{ to: "a@b.com", subject: "Welcome" }]);
  ```

  The same tracker can prove a negative — a test where registration is refused asserts `emails.data` is `[]`: no email went out.
- **Pushed events** — fire a simulated incoming event through the same handler path a real event takes: `network.simulateMessage("client-1", "Hello")`.

The read and write channels ride on two tiny utilities, `OutputListener`/`OutputTracker` and `ConfigurableResponses`; pushed events need neither, being plain handler extraction. When the codebase lacks the utilities, add them — example implementations in [utilities.md](references/utilities.md).

## Procedure

Start from the code you need to test. For a whole system, pick one class and repeat; conversion order across many classes is in [migration.md](references/migration.md).

1. List the dependencies of the class under test. Classify each one you need to control:
   - Pure logic, nothing external below → test directly, nothing to null.
   - Value object or config → `createTestInstance()` with safe overridable defaults. If it holds an infrastructure object, default it to the nulled version.
   - Already has `createNull()` → go to step 4.
   - Touches infrastructure below but has no `createNull()` → step 2.
2. Follow that dependency's chain down until you reach code you don't own — a third-party library doing I/O. That is the edge.
   - The codebase already has a wrapper for this technology (search `createNull`, `Stubbed`, `infrastructure/`) → reuse it, go to step 3.
   - No wrapper → build one: [building-low-level-wrappers-static.md](references/building-low-level-wrappers-static.md) when the seam is an interface you declare, [building-low-level-wrappers-dynamic.md](references/building-low-level-wrappers-dynamic.md) when any object with the right methods will do.
3. Walk back up the chain, giving each class `create()` and `createNull()` that compose its nulled dependencies — follow [building-high-level-wrappers.md](references/building-high-level-wrappers.md); its recipe carries the decomposition and tracker moves that keep layers honest, and this is where abstractions leak if you rush. Done when every class between the edge and the class under test has both factories, configuration in its own language decomposed downward, and its write channel tracked.
4. Write the tests following [consuming-nullables.md](references/consuming-nullables.md) — the fixture shape, error configs, and time travel live there. Done when every read, write, and error path of the class is asserted — both directions per dependency: the exact outgoing request (via that dependency's tracker) and the returned answer being used.

Converting a mock-based suite → [migration.md](references/migration.md). Improving existing nullables → walk their layers and check each against The cut and the rules below, plus: no leftover throwaway stubs. Structuring a new app around this (optional) → [architecture.md](references/architecture.md).

## Rules at every layer

Before committing a converted class, walk these as a checklist against it.

- `create()` wires production, `createNull()` wires nulled — both factories live on the wrapped class, never on the stub. The plain constructor is the test seam: tests use it to inject dependencies they hold handles on.
- Configure and assert as the state of the world the caller wants to control, in the caller's language: `PaymentClient.createNull({ approved: false })`, not HTTP statuses. Each layer decomposes its configuration into its dependency's language.
- Bare `createNull()` always works: every parameter has a safe default, so one call nulls the whole dependency chain from the top (parameterless instantiation).
- Every invented default is loud and self-naming — `"Nulled HttpClient default body"`, status 503, timezone `Australia/Lord_Howe`; stub errors self-name too (`"Nulled Jdbc: the database is down"`). Nothing breaks on these, but a test that accidentally depends on one sees obviously fake data instead of passing by luck. Collections default empty — the default world is empty; absurd *entries* would be mistakable for real data. Failing fast is reserved for overrunning explicit configuration: an exhausted response list throws "No more responses configured…".
- Constructors do no work. Connecting, starting, listening happen in explicit methods, so instantiating the whole dependency tree is always safe.
- One test helper owns construction and wiring (signature shielding): optional named parameters with `IRRELEVANT_*` defaults, returning a bag of results and trackers. A signature change hits one place.
- Stay in consumer scope: assert that the request went out and the answer got used. The dependency's own tests cover its behavior.
- Wrappers validate external responses hard and throw detailed errors on anything unexpected; callers decide how to recover. Paranoic telemetry is the whole loop, not just the throw: every failure path, hangs included, has to end in a logged error and an alert somewhere above the wrapper, and each of those paths gets its own test.
- Only the lowest wrapper gets narrow integration tests against the real system. They document the third-party behavior the stub must match — that pairing keeps the stub honest. For a hosted system you can't start and stop locally, the wrapper files cover what to run instead and what it does not buy you.

## Anti-patterns

- A test file as the stub's permanent home. The embedded stub is production code, tested like production code, and lives beside its wrapper; that placement is what lets a nulled instance serve a dry-run flag or cache warming. Two things are not this anti-pattern: the test-only placement above, chosen deliberately by a team that refuses production stubs, and a throwaway stub during migration, which is a named pattern with its own exit criteria.
- A stub that reimplements the real system — stubs return canned data; needing real logic means you're cutting at the wrong level.
- A `nulled` flag forking the wrapper's logic with if-branches — nulling swaps the wrapped dependency at the seam; the wrapper keeps one code path.
- Computing an assertion's expected value with the code under test — the test then verifies nothing.

## Quick diagnostic

Symptom-to-move lookup when the entry point isn't a fresh conversion:

| Symptom | Move |
|---------|------|
| Test touches real network, disk, clock, or randomness | Null the chain: [Procedure](#procedure) |
| `verify(x).calledWith(...)` assertions break on refactor | Swap call assertions for tracker assertions on domain data — [migration.md](references/migration.md) |
| Error, timeout, or hang path untestable | One configuration argument: `createNull([{ error: "boom" }])`, `{ hang: true }` — [consuming-nullables.md](references/consuming-nullables.md) |
| No wrapper exists for the technology | Build the bottom layer — [building-low-level-wrappers-static.md](references/building-low-level-wrappers-static.md) / [-dynamic.md](references/building-low-level-wrappers-dynamic.md) |
| Wrapper exists, but the class above it isn't Nullable | Compose upward — [building-high-level-wrappers.md](references/building-high-level-wrappers.md) |
| Setup duplicated across tests; a signature change fans out | One helper with `IRRELEVANT_*` defaults — [consuming-nullables.md](references/consuming-nullables.md) |
| Suite green, but a bug shipped in a class a mock replaced | Mocked code never runs; convert that seam — [migration.md](references/migration.md) |
| Assertions depend on timestamps or generated IDs | Configure the source: nulled Clock, nulled UuidGenerator — [consuming-nullables.md](references/consuming-nullables.md) |

## Pattern-name index

The source article is a pattern language, so requests may arrive in its vocabulary. Where each pattern lives here:

| Article pattern | Where |
|-----------------|-------|
| Nullables | The whole document; factory shape in Two channels |
| Narrow Tests, State-Based Tests, Overlapping Sociable Tests | Intro; assertion discipline in [consuming-nullables.md](references/consuming-nullables.md) |
| Zero-Impact Instantiation, Parameterless Instantiation | Rules: "constructors do no work", "bare `createNull()` always works" |
| Signature Shielding | Rules; [consuming-nullables.md](references/consuming-nullables.md) |
| Infrastructure Wrapper, Embedded Stub | The cut; [building-low-level-wrappers-static.md](references/building-low-level-wrappers-static.md), [-dynamic.md](references/building-low-level-wrappers-dynamic.md) |
| Thin Wrapper | "The Thin Wrapper pattern" in [building-low-level-wrappers-static.md](references/building-low-level-wrappers-static.md); only declared-interface languages need it |
| Narrow Integration Tests | Rules; the low-level wrapper files |
| Paranoic Telemetry | Rules; step 5 of [building-high-level-wrappers.md](references/building-high-level-wrappers.md) |
| Configurable Responses, Output Tracking | Two channels; [utilities.md](references/utilities.md) |
| Behavior Simulation | Two channels; "Simulating incoming events" in [consuming-nullables.md](references/consuming-nullables.md); the low-level wrapper files |
| Fake It Once You Make It | [building-high-level-wrappers.md](references/building-high-level-wrappers.md) |
| Collaborator-Based Isolation, Smoke Tests | Closing bullets of "Assertion discipline" in [consuming-nullables.md](references/consuming-nullables.md) |
| Easily-Visible Behavior, Testable Libraries | Logic layer in [architecture.md](references/architecture.md) |
| A-Frame Architecture, Logic Sandwich, Traffic Cop | [architecture.md](references/architecture.md) |
| Grow Evolutionary Seeds | "Growing new code" in [architecture.md](references/architecture.md) |
| Descend/Climb the Ladder, Replace Mocks with Nullables, Throwaway Stub | [migration.md](references/migration.md) |

## Source material

James Shore's ["Testing Without Mocks: A Pattern Language"](https://www.jamesshore.com/v2/projects/nullables/testing-without-mocks) is the canonical text; the pattern names above are his. [credits.md](credits.md) links his course and the example repositories, including a production-grade one.
