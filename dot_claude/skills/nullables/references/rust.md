# Nullables in Rust

How to build Nullables in Rust so production pays nothing for them. The rules in [SKILL.md](../SKILL.md) and the wrapper guides still apply. This file covers only what Rust changes.

## Contents

- The gate
- The seam: an enum, not a trait
- Factories and trackers
- Pushed events
- The shared module
- The cost of the gate
- Complete example

## The gate

Everything that exists only for tests sits behind one `cfg`:

```rust
#[cfg(any(test, feature = "test-util"))]
```

That covers the stub arm of the seam, the stub module, `create_null`, every `track_*` and `simulate_*` method, and the tracker storage inside `OutputListener`. A production build compiles none of it.

Declare the feature in every crate that uses the pattern, even when only unit tests need it. The declaration also keeps the `unexpected_cfgs` lint quiet.

```toml
[features]
test-util = []
```

`cfg(test)` is on only while the crate compiles its own unit tests. Integration tests in `tests/` and doctests link the library as an external crate, so `cfg(test)` is off for it there. Turn the feature on for them with a dev-dependency of the crate on itself:

```toml
[dev-dependencies]
mycrate = { path = ".", features = ["test-util"] }
```

Another crate in the workspace that needs the nulled wrapper turns the feature on in its own dev-dependency: `mycrate = { path = "../mycrate", features = ["test-util"] }`. Do not use `[[test]] required-features` for this. A bare `cargo test` then skips those tests and says nothing.

`cargo clippy --all-targets` turns `test-util` on for the library through that dev-dependency, so it never lints the production build. Also run `cargo clippy --lib`, which builds the library without the gated code.

Code outside the crate can call only `pub` items. Make a wrapper `pub` when integration tests or other crates use it. Keep the shared module private (`mod nullable;`), and re-export `OutputTracker` from the crate root behind the gate. Then a test helper outside the crate can name the tracker type, for example in the struct it returns:

```rust
#[cfg(any(test, feature = "test-util"))]
pub use nullable::OutputTracker;
```

## The seam: an enum, not a trait

This is the Thin Wrapper seam from [building-low-level-wrappers-static.md](building-low-level-wrappers-static.md), written in Rust. The wrapper holds a private enum with a `Real` arm and a gated `Stubbed` arm:

```rust
// The seam. Each arm mirrors only the std::fs calls this wrapper makes,
// and the real arm only forwards to std::fs.
#[derive(Debug, Clone)]
enum Disk {
    Real,
    #[cfg(any(test, feature = "test-util"))]
    Stubbed(stub::Files),
}
```

- Each method on the enum mirrors one third-party call the wrapper makes, and only those calls.
- The `Real` arm only forwards. It holds no logic, so it has nothing to get wrong.
- The `Stubbed` arm answers from the stub, which lives in a gated private module.
- Wrapper logic sits above the `match`, in code that both arms share, so nulled tests run it.

Do not write a trait for the seam. A `Box<dyn Backend>` adds dynamic dispatch and an allocation, and an `async fn` in a `dyn` trait needs its futures boxed. A generic `Fs<B: Backend>` pushes the type parameter into every type above the cut, so callers learn about the stub and parameterless instantiation breaks. The enum is a closed set of two arms with static dispatch, and its gated arm does not exist in production. For the same reason, do not write a `Nullable` trait for the factories: no code calls them generically, and their arguments differ from wrapper to wrapper.

## Factories and trackers

- `create()` is always compiled. `create_null(...)` and the `track_*()` methods sit in a separate `impl` block behind the gate.
- Rust has no default arguments, so the bare form of `create_null` must still be one call. Take the configuration as one `impl IntoIterator` with a concrete item type, or as a config struct that implements `Default`. Then `create_null([])` or `create_null(Config::default())` always works. A generic item type breaks type inference for an empty `[]`.
- Call `emit` at each write, in the code that both arms share. `emit` takes a closure, so a write that no tracker listens to builds nothing, and in production `emit` compiles to nothing.
- Track domain data (a `Write { path, contents }` struct), not the rendered bytes.
- A read whose answer changes from call to call keeps a `ConfigurableResponses` for each key in the stub. Hold them in an `Arc<Mutex<…>>`, so that `&self` methods can advance them and clones of the wrapper share one sequence. The example below does this.

## Pushed events

Extract the body of the real listener into a private handler, and have each `simulate_*` method call that handler. Put `simulate_*` behind the gate unless production code calls it. Production then carries no test-only methods. For a wrapper that the crate does not export, the gate also keeps the `dead_code` lint quiet.

## The shared module

Copy the Rust section of [utilities.md](utilities.md) into `src/nullable.rs` and declare it with `mod nullable;`. Copy only the parts your wrappers use. An unused part trips `dead_code` in `test-util` builds.

The copy in `utilities.md` is the canonical one. When a project improves its copy, port the change back to `utilities.md` together with a test that shows the change.

## The cost of the gate

The gate means production can never build a nulled instance. So a feature like `--dry-run` cannot run on nulled infrastructure, which the general pattern allows. When production needs a nulled instance, remove the gate from that wrapper's stub arm, its stub module, and its `create_null`, and from the parts of the shared module they use.

## Complete example

A file-system wrapper, with a read channel that repeats one answer or uses up a sequence, a tracked write channel, and its unit tests. `src/lib.rs` declares the modules and re-exports the tracker:

```rust
pub mod fs;
mod nullable;

#[cfg(any(test, feature = "test-util"))]
pub use nullable::OutputTracker;
```

`src/fs.rs`:

```rust
//! The file system edge. `Fs::create_null` swaps the disk for files held
//! in memory, so the code above it runs in tests without touching the disk.

use std::{
    io,
    path::{Path, PathBuf},
};

use crate::nullable::OutputListener;
#[cfg(any(test, feature = "test-util"))]
use crate::nullable::{ConfigurableResponses, OutputTracker};

/// One write the code made, as the data it wrote.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Write {
    pub path: PathBuf,
    pub contents: String,
}

#[derive(Debug, Clone)]
pub struct Fs {
    disk: Disk,
    writes: OutputListener<Write>,
}

impl Fs {
    #[must_use]
    pub fn create() -> Self {
        Self {
            disk: Disk::Real,
            writes: OutputListener::default(),
        }
    }

    /// # Errors
    ///
    /// Returns the error the file system reports.
    pub fn read(&self, path: &Path) -> io::Result<String> {
        self.disk.read_to_string(path)
    }

    /// # Errors
    ///
    /// Returns the error the file system reports.
    pub fn write(&self, path: &Path, contents: &str) -> io::Result<()> {
        self.disk.write(path, contents)?;
        self.writes.emit(|| Write {
            path: path.to_owned(),
            contents: contents.to_owned(),
        });
        Ok(())
    }
}

// The seam. Each arm mirrors only the std::fs calls this wrapper makes,
// and the real arm only forwards to std::fs.
#[derive(Debug, Clone)]
enum Disk {
    Real,
    #[cfg(any(test, feature = "test-util"))]
    Stubbed(stub::Files),
}

impl Disk {
    fn read_to_string(&self, path: &Path) -> io::Result<String> {
        match self {
            Self::Real => std::fs::read_to_string(path),
            #[cfg(any(test, feature = "test-util"))]
            Self::Stubbed(files) => files.read_to_string(path),
        }
    }

    fn write(&self, path: &Path, contents: &str) -> io::Result<()> {
        match self {
            Self::Real => std::fs::write(path, contents),
            #[cfg(any(test, feature = "test-util"))]
            Self::Stubbed(_) => Ok(()),
        }
    }
}

#[cfg(any(test, feature = "test-util"))]
impl Fs {
    /// Files held in memory, as (path, answers) pairs. One answer repeats
    /// on every read. A `Vec` of answers is used up in order, then the
    /// next read panics. A path with no entry reads as not found, so
    /// `Fs::create_null([])` is an empty disk.
    pub fn create_null<'a>(
        files: impl IntoIterator<Item = (&'a str, ConfigurableResponses<String>)>,
    ) -> Self {
        Self {
            disk: Disk::Stubbed(stub::Files::new(files)),
            writes: OutputListener::default(),
        }
    }

    /// Record every write made from now on, through any clone.
    #[must_use]
    pub fn track_writes(&self) -> OutputTracker<Write> {
        self.writes.track()
    }
}

#[cfg(any(test, feature = "test-util"))]
mod stub {
    use std::{
        collections::HashMap,
        io,
        path::{Path, PathBuf},
        sync::{Arc, Mutex, PoisonError},
    };

    use crate::nullable::ConfigurableResponses;

    // Clones of a nulled Fs share one set of answers, so a sequence is
    // used up across all of them.
    #[derive(Debug, Clone)]
    pub(super) struct Files(Arc<Mutex<HashMap<PathBuf, ConfigurableResponses<String>>>>);

    impl Files {
        pub(super) fn new<'a>(
            files: impl IntoIterator<Item = (&'a str, ConfigurableResponses<String>)>,
        ) -> Self {
            let files = files
                .into_iter()
                .map(|(path, answers)| (path.into(), answers))
                .collect();
            Self(Arc::new(Mutex::new(files)))
        }

        pub(super) fn read_to_string(&self, path: &Path) -> io::Result<String> {
            let mut files = self.0.lock().unwrap_or_else(PoisonError::into_inner);
            let answers = files.get_mut(path).ok_or_else(|| {
                io::Error::new(
                    io::ErrorKind::NotFound,
                    format!("Nulled Fs: no file configured at {}", path.display()),
                )
            })?;
            Ok(answers.next(&format!("Nulled Fs: {}", path.display())))
        }
    }
}

#[cfg(test)]
mod tests {
    use std::{io, path::Path};

    use super::{Fs, Write};

    #[test]
    fn a_nulled_read_answers_from_memory() {
        let fs = Fs::create_null([("/etc/motd", "hello".to_owned().into())]);
        assert_eq!(fs.read(Path::new("/etc/motd")).unwrap(), "hello");
        assert_eq!(fs.read(Path::new("/etc/motd")).unwrap(), "hello");
    }

    #[test]
    #[should_panic(expected = "No more responses configured for Nulled Fs: /etc/motd")]
    fn a_sequence_of_reads_is_used_up_then_fails_loudly() {
        let answers = vec!["first".to_owned(), "second".to_owned()];
        let fs = Fs::create_null([("/etc/motd", answers.into())]);
        assert_eq!(fs.read(Path::new("/etc/motd")).unwrap(), "first");
        assert_eq!(fs.clone().read(Path::new("/etc/motd")).unwrap(), "second");
        let _ = fs.read(Path::new("/etc/motd"));
    }

    #[test]
    fn an_unconfigured_path_reads_as_not_found() {
        let fs = Fs::create_null([]);
        let error = fs.read(Path::new("/missing")).unwrap_err();
        assert_eq!(error.kind(), io::ErrorKind::NotFound);
    }

    #[test]
    fn a_tracker_sees_writes_that_never_reach_the_disk() {
        let fs = Fs::create_null([]);
        let writes = fs.track_writes();
        fs.write(Path::new("/tmp/out"), "data").unwrap();
        assert_eq!(
            writes.data(),
            [Write {
                path: "/tmp/out".into(),
                contents: "data".into()
            }]
        );
        assert!(fs.read(Path::new("/tmp/out")).is_err());
    }
}
```

An integration test in `tests/` uses the same factory, through the dev-dependency on the crate itself. Its helper names `OutputTracker` through the re-export:

```rust
use std::path::Path;

use mycrate::{
    OutputTracker,
    fs::{Fs, Write},
};

struct Nulled {
    fs: Fs,
    writes: OutputTracker<Write>,
}

fn nulled() -> Nulled {
    let fs = Fs::create_null([]);
    let writes = fs.track_writes();
    Nulled { fs, writes }
}

#[test]
fn an_integration_test_can_null_the_disk() {
    let Nulled { fs, writes } = nulled();
    fs.write(Path::new("/x"), "y").unwrap();
    assert_eq!(
        writes.data(),
        [Write {
            path: "/x".into(),
            contents: "y".into()
        }]
    );
}
```
