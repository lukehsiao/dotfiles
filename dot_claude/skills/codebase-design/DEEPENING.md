# Deepening

How to deepen a cluster of shallow modules safely, given its dependencies. Assumes the vocabulary in [SKILL.md](SKILL.md): **module**, **interface**, **seam**, **adapter**.

## Dependency categories

When assessing a candidate for deepening, classify its dependencies. The category determines how the deepened module is tested across its seam.

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable: merge the modules and test through the new interface directly. No adapter needed.

### 2. Local-substitutable

Dependencies that have local test stand-ins (PGLite for Postgres, in-memory filesystem). Deepenable if the stand-in exists. The deepened module is tested with the stand-in running in the test suite. The seam is internal; no port at the module's external interface.

### 3. Remote but owned (Ports & Adapters)

Your own services across a network boundary (microservices, internal APIs). The deep module owns the logic; the transport is an **adapter**. Production uses an HTTP/gRPC/queue adapter. Tests use that same adapter's nulled instance, following the `nullables` skill, so its request building and response parsing still run. Define a **port** (interface) at the seam only when a second production transport exists.

Recommendation shape: *"Move the logic into one deep module. It reaches the service through a nullable HTTP adapter, so tests run the logic without the network."*

### 4. True external (Nullable)

Third-party services (Stripe, Twilio, etc.) you don't control. The deepened module reaches the service through an adapter that wraps its SDK. Tests use the adapter's nulled instance, which stubs at the third-party edge following the `nullables` skill, so the module's own request building and response parsing still run.

In Rust, keep the nulled arm and `create_null` of a §3 or §4 adapter under a test-only `cfg`, so production pays nothing for them. See `references/rust.md` in the `nullables` skill.

## Seam discipline

- **One adapter means a hypothetical seam. Two adapters means a real one.** Don't introduce a port unless at least two production adapters are justified. A Nullable does not count as a second adapter: it is the production adapter with its I/O switched off. A single-adapter seam is just indirection.
- **Internal seams vs external seams.** A deep module can have internal seams (private to its implementation, used by its own tests) as well as the external seam at its interface. Don't expose internal seams through the interface just because tests use them.

## Testing strategy: replace, don't layer

- Old unit tests on shallow modules become waste once tests at the deepened module's interface exist; delete them.
- Write new tests at the deepened module's interface. The **interface is the test surface**.
- Tests assert on observable outcomes through the interface, not internal state.
- Tests should survive internal refactors, since they describe behaviour, not implementation. If a test has to change when the implementation changes, it's testing past the interface.
