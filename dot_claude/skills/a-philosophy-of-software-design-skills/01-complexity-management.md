# Complexity Management Principles

## Core Philosophy
Complexity is the enemy. The primary goal of software design is to minimize complexity, making systems easier to understand, modify, and maintain.

## Complexity Definition
Complexity is anything related to the structure of a software system that makes it hard to understand and modify. It manifests in three ways:
1. **Change amplification**: A simple change requires modifications in many places
2. **Cognitive load**: How much a developer needs to know to complete a task
3. **Unknown unknowns**: It's not obvious what needs to be modified or what information is needed

## Root Causes of Complexity
1. **Dependencies**: When code cannot be understood or modified in isolation
2. **Obscurity**: When important information is not obvious

## When Writing Code

### Strategic vs Tactical Programming
- **AVOID tactical programming**: Getting features working as quickly as possible without regard for design
- **EMBRACE strategic programming**: Focus on producing great design that also happens to work
- Invest 10-20% of development time on design improvements
- Think: "How can I leave the codebase better than I found it?"

### Incremental Complexity
- Complexity accumulates in small chunks over time
- Adopt a "zero tolerance" philosophy toward complexity
- Never rationalize: "This little bit of complexity is no big deal"
- Each small compromise adds up to unmaintainable systems

### Investment Mindset
- Spend extra time to find simple designs
- Refactor when you discover design problems (don't patch around them)
- Write good documentation during development, not after
- Think long-term: the majority of code is written by extending existing systems

## Code Review Questions
When reviewing code (yours or others'), ask:
- Does this change amplify future changes?
- How much do I need to know to understand this?
- Are there hidden dependencies or assumptions?
- Is the purpose and behavior immediately obvious?
- Could this be simpler while still solving the problem?

## Red Flags
- Code that requires reading many other files to understand
- Multiple places that must be changed for a single logical change
- Extensive documentation needed to explain what code does
- Special cases and exceptions proliferating
- Difficulty explaining what code does in simple terms

## When to Apply
Apply these principles:
- At the start of every new feature or module
- When reviewing code before committing
- When you encounter confusing or difficult-to-modify code
- During refactoring sessions
- When onboarding new team members exposes unclear areas

## Examples

### BAD: Tactical Approach
```python
# Quick fix for bug - just check if user is None
def process_user_data(user):
    if user is None:
        return None
    # ... later someone adds another special case
    if user.is_deleted:
        return None
    # ... and another
    if not user.has_permission('read'):
        return None
    # Now we have complexity accumulating
```

### GOOD: Strategic Approach
```python
# Define valid states upfront, eliminate special cases
def process_user_data(user):
    """Process data for an active, valid user with read permission.
    
    Precondition: user must be non-null, active, and have read permission.
    Use get_valid_user() to retrieve a user that meets these requirements.
    """
    # No special case checks needed - preconditions ensure validity
    return user.process_data()

def get_valid_user(user_id):
    """Returns a user ready for processing, or None if user invalid."""
    user = fetch_user(user_id)
    if user and not user.is_deleted and user.has_permission('read'):
        return user
    return None
```

### BAD: Change Amplification
```javascript
// Banner color specified in each page
// pages/home.html: <div style="background-color: #336699">
// pages/about.html: <div style="background-color: #336699">
// pages/contact.html: <div style="background-color: #336699">
// Changing the color requires modifying every page
```

### GOOD: Centralized Decision
```javascript
// theme.css
:root {
    --banner-bg-color: #336699;
}

// All pages reference central value
<div class="banner">
```

## Summary
- Complexity is incremental - sweat the small stuff
- Working code isn't enough - design quality matters
- Make continual small investments in design
- Think strategically, not tactically
- Measure impact by how code affects readers, not writers
