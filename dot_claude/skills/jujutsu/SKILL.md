---
name: jujutsu
description: Use `jj` (Jujutsu) instead of `git` for version control operations. Covers the squash workflow, revsets, bookmarks, Git interop, conflict handling, and history editing. Written against jj 0.44; verify unfamiliar flags with `jj help <command>` on older installs.
---

# Jujutsu (jj)

Prefer `jj` over `git` for all version control operations in repositories that
contain a `.jj/` directory. Verify with `jj root` or by checking for `.jj/` at
the repo root. Fall back to `git` only when `jj` is unavailable.

## Mental Model

Four facts explain most of jj's behavior:

1. **The working copy is a commit.** `@` denotes it. Every jj command first
   snapshots the working copy, so there is no staging area, no stash, and no
   "untracked changes" state. Your edits are already in a commit.
2. **Change IDs vs commit IDs.** A *change ID* (letters k-z, e.g. `sxlszowu`)
   is stable across rewrites; a *commit ID* (hex) changes on every rewrite.
   Address work by change ID.
3. **Descendants rebase automatically.** Rewriting a commit (describe, squash,
   diffedit) rebases everything on top of it. No manual `rebase --onto` chains.
4. **Conflicts are values, not emergencies.** A rebase or squash that
   conflicts still succeeds; the conflict is recorded inside the commit and can
   be resolved whenever convenient.

Every operation is recorded in the operation log, so any mistake is
recoverable with `jj undo` or `jj op restore`.

## The Squash Workflow (preferred)

Always sit on a fresh, empty `@` and fold finished work into the commit below.
This keeps `@` as a scratch pad and the parent as the commit being built.

```sh
jj new                       # start: empty working-copy commit on top
jj describe @- -m "feat(x): add thing"   # describe the commit being built
# ... edit files; changes land in @ automatically ...
jj squash                    # fold all of @ into @-
jj squash path/to/file       # or fold only some paths
jj squash -i                 # or pick hunks interactively
```

After `jj squash` empties `@`, jj abandons it and gives you a new empty one;
the loop continues. To build several commits at once from mixed edits, use
`jj absorb`, which routes each hunk to the closest mutable ancestor that last
touched those lines.

`jj commit -m "..."` (describe `@` + `jj new`) is the shortcut when you want
the conventional "make a commit now" motion instead.

## Everyday Commands

```sh
jj st                        # status: what changed in @
jj diff                      # diff of @ against its parent
jj diff -r <rev>             # diff of any revision
jj log                       # graph of interesting commits
jj log -r ::@                # ancestors of the working copy
jj show <rev>                # metadata + diff of one revision
jj new <rev>                 # new empty commit on top of <rev>, edit it
jj edit <rev>                # make <rev> itself the working copy
jj describe -m "..."         # set @'s description ( -r for others )
jj abandon <rev>             # drop a revision; descendants rebase onto its parent
jj restore --from <rev> <path>   # copy paths from another revision into @
jj file list / show / annotate / track / untrack
```

## Editing History

```sh
jj squash --from <rev> --into <rev>   # move changes between arbitrary revisions
jj split                     # split @ (or -r <rev>) into two commits, interactively
jj rebase -r <rev> -d <dest> # move one revision
jj rebase -s <rev> -d <dest> # move a revision and all its descendants
jj rebase -b <rev> -d <dest> # move the whole branch of commits
jj diffedit -r <rev>         # edit the content changes of any revision
jj duplicate <rev>           # copy a revision without moving it
jj parallelize <revs>        # turn a stack of commits into siblings
jj revert -r <rev> --onto @  # new commit undoing <rev>, placed on top of @
```

Commits reachable from remote/trunk are **immutable** by default; jj refuses
to rewrite them. Do not reach for `--ignore-immutable` unless the user asks.

## Bookmarks (jj's branch pointers)

Bookmarks are named pointers used mainly for pushing. They do not move on
their own when you create new commits; advance them explicitly.

```sh
jj bookmark list             # alias: jj b l
jj bookmark set main -r @-   # create or move 'main' to @'s parent
jj bookmark move main --to @-
jj bookmark advance main     # hop the nearest bookmark forward (alias: jj b a)
jj bookmark track main@origin
jj bookmark delete <name>    # deletes on remote at next push
jj bookmark forget <name>    # local forget, no remote deletion
```

Older docs say `jj branch ...`; that command is now `jj bookmark`.

## Git Interop

```sh
jj git clone <url> [--colocate]
jj git init --colocate       # adopt an existing Git checkout
jj git fetch                 # update remote-tracking bookmarks
jj git push                  # push tracking bookmarks in remote..@
jj git push -b <name>        # push one bookmark
jj git push -c @-            # create+push an auto-named bookmark for a change
jj git push --named feat-x=@-   # create+push a bookmark with a chosen name
jj git push --dry-run        # preview what would change on the remote
```

Pushes are force-with-lease style: the remote is only updated if it still
matches what jj last fetched. In colocated repos, plain `git` commands still
work and jj imports/exports refs automatically on each command.

## Revsets

Revsets select commits. Common building blocks:

```
@        working copy          @-       its parent       @--   grandparent
x-       parents of x          x+       children of x
::x      ancestors of x        x::      descendants      x..y  y's ancestors not x's
trunk()  main/master on remote           mine()      commits I authored
bookmarks([pat])  remote_bookmarks()     tags()
empty()  no file changes       conflicts()  commits with unresolved conflicts
heads(x) latest(x, n)          description(pat)  subject(pat)
mutable() / immutable()        root()  the virtual root commit
```

Examples:

```sh
jj log -r 'trunk()..@'                   # my current stack
jj log -r 'mine() & description(glob:"wip*")'
jj abandon 'empty() ~ @'                 # drop stray empty commits
```

## Conflicts

Conflicted commits show up in `jj st` and `jj log` with a conflict marker.
Descendants of a conflicted commit inherit the conflict until it is resolved.

```sh
jj resolve                   # run the configured merge tool on @'s conflicts
jj resolve --list            # list conflicted files
# or: edit the conflict markers in the files directly, then check jj st
```

Resolving in one commit automatically propagates through descendants.

## Recovery

```sh
jj undo                      # undo the last operation
jj redo                      # redo an undone operation
jj op log                    # every repo mutation, with IDs
jj op restore <op-id>        # reset the whole repo to that point
jj op show -p                # inspect what the last operation did
jj evolog -r <rev>           # how one change evolved across rewrites
```

Nothing is lost until the operation log is garbage-collected; prefer
`jj op restore` over manual repair.

## Agent Guidance

- Snapshotting is implicit: never look for `git add`, `git stash`, or a dirty
  working tree. `jj st` after edits confirms what will be squashed.
- Use change IDs from `jj log` output when targeting revisions; commit IDs go
  stale after every rewrite.
- Before pushing, `jj git push --dry-run` shows exactly which bookmarks move.
- Destructive-looking commands (`abandon`, `rebase`, `squash`) are safe to
  attempt: `jj undo` reverses them. Still, prefer asking before abandoning
  work you did not create.
