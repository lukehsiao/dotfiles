# Global Preferences

## Commenting

Never add organizational comments that are simply section headers.
These are just noise.
Only add comments that provide useful context, communicate why, and clarify intention.
Always comment with justification for magic numbers.
Always run comments through the humanizer skill first; there should be no emdashes.

## Version Control

- Always use `jj` (Jujutsu) instead of `git` for version control operations when available.
  - Use `jj` commands for log, diff, status, commit, rebase, etc.
  - Fall back to `git` only for operations that `jj` does not support (e.g., when `jj` is not installed).
  - load the jujutsu skill as necessary for additional context

Importantly, use the [squash workflow](https://steveklabnik.github.io/jujutsu-tutorial/real-world-workflows/the-squash-workflow.html).
That is, we should always be sitting on a new commit, and squashing into the one we are editing.

## Git Commit Style

Follow the Conventional Commits format:

```
type(scope): short description

Body explaining why.

Optional trailers.
```

### Format rules

- **Type**: `feat`, `fix`, `docs`, `refactor`, `chore`, `style`, `test`, `perf`, `ci`, `build`
- **Scope**: lowercase, specific and literal — a module, filename, or subsystem (e.g., `README`, `Justfile`, `n2k`, `docker`). Omit if too vague to add signal.
- **Description**: lowercase imperative, no trailing period, ≤72 chars.

### Body

Most commits need a body. The body is not a summary of what changed — the diff does that. The body answers: *why did this have to change, and why this way?*

**Start with the problem.** Not "I changed X to Y" but "X was wrong/broken/annoying because Z, so Y." The reader should understand the situation before they understand the fix.

**Own tradeoffs directly.** State the cost honestly: "Unfortunately, this raises the image size from 7.32GB to 10.2GB." If something is a judgment call or personal preference, say so: "This is a subjective organizational choice." If the motivation is self-serving, admit it: "The selfish motivation for this is..."

**Be specific.** Not "improved coverage" — "raises raymarine testing from 48% to 67%, and total coverage to 32%." Not "a broken dependency" — name it.

**Be tight.** One paragraph handles most commits. Two is the ceiling. A sentence that could be deleted should be deleted. Never write a sentence that restates something the diff already shows.

**Use prose, not bullets.** Numbered lists are acceptable only when there are genuinely parallel, distinct points that would tangle in prose. Don't use them to enumerate sub-changes.

"This patch..." and "This change..." are fine as sentence subjects. Prefer them over subjectless constructions or passive voice.

### Tone

Be direct. State opinions without hedging. "This is the wrong approach" is better than "this might potentially not be ideal." Confidence is not the same as arrogance — acknowledge when something is a guess, when you haven't tested something, or when the motivation is partly selfish. "Kind of concerning that this test does NOT fail with the existing testing flow, but going to fix-forward rather than invest the time to figure out why" is correct voice.

First person is fine and natural. Don't avoid it.

Always run the message through the humanizer skill.

### Tested section

For anything with non-trivial runtime behavior — Docker images, CI changes, deployed code — include a `Tested:` block with the actual commands run and what was verified. Use real terminal output when it's short and informative. Be honest when something wasn't tested: "NOT TESTED. A downside of GitHub Actions is that there's no way to test a new workflow on a branch before it hits main." is correct and acceptable.

### Trailers

Use trailers for cross-references. Keep them out of the body.

```
Fixes: <sha> ("<subject>")
Ref: <url>
Closes: <issue url>
Inspired-by: <url>
```

When AI tools contribute development, proper attribution helps track the evolving role of AI in the development process.
Contributions should include an Assisted-by tag in the following format:

```
Assisted-by: AGENT_NAME:MODEL_VERSION [TOOL1] [TOOL2]
```

Where:

`AGENT_NAME` is the name of the AI tool or framework

`MODEL_VERSION` is the specific model version used

`[TOOL1] [TOOL2]` are optional specialized analysis tools used (e.g., `coccinelle`, `sparse`, `smatch`, `clang-tidy`)

Basic development tools (git, gcc, make, editors) should not be listed.

Example:

```
Assisted-by: Claude:claude-3-opus coccinelle sparse
```

### Special prefixes

- `wip:` — work in progress, not ready for review
- `private:` — personal/local only, not for shared branches
