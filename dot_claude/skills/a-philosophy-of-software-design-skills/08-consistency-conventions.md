# Consistency and Conventions

## Core Principle
Consistency is a powerful tool for reducing complexity. When similar things are done in similar ways and dissimilar things are done in different ways, developers can leverage their existing knowledge to understand new code quickly.

## Benefits of Consistency

### Cognitive Leverage
- Learn once, apply everywhere
- Safe assumptions based on patterns
- Faster comprehension
- Less time spent learning each new situation

### Reduced Mistakes
- Patterns are recognizable
- Expectations are met
- Fewer surprises
- Correct assumptions

### Faster Development
- Don't need to make same decisions repeatedly
- Code faster with fewer bugs
- Reviews go faster
- Onboarding easier

## Types of Consistency

### 1. Naming
- Use same name for same concept everywhere
- Never use same name for different concepts
- Examples:
  - Always `fileBlock` for file blocks, `diskBlock` for disk blocks
  - Loop variables: `i` for outer, `j` for nested
  - Counts: `numItems`, `itemCount`, `totalItems`

### 2. Coding Style
- Indentation
- Brace placement
- Declaration order
- Whitespace usage
- Line length
- Import organization

### 3. Interfaces
- Multiple implementations of same interface
- Once you understand one, others are easier
- Provides consistent experience
- Reduces learning curve

### 4. Design Patterns
- Standard solutions to common problems
- Model-View-Controller
- Observer
- Factory
- Strategy
- Well-understood by developers

### 5. Invariants
- Properties that are always true
- Example: "Each line ends with newline"
- Reduces special cases
- Makes reasoning easier

### 6. Error Handling
- How exceptions are used
- When to return error codes vs exceptions
- How errors are logged
- Standard error response format

## Establishing Consistency

### Document Conventions
- Create style guide
- List most important conventions
- Make it easily accessible
- Keep it up to date
- Include examples

### Enforce Conventions
- Automated checkers (linters, formatters)
- Pre-commit hooks
- CI/CD checks
- Code review focus

### Educate Team
- New member orientation
- Regular reminders
- Code review teaching moments
- Lead by example

### Follow Existing Patterns
**"When in Rome, do as the Romans do"**
- Look at existing code first
- Match style you see
- Ask if unsure
- Don't innovate on conventions

### Don't Change Existing Conventions
**Resist "improvement" urge**:
- Consistency > your better idea
- Value of uniformity > value of marginal improvement
- Only change if:
  - Have significant new information
  - New approach much better
  - Will update ALL old code
  - Team agrees
  - Worth the disruption

## When to Apply

### Always
- Naming variables and methods
- Formatting code
- Handling errors
- Writing comments
- Organizing files

### During Code Review
- Check for consistency violations
- Teach conventions to new developers
- Be nitpicky about style
- Faster everyone learns

### When Writing New Code
- Look at similar code first
- Match existing patterns
- Reuse existing structures
- Apply established conventions

## Examples

### BAD: Inconsistent Naming
```python
# Different names for same concept
def get_user_by_id(id): pass
def fetch_product(product_id): pass
def retrieve_order(order_id): pass

# Same name for different concepts
def process(user): pass        # Processes user account
def process(order): pass       # Processes order payment
def process(data): pass        # Processes data transformation
```

### GOOD: Consistent Naming
```python
# Same pattern for similar operations
def get_user(user_id): pass
def get_product(product_id): pass
def get_order(order_id): pass

# Distinct names for different operations
def activate_user_account(user): pass
def process_order_payment(order): pass
def transform_data(data): pass
```

### BAD: Inconsistent Error Handling
```python
def read_file(path):
    return content  # Returns None on error

def write_file(path, data):
    raise IOError("Cannot write")  # Throws exception

def delete_file(path):
    return True  # Returns boolean for success/failure

# Three different error approaches!
```

### GOOD: Consistent Error Handling
```python
def read_file(path):
    """Read file. Raises IOError if file cannot be read."""
    # ... raises IOError on error

def write_file(path, data):
    """Write file. Raises IOError if file cannot be written."""
    # ... raises IOError on error

def delete_file(path):
    """Delete file. Raises IOError if file cannot be deleted."""
    # ... raises IOError on error

# Consistent: all raise IOError for I/O problems
```

### BAD: Inconsistent Style
```javascript
// Mixed indentation
function process() {
  if (condition) {
      doSomething();
  }
}

function analyze() {
    if (check) {
    performAction();
    }
}

// Mixed brace styles
function create()
{
    return obj;
}

function destroy() {
    return null;
}

// Mixed declaration styles
var x = 1;
let y = 2;
const z = 3;
```

### GOOD: Consistent Style
```javascript
// Consistent indentation (2 spaces)
function process() {
  if (condition) {
    doSomething();
  }
}

function analyze() {
  if (check) {
    performAction();
  }
}

// Consistent brace style (same line)
function create() {
  return obj;
}

function destroy() {
  return null;
}

// Consistent declaration (const/let, no var)
const x = 1;
let y = 2;
const z = 3;
```

### BAD: Breaking Existing Patterns
```python
# Existing codebase uses snake_case
def existing_function():
    pass

def another_function():
    pass

# New developer adds camelCase - breaks consistency!
def newFunction():  # WRONG - doesn't match existing style
    pass

def processData():  # WRONG - inconsistent with codebase
    pass
```

### GOOD: Following Existing Patterns
```python
# Existing codebase uses snake_case
def existing_function():
    pass

def another_function():
    pass

# New code matches existing style
def new_function():  # RIGHT - matches existing style
    pass

def process_data():  # RIGHT - consistent with codebase
    pass
```

### GOOD: Design Pattern Consistency
```java
// Observer pattern used consistently throughout application

// All event sources implement same interface
public interface Observable {
    void addObserver(Observer observer);
    void removeObserver(Observer observer);
    void notifyObservers();
}

// All observers implement same interface
public interface Observer {
    void update(Observable source, Object data);
}

// All classes follow the pattern
public class UserManager implements Observable {
    // Consistent implementation
}

public class OrderProcessor implements Observable {
    // Consistent implementation
}

// Developers understand the pattern immediately
```

### GOOD: Invariant Consistency
```python
class TextBuffer:
    """
    Maintains text as list of lines.
    
    INVARIANT: Every line ends with '\n' character.
    This invariant simplifies all text operations by eliminating
    special cases for the last line.
    """
    
    def insert_line(self, line_num, text):
        # Ensure invariant: add \n if missing
        if not text.endswith('\n'):
            text += '\n'
        self.lines.insert(line_num, text)
        
    def get_line(self, line_num):
        # Invariant guaranteed: always has \n
        return self.lines[line_num]
        
    # All methods can rely on invariant
```

## Guidelines

### Creating Conventions
1. Look at existing successful projects
2. Choose conventions that are:
   - Simple to follow
   - Easy to check automatically
   - Well-documented
   - Widely accepted in community
3. Document clearly with examples
4. Enforce with tools where possible

### Maintaining Consistency
1. Review all code changes for consistency
2. Run automated checks
3. Teach through code reviews
4. Update documentation as conventions evolve
5. Refactor old code when touching it

### When Consistency Conflicts
Priority order:
1. System safety and correctness
2. External API stability
3. Internal consistency
4. Personal preference (lowest priority)

### Checking for Consistency
Questions to ask:
- Is this done the same way as similar code?
- Are similar concepts named consistently?
- Does this follow team conventions?
- Will this surprise other developers?
- Am I introducing a new pattern unnecessarily?

## Taking It Too Far

### Don't Force Dissimilar Things
Consistency means:
- Similar things done similarly
- **AND** dissimilar things done differently

**Bad consistency**: Forcing different things into same pattern
- Using same variable name for different concepts
- Applying pattern where it doesn't fit
- Ignoring important differences

**Example**:
```python
# BAD: Forcing different operations into same pattern
def get(entity_type, id):  # Too generic
    if entity_type == 'user':
        # Different logic for users
    elif entity_type == 'order':
        # Different logic for orders
    # Forcing consistency where differences matter

# GOOD: Acknowledge differences
def get_user(user_id):      # User-specific logic
    pass
    
def get_order(order_id):    # Order-specific logic
    pass
```

## Automated Enforcement

### Tools to Use
- **Linters**: ESLint, Pylint, RuboCop, etc.
- **Formatters**: Prettier, Black, gofmt, etc.
- **Type checkers**: TypeScript, mypy, Flow
- **Pre-commit hooks**: Run checks before commit
- **CI checks**: Fail build on violations

### Example Automation
```bash
# .git/hooks/pre-commit
#!/bin/bash

# Format code automatically
black .
eslint --fix .

# Check for violations
pylint src/
eslint src/

# Fail commit if violations found
if [ $? -ne 0 ]; then
    echo "Code style violations found. Please fix before committing."
    exit 1
fi
```

## Red Flags
- Different approaches to same problem in different places
- Multiple naming conventions mixed together
- Inconsistent error handling
- No clear conventions documented
- Constant debates about style
- Each developer has their own approach

## Benefits
- Faster development
- Fewer bugs from misunderstanding
- Easier code reviews
- Simpler onboarding
- Less cognitive load
- More maintainable code
- Better teamwork
