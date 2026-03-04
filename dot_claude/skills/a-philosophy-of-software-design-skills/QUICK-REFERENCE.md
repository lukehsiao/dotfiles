# Quick Reference Card

## Red Flags (Signs of Complexity)

🚩 **Shallow Module** - Interface not much simpler than implementation  
🚩 **Information Leakage** - Design decision reflected in multiple modules  
🚩 **Temporal Decomposition** - Structure based on execution order  
🚩 **Pass-Through Method** - Just calls another method with same signature  
🚩 **Repetition** - Same code in multiple places  
🚩 **Special-General Mixture** - Special cases not separated  
🚩 **Comment Repeats Code** - Comment obvious from code  
🚩 **Vague Name** - Name too generic to convey meaning  
🚩 **Hard to Describe** - Long documentation required  
🚩 **Nonobvious Code** - Can't understand with quick read  

## Design Principles (Quick Checklist)

✓ **Complexity is incremental** - Sweat the small stuff  
✓ **Working code isn't enough** - Design quality matters  
✓ **Invest 10-20% in design** - Make continual small improvements  
✓ **Modules should be deep** - Simple interface, powerful implementation  
✓ **Optimize for common usage** - Make typical cases simple  
✓ **Simple interface > simple implementation** - Hide complexity  
✓ **General-purpose is deeper** - Don't be too specific  
✓ **Separate general/special code** - Clear boundaries  
✓ **Different layers, different abstractions** - Add value per layer  
✓ **Pull complexity downward** - Hide in implementation  
✓ **Define errors out** - Design so errors can't occur  
✓ **Design it twice** - Consider alternatives  
✓ **Comments describe non-obvious** - Different level than code  
✓ **Design for reading** - Not for writing  
✓ **Increments are abstractions** - Not features  

## Before You Code

```
1. Write interface comment first
2. What's the simplest interface?
3. Can I eliminate special cases?
4. Have I considered alternatives?
5. Is this obvious to readers?
```

## Before You Commit

```
1. Scan for red flags
2. Update all comments
3. Check naming consistency
4. Review error handling
5. Can anything be simpler?
```

## Code Review Checklist

**Complexity:**
- [ ] Does this reduce overall complexity?
- [ ] Are dependencies minimized?
- [ ] Is behavior obvious?

**Abstraction:**
- [ ] Is interface simple and powerful?
- [ ] Are implementation details hidden?
- [ ] Is this deep or shallow?

**Errors:**
- [ ] Can exceptions be eliminated?
- [ ] Are special cases necessary?
- [ ] Could this be defined to always work?

**Names:**
- [ ] Are names precise and meaningful?
- [ ] Is naming consistent?
- [ ] Do booleans use predicates?

**Comments:**
- [ ] Do comments add information?
- [ ] Is interface documented?
- [ ] Are non-obvious aspects explained?

## When to Apply Which Skill

| Situation | Primary Skill | Also Consider |
|-----------|--------------|---------------|
| Designing new class | 02-Deep Modules | 07-Design Process |
| Handling errors | 03-Error Handling | 01-Complexity |
| Naming variables | 04-Naming | 08-Consistency |
| Writing docs | 05-Documentation | 02-Deep Modules |
| API design | 06-General-Purpose | 02-Deep Modules |
| Refactoring | 07-Design Process | 01-Complexity |
| Code review | All (use red flags) | 08-Consistency |
| Team standards | 08-Consistency | 01-Complexity |

## Emergency Guide

**"Code is too complex!"**
→ Check 01-Complexity Management
→ Look for red flags
→ Apply strategic refactoring

**"Interface is confusing!"**
→ Check 02-Deep Modules
→ Hide more implementation details
→ Simplify parameter list

**"Too many exceptions!"**
→ Check 03-Error Handling
→ Define errors out of existence
→ Use defaults

**"Code is unclear!"**
→ Check 04-Naming Obviousness
→ Improve names
→ Add strategic comments

**"Undocumented code!"**
→ Check 05-Documentation
→ Write interface comments
→ Explain non-obvious aspects

**"Too specific/inflexible!"**
→ Check 06-General-Purpose
→ Make somewhat general
→ Eliminate special cases

**"Poor design!"**
→ Check 07-Design Process
→ Design it twice
→ Write comments first

**"Inconsistent code!"**
→ Check 08-Consistency
→ Follow existing patterns
→ Establish conventions

## Quick Wins

**Immediate Impact:**
1. Write interface comments for undocumented public methods
2. Rename vague variables (data, info, result, etc.)
3. Eliminate one special case from error handling
4. Combine shallow pass-through methods
5. Add precision to variable comments (units, boundaries)

**This Week:**
1. Apply "design it twice" to one feature
2. Refactor one module to be deeper
3. Define one error out of existence
4. Establish one naming convention
5. Document one cross-module decision

**This Month:**
1. Review all public interfaces for depth
2. Eliminate all pass-through methods
3. Establish team coding standards
4. Create documentation for key abstractions
5. Reduce exception count by 50%

## Measuring Success

**Good Signs:**
- Features faster to add
- Bugs easier to fix
- Code reviews shorter
- New devs onboard quicker
- Less "what does this do?"
- More design time, less firefighting

**Warning Signs:**
- Feature velocity decreasing
- Bug fixes create new bugs
- Can't understand old code
- Afraid to make changes
- Documentation always needed
- Fighting the codebase

## Remember

> "Complexity is the enemy. Your job is to minimize it through strategic design, not tactical hacking."

> "Working code isn't enough. Great design that happens to work is the goal."

> "Simple designs take thought, but they pay for themselves quickly."

---

**Full Details:** See README.md and individual skill files
**Book:** "A Philosophy of Software Design" by John Ousterhout
