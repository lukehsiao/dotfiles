---
name: jujutsu
description: This document instructs Claude Code to use `jj` (Jujutsu) instead of `git` for version control operations. jj is a Git-compatible VCS that provides a simpler mental model and powerful history editing.
---

# Jujutsu (jj) Usage Guide for Claude Code

This document instructs Claude Code to use `jj` (Jujutsu) instead of `git` for version control operations. jj is a Git-compatible VCS that provides a simpler mental model and powerful history editing.

## Core Concepts

### Key Differences from Git

1. **No staging area** - Every change is automatically part of the working copy commit
2. **Working copy is a commit** - The `@` symbol represents your current working copy commit
3. **Anonymous branches** - Commits don't need branch names; use "bookmarks" when needed for pushing
4. **Conflicts are values** - Conflicts don't block operations; they're tracked and can be resolved later
5. **Automatic rebasing** - Descendant commits automatically rebase when you modify history

### Terminology Mapping

| Git | jj |
| --- | --- |
| `branch` | `bookmark` |
| `HEAD` | `@` (working copy) |
| `checkout` | `edit` or `new` |
| `stash` | Not needed (just create new commits) |
| `staging/index` | Not applicable |
| `commit --amend` | Just edit, changes auto-apply to `@` |

## Common Operations

### Viewing State

```
# Show current status (like git status)
jj status
jj st              # short form

# Show commit log (like git log --graph)
jj log
jj log -r 'all()'  # show all commits

# Show diff of working copy
jj diff --git

# Show diff of specific commit
jj diff --git -r <commit>

# Show commit details
jj show <commit>
```

### Creating Commits

```
# Describe the current working copy commit
jj describe -m "feat: add new feature"
jj desc -m "feat: add new feature"  # short form

# Create a new empty commit on top of current
jj new
jj new -m "feat: starting new work"  # with message

# Create new commit on top of specific commit
jj new <commit>
jj new main        # new commit based on main
```

### Editing History

```
# Edit an existing commit (moves @ to that commit)
jj edit <commit>

# Squash current commit into parent
jj squash -m "combined message"

# Squash specific commit into its parent
jj squash -r <commit> -m "combined message"

# Squash specific paths from one commit into another (no editor)
jj squash --from <src> --into <dst> <paths>

# Restore specific paths to the state at another commit
jj restore --from <rev> <paths>

# Split a commit by file paths (no editor, see "Avoiding Interactive Editors")
jj split <path>...

# Absorb changes into appropriate ancestor commits
jj absorb

# Rebase commits
jj rebase -r <commit> -d <destination>      # single commit
jj rebase -s <commit> -d <destination>      # commit and descendants
jj rebase -b <commit> -d <destination>      # whole branch
```

### Working with Bookmarks (Branches)

```
# List bookmarks
jj bookmark list

# Create a bookmark at current commit
jj bookmark create <n>
jj bookmark create <n> -r <commit>  # at specific commit

# Move a bookmark to current commit
jj bookmark set <n>

# Delete a bookmark
jj bookmark delete <n>

# Track a remote bookmark
jj bookmark track <n>@origin
```

### Remote Operations

```
# Fetch from remote
jj git fetch
jj git fetch --remote origin

# Push bookmark to remote
jj git push --bookmark <n>
jj git push -b <n>  # short form

# Push current commit's bookmark
jj git push

# Create and push in one step (if bookmark exists)
jj bookmark set feature-x && jj git push -b feature-x
```

### Handling Conflicts

```
# Conflicts don't block operations - check for them
jj log -r 'conflicts()'

# Resolve conflicts in working copy
# Just edit the files, remove conflict markers, save

# After resolving, the commit auto-updates
jj status  # verify resolved
```

### Undo and Recovery

```
# Show operation log
jj op log

# Undo last operation
jj op undo

# Restore to specific operation
jj op restore <operation-id>
```

## Workflow Patterns

### Starting New Work

When starting substantial new work (feature, bug fix, refactor), create a new commit first:

```
# Start new work from main
jj new main -m "feat: description of the work"

# Or start from current position
jj new -m "fix: description of the fix"
```

This keeps changes isolated and makes it easier to:

* Understand what changed for a specific piece of work
* Review changes before merging
* Revert or modify specific work without affecting other changes

### Making Changes

The cheapest way to get atomic commits is to create them as you go, not
to split a sprawling working copy afterward. Between logical steps, run
`jj new`:

```
# start work with a description already in place
jj new -m "refactor: extract auth helper"
# ...edit files...

# move on to the next logical step
jj new -m "feat: use auth helper in login flow"
# ...edit files...

# and the next
jj new -m "test: cover auth helper edge cases"
```

If the description needs updating later:

```
jj describe -m "refactor: extract auth helper from login module"
```

If two adjacent commits turn out to be one logical change after all:

```
jj squash -m "combined message"
```

### Cleaning Up Before Push

```
# Squash fixup commits into their parents
jj squash -r <fixup-commit>

# Or use absorb to automatically distribute changes
jj absorb
# Note: absorb only moves hunks into ancestor commits that already
# touch the same lines. It won't create new commits; if you have
# mixed unrelated changes in @, split them first.

# Rebase onto latest main
jj git fetch
jj rebase -d main
```

### Creating a Pull Request

```
# Ensure bookmark exists
jj bookmark create my-feature

# Push to remote
jj git push -b my-feature

# Or push and create bookmark tracking
jj git push --bookmark my-feature
```

### Updating a PR After Review

```
# Edit the commit that needs changes
jj edit <commit>

# Make changes (they apply directly)
# Descendants auto-rebase

# Return to working on tip
jj new <tip-commit>

# Force push updated bookmark
jj git push -b my-feature
```

## Best Practices

### Commit Messages

* Use conventional commits: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`
* Describe the commit when the work is complete, not at the start
* Use `jj describe` to update messages as work evolves

### History Hygiene

* Use `jj squash` to combine WIP commits before pushing
* Use `jj absorb` to fold review feedback into original commits
* Keep commits atomic and focused

### Bookmark Naming

When pushing to GitHub, use descriptive bookmark names:

```
jj bookmark create fix/issue-123-auth-bug
jj bookmark create feat/user-dashboard
jj bookmark create claude/<feature>-<session-id>  # for Claude Code sessions
```

### Before Push Checklist

```
# 1. Check for conflicts
jj log -r 'conflicts()'

# 2. Ensure clean status
jj status

# 3. Rebase onto latest main
jj git fetch && jj rebase -d main

# 4. Review changes
jj log -r '::@ ~ ::main'

# 5. Push
jj git push -b <bookmark>
```

## Coexistence with Git

jj can coexist with git in the same repository:

```
# Initialize jj in existing git repo
jj git init --colocate

# jj and git now share the same .git directory
# You can use either tool, but prefer jj for day-to-day work
```

When colocated:

* `jj git fetch` updates both jj and git refs
* `jj git push` pushes via git
* git commands still work if needed for edge cases

## Avoiding Interactive Editors

jj commands like `squash`, `describe`, `commit`, and `split` open an
interactive editor by default. Since LLMs cannot drive TUIs, always use
the non-interactive forms:

* **Commit messages inline**: always pass `-m "message"` to `describe`,
  `squash`, `commit`, `new`.
* **Squash without editor**: `jj squash -m "message"` or
  `jj squash --into <rev> -m "message"`.
* **Squash specific paths only**: `jj squash --from <src> --into <dst> <paths>`
  moves only the named files, no editor involved.
* **Restore specific paths**: `jj restore --from <rev> <paths>` pulls paths
  back to the state at `<rev>`, useful for peeling changes off a commit.

### Splitting commits non-interactively

`jj split` *can* be used non-interactively — don't avoid it, just use the
right invocation:

* **File-based split** (preferred): `jj split <path>...` moves the listed
  paths into the first commit and leaves everything else in the second.
  No editor opens. Use this whenever atomic boundaries align with files.
* **Parallel split**: add `--parallel` if the two halves should be
  siblings rather than stacked.
* **Messages inline**: add `-m "first" -m "second"` to set both commit
  descriptions without prompting.

Example:

```
jj split -m "refactor: extract helper" -m "feat: use helper in X" \
    src/helper.rs
```

### When file-based split isn't enough

For hunk-level splits within a single file, prefer one of these patterns
over trying to drive the interactive TUI:

1. **Split before you mess up** — the best strategy. Between logical
   steps, run `jj new -m "next thing"`. You end up with atomic commits
   by construction and never need `split`.

2. **Compose with `squash`/`restore`**:

   ```
   jj new              # empty change on top
   # edit files to the desired state of part A
   jj squash --from <original> --into @ <paths-for-A>
   # the original commit now contains only part B
   ```

3. **Patch round-trip** (last resort, fully scriptable):

   ```
   jj diff -r <rev> --git > /tmp/full.patch
   # split the patch into partial.patch and rest.patch
   jj restore -r <rev>
   jj new -r <rev>-
   git apply /tmp/partial.patch && jj commit -m "part A"
   git apply /tmp/rest.patch     && jj commit -m "part B"
   ```

## Command Quick Reference

| Action | Command |
| --- | --- |
| Status | `jj st` |
| Log | `jj log` |
| Diff | `jj diff --git` |
| Describe commit | `jj desc -m "message"` |
| New commit | `jj new` |
| Edit old commit | `jj edit <rev>` |
| Squash into parent | `jj squash -m <message>` |
| Squash paths | `jj squash --from <src> --into <dst> <paths>` |
| Split by file | `jj split <path>...` |
| Rebase | `jj rebase -d <dest>` |
| Create bookmark | `jj bookmark create <n>` |
| Fetch | `jj git fetch` |
| Push | `jj git push -b <n>` |
| Undo | `jj op undo` |

## Error Recovery

If something goes wrong:

```
# See what happened
jj op log

# Undo the last operation
jj op undo

# Or restore to a known good state
jj op restore <operation-id>
```

jj's operation log means you can always recover from mistakes - nothing is ever truly lost.
