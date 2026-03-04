# Installation and Usage Guide

## What's Included

This skill package contains 8 comprehensive markdown documents covering software design principles, plus supporting files:

- **SKILL.md** - Main skill description and overview
- **README.md** - Complete guide with quick references
- **01-complexity-management.md** - Core philosophy (4.4 KB)
- **02-deep-modules.md** - Interface design and abstraction (8.0 KB)
- **03-error-handling.md** - Eliminating exceptions (9.2 KB)
- **04-naming-obviousness.md** - Naming and code clarity (8.9 KB)
- **05-comments-documentation.md** - Effective documentation (11 KB)
- **06-general-purpose-design.md** - Flexible design patterns (13 KB)
- **07-design-process.md** - Design methodology (11 KB)
- **08-consistency-conventions.md** - Standards and conventions (9.9 KB)

**Total package size:** ~36 KB compressed, ~84 KB uncompressed

## Installation Options

### Option 1: Use as Reference Documentation
1. Extract the zip file to a convenient location
2. Keep the folder accessible while coding
3. Reference specific skills as needed

### Option 2: Integrate with IDE
Many IDEs support quick documentation access:
- Add to IDE bookmarks/favorites
- Create snippets with links to specific sections
- Use IDE markdown preview for quick reference

### Option 3: Team Knowledge Base
1. Add to team wiki or documentation system
2. Link from coding standards document
3. Reference in code review checklists
4. Use in onboarding materials

### Option 4: Print Reference
Print key sections for offline reference:
- Quick Reference sections from README
- Red Flags list
- Design Principles summary

## Quick Start

### First Time
1. Read `README.md` for complete overview
2. Study `01-complexity-management.md` for core philosophy
3. Skim other skills to understand what's available

### During Development
1. Reference specific skills when facing related decisions
2. Use Red Flags list during code reviews
3. Check Design Principles before major changes
4. Apply Examples to guide implementation

### Code Reviews
1. Keep Red Flags list handy
2. Reference specific skills when providing feedback
3. Use examples to illustrate improvements
4. Focus on teaching, not just critiquing

## How to Use Each Skill

Each skill document follows this structure:

1. **Core Principle** - Main concept in one sentence
2. **Detailed Explanation** - Why it matters and how it works
3. **When to Apply** - Specific situations to use this skill
4. **Examples** - BAD vs GOOD code comparisons
5. **Guidelines** - Step-by-step advice
6. **Red Flags** - Warning signs to watch for
7. **Benefits** - What you gain by applying this

### Reading Strategy

**For Learning:**
- Read skills 01-08 in order (they build on each other)
- Study the examples carefully
- Try to identify patterns in your own code

**For Reference:**
- Jump directly to relevant skill
- Scan the examples for quick guidance
- Check Red Flags section
- Review Guidelines for specific advice

**For Code Review:**
- Keep README Quick Reference open
- Look up specific red flags when you spot them
- Reference examples when suggesting improvements

## Integration with Workflow

### Daily Development
- Quick check: "Does this follow the principles?"
- Before commit: Scan Red Flags list
- When stuck: Review relevant skill
- During design: Apply "Design It Twice"

### Code Review Process
1. Check for red flags (use list from README)
2. Verify principles are followed
3. Reference specific skills in feedback
4. Provide examples from the skill docs

### Team Adoption
Week 1: Introduce complexity management and strategic programming
Week 2: Focus on deep modules and information hiding
Week 3: Cover error handling and special cases
Week 4: Emphasize naming and obviousness
Week 5: Improve documentation practices
Week 6: Apply general-purpose design patterns
Week 7: Refine design process
Week 8: Establish consistency conventions

### Measuring Success
Track these metrics:
- Time to add new features (should decrease)
- Time to fix bugs (should decrease)
- Code review time (should decrease after initial learning)
- Developer confidence (should increase)
- "What does this do?" questions (should decrease)

## Tips for Best Results

1. **Start Small** - Don't try to apply everything at once
2. **Focus on Principles** - Understand why, not just what
3. **Practice Recognition** - Learn to spot red flags in code
4. **Share Knowledge** - Discuss examples with team
5. **Be Patient** - Design skills improve with practice
6. **Measure Impact** - Track complexity and velocity
7. **Keep Accessible** - Make docs easy to reference
8. **Update Regularly** - Review and refresh your understanding

## Troubleshooting

**"Too much to remember"**
- Start with Red Flags list - use as checklist
- Focus on one skill per week
- Apply principles gradually

**"Examples don't match my language"**
- Concepts translate across languages
- Adapt patterns to your syntax
- Focus on principles, not syntax

**"Team isn't adopting"**
- Start with code reviews
- Lead by example
- Share specific examples from your code
- Celebrate improvements

**"When to apply which skill?"**
- See "When to Apply" in each skill
- README has integration guide
- If unsure, start with complexity management

## Support and Learning

### Additional Resources
- Original book: "A Philosophy of Software Design" by John Ousterhout
- CS 190 at Stanford (course materials)
- Related: "Clean Code," SOLID principles

### Practice Exercises
1. Review old code - identify red flags
2. Refactor a module using deep module principles
3. Eliminate exceptions in error-prone code
4. Rename variables using naming guidelines
5. Document an undocumented module properly

### Discussion Topics
- What red flags appear most in our code?
- Which principles would help most?
- Share refactoring success stories
- Review real examples from codebase

## File Structure
```
software-design-skills/
├── SKILL.md                          # Main skill description
├── README.md                         # Complete overview
├── INSTALLATION.md                   # This file
├── 01-complexity-management.md       # Core philosophy
├── 02-deep-modules.md               # Interface design
├── 03-error-handling.md             # Exception elimination
├── 04-naming-obviousness.md         # Code clarity
├── 05-comments-documentation.md     # Documentation
├── 06-general-purpose-design.md     # Flexible design
├── 07-design-process.md             # Methodology
└── 08-consistency-conventions.md    # Standards
```

## License and Attribution

These skills are derived from concepts in "A Philosophy of Software Design" by John Ousterhout, published by Yaknyam Press. They represent practical applications of the book's principles.

For the complete and authoritative treatment, refer to the original book.
