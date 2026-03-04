# Design Process and Methodology

## Core Principles

### 1. Design It Twice
Never settle for the first design that comes to mind. Consider multiple approaches before choosing one.

**Process**:
1. Think of one approach
2. Think of at least one alternative that's significantly different
3. Compare the approaches
4. Pick the best one
5. If all seem bad, brainstorm more alternatives

**Why it works**:
- First idea rarely the best
- Comparison reveals strengths/weaknesses
- Exposes options you wouldn't otherwise see
- Relatively small time investment
- Improves design intuition over time

### 2. Incremental Design
Design emerges through iteration, not upfront planning:
- Start with small subset
- Design, implement, evaluate
- Discover problems early while system is small
- Refactor based on experience
- Add features incrementally
- Each iteration improves design

**Not waterfall**: Don't try to design everything upfront

**Not pure agile**: Don't skip design in favor of just features

**Balance**: Design abstractions incrementally, not features incrementally

## Design Process Steps

### For New Module/Class

1. **Write interface comment first**
   - What does this module do? (in one sentence)
   - What abstraction does it provide?
   - Write this before any code

2. **Design key methods**
   - Write method signatures
   - Write interface comments for each
   - Iterate until structure feels right

3. **Declare important instance variables**
   - Write comments for each
   - Consider what information needs to be maintained

4. **Implement methods**
   - Fill in method bodies
   - Add implementation comments as needed
   - Discover need for additional methods/variables
   - Write interface comments before implementing new methods

5. **Review and refactor**
   - Does implementation match comments?
   - Are abstractions clean?
   - Can anything be simplified?

### For Modifying Existing Code

1. **Stay strategic**
   - Don't just make minimal change
   - Think: "What's the best design for this system now?"
   - Refactor toward best design

2. **Improve while you're there**
   - Leave code better than you found it
   - Fix design problems you encounter
   - Even small improvements accumulate

3. **Update documentation**
   - Keep comments near code they describe
   - Update before committing
   - Check diffs for documentation consistency

## When Making Design Decisions

### Questions to Ask

**Complexity**:
- Does this reduce overall complexity?
- Am I adding dependencies?
- Is this obvious to readers?

**Abstractions**:
- What's the essential concept?
- What can be hidden?
- Is this interface deep or shallow?

**Generality**:
- Is this too specific to one use case?
- Could this handle related scenarios?
- Am I exposing implementation details?

**Special Cases**:
- Can I eliminate this special case?
- Can I define this error out of existence?
- Is this exception necessary?

**Alternatives**:
- Have I considered other approaches?
- What's the trade-off?
- Which is simpler?

### Trade-offs to Consider

**Simplicity vs Functionality**:
- Prefer simpler design if it meets needs
- Don't add features "just in case"
- Can add complexity later if actually needed

**Generality vs Specificity**:
- Somewhat general is deeper
- Too general adds unnecessary complexity
- Find the sweet spot

**Performance vs Simplicity**:
- Simple code often fast enough
- Measure before optimizing
- Design for natural efficiency
- Keep critical paths simple

**Comments vs Code Clarity**:
- Good code needs fewer comments
- But some things can't be expressed in code
- Use both: clear code + strategic comments

## Common Patterns

### Pull Complexity Downward
When complexity can't be eliminated, hide it in implementation:
- Users shouldn't deal with complexity
- Better for module to handle complexity than push to callers
- Example: Configuration with sensible defaults vs requiring all parameters

### Define Errors Out
Design so exceptions/errors cannot occur:
- Make operations work for all inputs
- Use defaults instead of errors
- Handle edge cases internally

### Separate General from Special
- Keep general-purpose code separate from special-purpose
- Special code can use general code
- General code shouldn't know about special code
- Clearer responsibilities and dependencies

### One Concept, One Place
- Each design decision should be reflected in one place only
- Avoid information leakage
- Changes affect minimal code
- Easier to understand and maintain

## Examples

### BAD: First Design (Not Designed Twice)
```python
# First idea that came to mind
class Cache:
    def __init__(self, max_size):
        self.data = {}
        self.max_size = max_size
        self.access_times = {}
        
    def get(self, key):
        if key in self.data:
            self.access_times[key] = time.time()
            return self.data[key]
        return None
        
    def put(self, key, value):
        if len(self.data) >= self.max_size:
            # Evict least recently used
            oldest_key = min(self.access_times.keys(), 
                           key=lambda k: self.access_times[k])
            del self.data[oldest_key]
            del self.access_times[oldest_key]
        self.data[key] = value
        self.access_times[key] = time.time()
```

### GOOD: After Considering Alternatives
```python
# Alternative 1: LRU with separate tracking (rejected - complex)
# Alternative 2: TTL-based eviction (rejected - different use case)
# Alternative 3: OrderedDict approach (selected - simpler)

from collections import OrderedDict

class Cache:
    """Fixed-size cache with LRU eviction.
    
    Maintains most recently accessed items up to max_size.
    Automatically evicts least recently used items when full.
    """
    def __init__(self, max_size):
        self._data = OrderedDict()
        self._max_size = max_size
        
    def get(self, key):
        """Get value, marking it as recently used."""
        if key not in self._data:
            return None
        # Move to end (most recent)
        self._data.move_to_end(key)
        return self._data[key]
        
    def put(self, key, value):
        """Add or update value, evicting LRU if necessary."""
        if key in self._data:
            self._data.move_to_end(key)
        self._data[key] = value
        
        # Evict oldest if over capacity
        if len(self._data) > self._max_size:
            self._data.popitem(last=False)

# Simpler, clearer, leverages standard library
```

### BAD: Tactical Programming
```javascript
// Just make it work quickly
function processUserRegistration(req) {
    // Quick fix for null email
    if (!req.body.email) {
        req.body.email = 'default@example.com';
    }
    
    // Another quick fix for age
    if (!req.body.age) {
        req.body.age = 0;
    }
    
    // Add user to database
    db.users.insert(req.body);
    
    // Oh, need to send email too
    sendEmail(req.body.email, 'Welcome!');
}

// Complexity accumulates, no thought to design
```

### GOOD: Strategic Programming
```javascript
/**
 * Process new user registration.
 * 
 * Validates input, creates user account, sends welcome email.
 * Returns created user or throws ValidationError.
 */
function processUserRegistration(registrationData) {
    // Validate input (defines errors out of existence)
    const validated = validateRegistration(registrationData);
    
    // Create user (single responsibility)
    const user = createUser(validated);
    
    // Send welcome notification (separate concern)
    scheduleWelcomeEmail(user);
    
    return user;
}

function validateRegistration(data) {
    /**
     * Validate and normalize registration data.
     * Throws ValidationError with details if invalid.
     */
    if (!data.email || !isValidEmail(data.email)) {
        throw new ValidationError('Valid email required');
    }
    
    if (!data.age || data.age < 13) {
        throw new ValidationError('Must be 13 or older');
    }
    
    return {
        email: data.email.toLowerCase().trim(),
        age: parseInt(data.age),
        ...data
    };
}

// Thought given to design, proper abstractions, maintainable
```

### GOOD: Incremental Design Evolution
```python
# Iteration 1: Basic functionality
class DocumentStore:
    def save(self, doc): pass
    def load(self, id): pass

# Iteration 2: Discover need for search
class DocumentStore:
    def save(self, doc): pass
    def load(self, id): pass
    def search(self, query): pass  # Added based on actual need

# Iteration 3: Performance issues → Add caching (internal detail)
class DocumentStore:
    def __init__(self):
        self._cache = Cache(100)  # Internal implementation detail
        
    def save(self, doc):
        # Implementation now uses cache
        
    def load(self, id):
        # Check cache first
        # Interface unchanged, implementation improved

# Design evolved based on real usage and problems
```

## Guidelines

### Time Investment
- Spend 10-20% of development time on design
- This includes:
  - Thinking about abstractions
  - Writing comments/documentation
  - Refactoring
  - Reviewing alternatives
- Short-term slower, long-term much faster

### Design Reviews
- Review own code before committing
- Think about design in code reviews
- Ask: "Is this the simplest approach?"
- Look for red flags
- Suggest refactorings

### Refactoring Strategy
- Make small improvements continuously
- Don't wait for "big refactoring" later
- Leave code better than you found it
- Fix design problems when you see them
- Think: "What's the best structure now?"

### When to Stop Designing
Stop when:
- Design is simple and obvious
- Interface comment is short and clear
- Implementation straightforward
- No obvious improvements
- Further changes add complexity

Don't stop just because:
- You have working code
- You're under time pressure (invest anyway)
- First design seems "good enough"

## Red Flags in Process

**Tactical Programming Signs**:
- Just making it work quickly
- Adding complexity for short-term convenience
- Patching around problems
- Not updating documentation
- Skipping design phase

**Poor Process Signs**:
- Never considering alternatives
- Not writing comments first
- Designing everything upfront (waterfall)
- Never refactoring
- Adding features without design

**Need to Rethink Signs**:
- Can't write simple interface comment
- Implementation as complex as interface
- Many special cases
- Can't explain design simply
- Design feels wrong

## Benefits of Good Process
- Better designs emerge
- Problems caught early
- Less rework needed
- Faster long-term development
- More enjoyable programming
- Cleaner codebases
- Easier maintenance
