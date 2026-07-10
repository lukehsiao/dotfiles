# Architecture Patterns (optional)

Nullables work inside whatever design already exists — none of this is required. These patterns are for when you're shaping new code, or refactoring anyway, and want the structure that makes testing with Nullables most natural.

## A-Frame

A layered architecture puts Logic on top of Infrastructure, so logic can't run without I/O underneath it. A-Frame makes them peers:

```
        Application (coordinates)
          ↓                  ↓
Logic (pure functions)   Infrastructure (Nullables)
          ↖  Value Objects  ↗
```

- **Logic** — pure computation. No I/O, no side effects, no dependency on anything that has them. Tested directly; needs no Nullables at all. Prefer pure functions and immutable objects; give mutable state a getter or change event so tests can see it (easily-visible behavior). Never reach through a dependency into state two levels down — each object encapsulates its next level.
- **Infrastructure** — wrappers with `create()`/`createNull()`.
- **Application** — thin coordination between the two. Tested with Nullables.

Logic never imports Infrastructure; the layers exchange Value Objects — plain data. Time is the classic case: pass `today` into logic as a value (`isOverdue(book, today)`); only the application layer asks a Clock.

## Logic Sandwich

The application layer's basic move — read, process, write:

```javascript
async processOrder(orderId) {
  const order = await this._db.getOrder(orderId);        // READ (infrastructure)
  const result = OrderLogic.process(order);              // PROCESS (pure logic)
  await this._db.save(result);                           // WRITE (infrastructure)
  this._logger.info("order processed", { orderId });
}
```

Tests null the infrastructure, configure the reads, and assert the writes via trackers. When the middle grows complicated, extract it into the Logic layer, where it's tested as plain functions.

## Traffic Cop

For event-driven code (sockets, queues, schedulers): the application layer observes events and runs a Logic Sandwich per event.

```javascript
async startAsync() {
  this._network.onMessage((clientId, message) => {
    const user = /* READ */;
    const outgoing = ChatLogic.route(user, message);      /* PROCESS */
    outgoing.forEach((m) => this._network.send(m));       /* WRITE */
  });
  await this._network.startAsync();
}
```

Tests drive it with Behavior Simulation (`network.simulateMessage(...)`) and assert with trackers. Keep each handler a focused sandwich; if the cop accumulates logic, push it into the Logic layer or split handlers.

## Growing new code

Starting fresh: begin with one application class returning a hardcoded value, add the first infrastructure wrapper when a real value is needed, make it Nullable, and keep extracting Logic as the application layer gets messy. The architecture emerges; it isn't scaffolded up front.
