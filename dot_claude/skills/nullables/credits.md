Based on James Shore's "Testing Without Mocks" pattern language and training course:
- Article (canonical pattern text): https://www.jamesshore.com/v2/projects/nullables/testing-without-mocks
- Course: https://www.jamesshore.com/v2/courses/testing-without-mocks
- Example code: https://github.com/jamesshore/testing-without-mocks-example (simple),
  https://github.com/jamesshore/testing-without-mocks-complex (production-grade)

Java patterns from James Shore and Ted M. Young's collaborations:
- yacht-tdd — converting an existing Spring codebase to Nullables: https://github.com/jitterted/yacht-tdd

## Local modifications

Apache-2.0 section 4(b) notice: this copy diverges from the upstream
lexler/skill-factory version. On 2026-08-17, SKILL.md and every reference
file except utilities.md were revised against the 2023 article: new Fit and
tradeoffs, Quick diagnostic, and Pattern-name index sections; corrected
Paranoic Telemetry and speed claims; added rulings for vendor SDKs,
module-mock seams without an injection point, and hosted APIs that can't
run locally. The modifications are offered under the same Apache-2.0
license as the rest of this directory.

utilities.md contains code adapted from the article's MIT-licensed
examples (Copyright Titanium I.T. LLC and Ted M. Young); those notices
live in its code blocks.
