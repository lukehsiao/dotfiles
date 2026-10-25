# Utilities: OutputListener and ConfigurableResponses

Two tiny reusable classes carry the whole approach — one for the write channel, one for the read channel. Copy them into the codebase (e.g. `infrastructure/util/`) when it doesn't have them; they are production code and get committed like any other. JS and Java versions are below. The Rust version is one module at the end. In another language, port them, preserving the semantics stated with each (they are well under 100 lines apiece).

## Contents

- OutputListener / OutputTracker (write channel)
- ConfigurableResponses (read channel)
- Rust (both utilities, one module)

## OutputListener / OutputTracker

Wrappers hold an `OutputListener` and `emit(domainData)` at the moment of each write, in code shared by real and nulled paths. Tests call `trackX()` to get an `OutputTracker`. No tracker subscribed → emit is a no-op.

JavaScript/TypeScript:

```javascript
// Adapted from OutputTracker by James Shore, Copyright 2020-2022 Titanium I.T. LLC. MIT License.
import { EventEmitter } from "node:events";

const EVENT = "output";

export class OutputListener {
  constructor() {
    this._emitter = new EventEmitter();
  }
  emit(data) {
    this._emitter.emit(EVENT, data);
  }
  trackOutput() {
    return new OutputTracker(this._emitter);
  }
}

class OutputTracker {
  constructor(emitter) {
    this._emitter = emitter;
    this._data = [];
    this._listener = (item) => this._data.push(item);
    this._emitter.on(EVENT, this._listener);
  }
  get data() {
    return this._data;
  }
  clear() {                       // return current data and reset
    const result = [...this._data];
    this._data.length = 0;
    return result;
  }
  stop() {                        // unsubscribe
    this._emitter.off(EVENT, this._listener);
  }
}
```

Java:

```java
// Adapted from code Copyright 2022 Titanium I.T. LLC and Ted M. Young. MIT License.
public class OutputListener<T> {
    private final List<OutputTracker<T>> listeners = new ArrayList<>();

    public void emit(T data) {
        listeners.forEach(tracker -> tracker.add(data));
    }

    public OutputTracker<T> trackOutput() {
        OutputTracker<T> tracker = new OutputTracker<>(this);
        listeners.add(tracker);
        return tracker;
    }

    void remove(OutputTracker<T> outputTracker) {
        listeners.remove(outputTracker);
    }
}

public class OutputTracker<T> {
    private final List<T> output = new ArrayList<>();
    private final OutputListener<T> outputListener;

    public OutputTracker(OutputListener<T> outputListener) {
        this.outputListener = outputListener;
    }

    void add(T data) {
        output.add(data);
    }

    public List<T> data() {
        return List.copyOf(output);
    }

    public List<T> clear() {
        List<T> data = this.data();
        output.clear();
        return data;
    }

    public void stop() {
        outputListener.remove(this);
    }
}
```

Usage in a wrapper:

```java
private final OutputListener<Game.Snapshot> listener = new OutputListener<>();

public void saveGame(Game.Snapshot snapshot) {
    gameDatabaseJpa.save(GameRow.from(snapshot));
    listener.emit(snapshot);                    // domain-level, both modes
}
public OutputTracker<Game.Snapshot> trackSaves() {
    return listener.trackOutput();
}
```

## ConfigurableResponses

Encapsulates the read-channel semantics: a single value repeats forever; a list is consumed in order and then fails fast with a named error. Used inside embedded stubs.

JavaScript/TypeScript:

```javascript
// Adapted from code Copyright 2023 Titanium I.T. LLC. MIT License.
export class ConfigurableResponses {
  // Array → different response each call, throws when exhausted.
  // Anything else → same response every call, never runs out.
  // 'name' appears in error messages.
  static create(responses, name) {
    return new ConfigurableResponses(responses, name);
  }

  // Convert every property of an object: { "/a": 1 } → { "/a": ConfigurableResponses }
  static mapObject(responseObject, name) {
    const entries = Object.entries(responseObject).map(([key, value]) => {
      const translatedName = name === undefined ? undefined : `${name}: ${key}`;
      return [key, ConfigurableResponses.create(value, translatedName)];
    });
    return Object.fromEntries(entries);
  }

  constructor(responses, name) {
    this._description = name === undefined ? "" : ` in ${name}`;
    this._responses = Array.isArray(responses) ? [...responses] : responses;
  }

  next() {
    const response = Array.isArray(this._responses)
      ? this._responses.shift()
      : this._responses;
    if (response === undefined) {
      throw new Error(`No more responses configured${this._description}`);
    }
    return response;
  }
}
```

Java idiom (iterator normalization):

```java
private static Iterator<Object> normalize(Object responses) {
    if (responses instanceof List) {
        return ((List<Object>) responses).iterator();       // in order, then hasNext() false
    }
    return Stream.generate(() -> responses).iterator();     // repeats forever
}

private Object next(String key, Iterator<Object> responses) {
    if (!responses.hasNext()) {
        throw new NoSuchElementException("No more responses configured for: " + key);
    }
    return responses.next();
}
```

Usage in a stub:

```javascript
class StubbedHttp {
  constructor(responses = {}) {
    this._responses = ConfigurableResponses.mapObject(responses, "nulled HTTP client");
  }
  request({ path }) {
    return new StubbedRequest(this._responses[path]?.next() ?? DEFAULT_NULLED_RESPONSE);
  }
}
```

## Rust (both utilities, one module)

One module, `src/nullable.rs`, holds both utilities and their unit tests. Unlike the versions above, it is not entirely production code. The tracker storage, `OutputTracker`, and `ConfigurableResponses` compile only under `cfg(any(test, feature = "test-util"))`, so in production `emit` compiles to nothing. [rust.md](rust.md) covers the gate, the `test-util` feature, and the wrapper pattern that uses this module. `OutputTracker::clear()` returns the writes seen so far and forgets them, as `clear()` does above.

This copy is the canonical one. When a project improves its copy, port the change back here with a test that shows it.

```rust
// Adapted from openring-rs src/nullable.rs (github.com/lukehsiao/openring-rs @ 2352ab0), Copyright Luke Hsiao. BlueOak-1.0.0.
//! Shared parts of the nullable infrastructure wrappers. A wrapper emits
//! each write it makes through an [`OutputListener`], so a test can track
//! what went out. Its embedded stub answers from `ConfigurableResponses`.
//!
//! Only test builds can track output or build a stub. A test build is the
//! crate's own unit tests, or any build with the `test-util` feature on. In
//! other builds an [`OutputListener`] holds nothing and emitting is free.

#[cfg(any(test, feature = "test-util"))]
use std::{
    collections::VecDeque,
    sync::{Arc, PoisonError, Weak},
};
use std::{fmt, marker::PhantomData, sync::Mutex};

/// The writes one tracker has seen. The tracker owns it, and the listener
/// holds only a weak reference, so a dropped tracker stops collecting.
#[cfg(any(test, feature = "test-util"))]
type Seen<T> = Mutex<Vec<T>>;

/// The write channel of a wrapper. The wrapper calls [`emit`] at each write,
/// in the code path that real and nulled instances share. Clones share
/// their trackers, so a tracker sees writes from every clone of a wrapper,
/// the way a real server sees requests from every clone of a client.
///
/// [`emit`]: OutputListener::emit
#[derive(Clone)]
pub struct OutputListener<T> {
    #[cfg(any(test, feature = "test-util"))]
    trackers: Arc<Mutex<Vec<Weak<Seen<T>>>>>,
    // A Mutex marker gives every build the auto traits of the test-only
    // field, so a type that is Send in production is also Send in tests.
    _data: PhantomData<Mutex<T>>,
}

impl<T> Default for OutputListener<T> {
    fn default() -> Self {
        Self {
            #[cfg(any(test, feature = "test-util"))]
            trackers: Arc::default(),
            _data: PhantomData,
        }
    }
}

impl<T> fmt::Debug for OutputListener<T> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("OutputListener").finish_non_exhaustive()
    }
}

impl<T: Clone> OutputListener<T> {
    /// Record one write. `data` runs only when a live tracker listens, so a
    /// write nobody tracks builds nothing.
    pub fn emit(&self, data: impl FnOnce() -> T) {
        #[cfg(any(test, feature = "test-util"))]
        {
            let mut trackers = self.trackers.lock().unwrap_or_else(PoisonError::into_inner);
            let live: Vec<Arc<Seen<T>>> = trackers.iter().filter_map(Weak::upgrade).collect();
            // A dropped tracker can never read again, so forget it.
            trackers.retain(|tracker| tracker.strong_count() > 0);
            drop(trackers);
            if live.is_empty() {
                return;
            }
            let data = data();
            for tracker in live {
                tracker
                    .lock()
                    .unwrap_or_else(PoisonError::into_inner)
                    .push(data.clone());
            }
        }
        #[cfg(not(any(test, feature = "test-util")))]
        let _ = (self, data);
    }

    /// Start recording writes. The tracker sees only writes made after this
    /// call, and stops recording when it is dropped.
    #[cfg(any(test, feature = "test-util"))]
    #[must_use]
    pub fn track(&self) -> OutputTracker<T> {
        let seen = Arc::new(Mutex::new(Vec::new()));
        self.trackers
            .lock()
            .unwrap_or_else(PoisonError::into_inner)
            .push(Arc::downgrade(&seen));
        OutputTracker { seen }
    }
}

/// The writes a wrapper made since a test started tracking it, in order.
#[cfg(any(test, feature = "test-util"))]
pub struct OutputTracker<T> {
    seen: Arc<Seen<T>>,
}

#[cfg(any(test, feature = "test-util"))]
impl<T> fmt::Debug for OutputTracker<T> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("OutputTracker").finish_non_exhaustive()
    }
}

#[cfg(any(test, feature = "test-util"))]
impl<T: Clone> OutputTracker<T> {
    /// The writes seen so far, oldest first.
    #[must_use]
    pub fn data(&self) -> Vec<T> {
        self.seen
            .lock()
            .unwrap_or_else(PoisonError::into_inner)
            .clone()
    }
}

#[cfg(any(test, feature = "test-util"))]
impl<T> OutputTracker<T> {
    /// Return the writes seen so far and forget them. The tracker keeps
    /// recording, so the next read sees only the writes made after this.
    pub fn clear(&self) -> Vec<T> {
        std::mem::take(&mut *self.seen.lock().unwrap_or_else(PoisonError::into_inner))
    }
}

/// Canned answers for an embedded stub. A single answer repeats forever. A
/// sequence is used up in order, and asking past its end panics with the
/// stub's name, so a test that asks too often fails instead of passing on
/// stale data.
#[cfg(any(test, feature = "test-util"))]
#[derive(Debug)]
pub enum ConfigurableResponses<T> {
    Repeat(T),
    Sequence(VecDeque<T>),
}

#[cfg(any(test, feature = "test-util"))]
impl<T: Clone> ConfigurableResponses<T> {
    /// The next answer. `name` identifies the stub in the panic message.
    ///
    /// # Panics
    ///
    /// Panics when a sequence has no answers left.
    pub fn next(&mut self, name: &str) -> T {
        match self {
            Self::Repeat(response) => response.clone(),
            Self::Sequence(responses) => responses
                .pop_front()
                .unwrap_or_else(|| panic!("No more responses configured for {name}")),
        }
    }
}

#[cfg(any(test, feature = "test-util"))]
impl<T> From<T> for ConfigurableResponses<T> {
    fn from(response: T) -> Self {
        Self::Repeat(response)
    }
}

#[cfg(any(test, feature = "test-util"))]
impl<T> From<Vec<T>> for ConfigurableResponses<T> {
    fn from(responses: Vec<T>) -> Self {
        Self::Sequence(responses.into())
    }
}

#[cfg(test)]
mod tests {
    use super::{ConfigurableResponses, OutputListener};

    #[test]
    fn a_tracker_sees_writes_made_after_it_starts_from_any_clone() {
        let listener = OutputListener::default();
        listener.emit(|| "before");
        let tracker = listener.track();
        listener.emit(|| "first");
        listener.clone().emit(|| "second");
        assert_eq!(tracker.data(), ["first", "second"]);
    }

    #[test]
    fn emitting_without_a_tracker_builds_nothing() {
        let listener = OutputListener::<&str>::default();
        listener.emit(|| panic!("built data nobody tracks"));
    }

    #[test]
    fn a_dropped_tracker_stops_collecting() {
        let listener = OutputListener::<&str>::default();
        drop(listener.track());
        listener.emit(|| panic!("built data for a dropped tracker"));
    }

    #[test]
    fn clearing_returns_the_writes_and_keeps_recording() {
        let listener = OutputListener::default();
        let tracker = listener.track();
        listener.emit(|| "first");
        assert_eq!(tracker.clear(), ["first"]);
        listener.emit(|| "second");
        assert_eq!(tracker.data(), ["second"]);
    }

    #[test]
    fn a_single_response_repeats() {
        let mut responses = ConfigurableResponses::from(7);
        assert_eq!([responses.next("x"), responses.next("x")], [7, 7]);
    }

    #[test]
    #[should_panic(expected = "No more responses configured for the test stub")]
    fn a_sequence_is_used_up_in_order_then_panics() {
        let mut responses = ConfigurableResponses::<i32>::from(vec![1, 2]);
        assert_eq!([responses.next("x"), responses.next("x")], [1, 2]);
        responses.next("the test stub");
    }
}
```
