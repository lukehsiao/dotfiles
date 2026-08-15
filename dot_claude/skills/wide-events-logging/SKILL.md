---
name: wide-events-logging
description: Instrument services with wide events (canonical log lines): one context-rich structured event per unit of work instead of scattered log statements. Covers what to capture, the middleware pattern, high-cardinality fields, sampling (including smart tail sampling), and how to query the result. Use when writing or reviewing logging code or designing observability for a service.
---

# Wide Events

Emit exactly **one structured event per unit of work** (an HTTP request, a
background job, a queue message), containing every field you can cheaply
collect about that work. Do not scatter `log.info("doing X")` narration
through the code path; accumulate context into a single event and emit it
when the work finishes.

A wide event is just a flat bag of key-value fields, like one JSON document.
Traces, logs, and metrics are all special cases of it: a span is a wide event
with `trace_id`/`span_id`/`parent_span_id`; a metric is a periodic wide event
snapshotting counters. One well-built event stream can answer questions all
three "pillars" were supposed to answer, plus the ones you didn't predict.

## Why: unknown unknowns

Pre-aggregated metrics can only answer questions someone thought to ask in
advance. Incidents are dominated by questions nobody predicted, such as "only
Android app build N on OS version M, for one campaign type, is failing."
The way you find that is iterative slicing of raw events: group by a field,
spot the anomalous group, filter to it, group by the next field, repeat.
That workflow requires the context to already be on the events. So when in
doubt: **add the field.** The marginal cost of one more column is near zero
in columnar storage (repeated values dictionary-encode to almost nothing),
and high cardinality is fine because nothing is pre-aggregated. Prefer wider
events at a higher sample rate over narrow events at full volume.

## Implementation pattern

1. **Middleware owns the lifecycle.** At request start, create the event
   (or grab the tracing SDK's request-wrapping span) and stash a reference in
   the request context. At request end, in a `finally`/deferred hook, attach
   status, duration, and error info, then emit. Infrastructure fields belong
   in middleware; business fields are added by handlers as they learn them.
2. **Expose one enrichment helper.** Handlers call something like
   `event.set("checkout.cart_value_usd", 42)` against the context; they never
   construct or emit events themselves.
3. **Mark the canonical event.** Set `main=true` (or similar) on the
   per-request event so it is trivially separable from child spans:
   `WHERE main = true GROUP BY http.route` is the "what is this service
   doing" query.
4. **Keep phase timings on the main event.** Record
   `auth.duration_ms`, `db.duration_ms`, `render.duration_ms` as fields
   rather than only as child spans. Fields aggregate and heatmap across all
   requests; a waterfall only explains one request.
5. **Summarize fan-out.** Roll up child work into counts and totals on the
   main event: `db.query_count`, `db.duration_ms`, `http.requests_count`,
   per-vendor call counts. Outliers (a request issuing 700 queries) become
   one `HEATMAP` away.

## What to capture

Aim for dozens to hundreds of fields. Categories, roughly in order of value:

- **Request:** method, matched route pattern (`/team/{id}`), interesting
  route/query params, status code, request/response body sizes, request ID,
  parsed user-agent (device/OS/app/version), client IP.
- **Who:** `user.id`, `user.type` (free/enterprise/vip), auth method, org and
  team IDs, account age, and `user.assumed_by` for support impersonation.
  This is the highest-value category and no SDK adds it for you. One account
  is often 10%+ of revenue with traffic that looks nothing like the average;
  you must be able to isolate it.
- **Build and deploy:** version, git SHA, deploy timestamp or
  `deployment.age_minutes`, deploy trigger and actor. "Did something just
  ship?" becomes a group-by instead of a trip to another tool.
- **Where:** service name, environment, owning team, instance ID and size,
  region and zone, container and pod names.
- **Runtime health:** `uptime_sec` (and its log10, which makes crash loops
  visible next to week-old instances), a cached ~10s snapshot of memory, CPU
  load, and GC stats. Good for debugging correlation, not for alerting.
- **Outcome:** `error=true`, exception type, message, stacktrace, and an
  `error.slug`: a unique hardcoded string at each throw site
  (`"stripe-retries-exhausted"`). Slugs are greppable straight to the line of
  code and give a low-cardinality group-by. A failed request *without* a slug
  is a hole in your error handling; query for those.
- **Behavior toggles:** every feature flag evaluated for the request. This is
  what makes progressive rollouts and migrations observable: compare error
  and latency distributions across flag values.
- **Dependencies:** cache hit/miss per cache, rate-limit state
  (limit/remaining/used), vendor transaction IDs, queue depths at enqueue
  time, versions of runtime and key frameworks.
- **Domain:** the fields unique to your product; cart value, document size,
  warehouse ID, model name. No convention or SDK can supply these; they are
  usually what cracks the incident.

Follow OpenTelemetry semantic conventions for names where one exists
(`http.response.status_code`, `url.path`), but shipping data beats naming
perfection; make names consistent within the org first.

## Sampling

At scale you keep a statistically useful subset, not everything. The rules:

- **Record the rate on the event.** Every event carries `sample_rate` (N
  where 1-in-N is kept). Query tools then upscale transparently, i.e.
  `SUM(sample_rate)` instead of `COUNT(*)`, so charts show true totals even
  when different events were sampled at different rates. This one field is
  what makes every smarter strategy possible later.
- **Start dumb.** Uniform random head sampling (decide at request start) at
  1-in-N is fine on day one. Even 1-in-1000 paints an accurate picture of
  aggregate traffic.
- **Graduate to smart tail sampling.** Because the wide event is emitted at
  the *end* of the work, you know the outcome before you must decide to keep
  it. Choose the rate from what the event contains:
  - errors and 5xx: keep 100% (`sample_rate=1`)
  - latency outliers (over SLO, or over ~p99): keep 100%
  - rare or high-value segments (enterprise tier, new build, flag cohort,
    first requests of a new deploy): keep at a high rate
  - healthy, fast, common 200s: sample aggressively (1-in-100+, per route)
  - optionally key the decision on the whole trace (any span failed →
    keep all of it), which is what dedicated tail samplers do
- **Budget by value, not uniformly.** A health-check endpoint deserves
  1-in-10000; checkout deserves 1-in-1.

## Querying the result

Get fast at three moves and iterate in seconds, not minutes:

- **Visualize:** `COUNT`, `P90`/`P99`, `MAX`, and especially heatmaps, which
  expose outliers and multi-modal distributions that percentile lines hide.
- **Group:** `GROUP BY` any field to see which value misbehaves.
- **Filter:** `WHERE` the anomalous value, then group by the next field.

The loop "group → spot anomaly → filter → group again" localizes incidents
without prior knowledge of the system. Any columnar/OLAP-backed tool works
(Honeycomb, ClickHouse-based stacks, DataDog events, DuckDB over parquet);
plain full-text log search makes this workflow painful.

## Anti-patterns

- Narrating progress with many small log lines per request (undiagnosable,
  and usually *more* total bytes than one wide event).
- Wrapping every function in a child span instead of putting phase timings
  and rollups on the main event.
- Withholding a field because "it's the same for every request"; constant
  columns compress to almost nothing.
- Avoiding user IDs or request IDs for cardinality reasons; raw-event stores
  don't have a cardinality problem (do respect PII policy).
- Emitting the event only on success; the `finally` path must emit on error
  and timeout too, or you lose exactly the events you need.
- Dropping all metrics: keep a small set for cheap exact alerting
  (request counts, CPU); wide events answer the investigative questions.

## Sources

Synthesized from Ivan Burmistrov's "All you need is Wide Events, not
'Metrics, Logs and Traces'"
(https://isburmistrov.substack.com/p/all-you-need-is-wide-events-not-metrics)
and Jeremy Morrell's "A Practitioner's Guide to Wide Events"
(https://jeremymorrell.dev/blog/a-practitioners-guide-to-wide-events/).
See also Brandur Leach's canonical log lines
(https://brandur.org/canonical-log-lines) and Stripe's write-up
(https://stripe.com/blog/canonical-log-lines).
