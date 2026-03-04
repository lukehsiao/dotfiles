# Comments and Documentation

## Core Principle
Comments should describe things that aren't obvious from the code itself. Good comments capture abstractions and design decisions that cannot be represented in code alone.

## The Role of Comments
- Capture WHAT and WHY, not HOW
- Describe abstractions and intent
- Provide information at different level than code
- Make code obvious
- Reduce cognitive load

**Critical**: If you can't describe something simply in a comment, it's probably too complex.

## Comment Types

### 1. Interface Comments
Describe a module's abstraction without implementation details:
- **Class comment**: Overall abstraction, what class represents
- **Method comment**: Behavior, parameters, return value, side effects, exceptions, preconditions
- Focus on WHAT the method does, not HOW

### 2. Implementation Comments
Inside methods, explain:
- Overall strategy
- Why code works this way
- Non-obvious aspects
- What each major block does

### 3. Data Comments
For variables, describe:
- What the variable represents
- Units of measurement
- Boundary conditions (inclusive/exclusive)
- Null semantics
- Ownership (who frees/closes)
- Invariants

### 4. Cross-Module Comments
Document dependencies between modules:
- Keep in central location (designNotes file)
- Reference from relevant code
- Example: "See Zombies section in designNotes"

## Writing Good Comments

### Write Comments First
1. Write interface comment before code
2. This makes comments part of design process
3. Helps identify complexity early
4. Ensures abstractions are well thought out
5. Comments improve alongside code

### Lower-Level Comments (Add Precision)
Provide details not obvious from code:
- Units: "timeout in milliseconds"
- Boundaries: "startIndex inclusive, endIndex exclusive"
- Null handling: "returns null if user not found"
- Ownership: "caller must free returned memory"
- Invariants: "list always contains at least one entry"

### Higher-Level Comments (Add Intuition)
Provide simpler, more abstract understanding:
- Overall purpose of code block
- Why this approach was chosen
- How pieces fit together
- Key assumptions

## What NOT to Comment

### Don't Repeat Code
Bad: Comment just restates what code does
```python
# Increment counter
counter += 1

# Check if user is valid
if user.is_valid():
```

### Don't Use Same Words as Code
Bad: Comment uses same words as method/variable name
```java
// Get normalized resource names
private String[] getNormalizedResourceNames()

// Downcast parameter to type
private Object downCastParameter(String parameter, String type)
```

### Don't Document Obvious Things
- No need to document that you must include .h file
- Don't explain language features
- Don't repeat type information

### Don't Put Implementation in Interface
Bad: Interface comment describes implementation details
```java
/**
 * This method scans through internal hash table using linear probing
 * and compares each entry using strcmp...
 */
public String lookup(String key)
```

Good: Interface describes behavior only
```java
/**
 * Returns the value associated with the given key, or null if key not found.
 */
public String lookup(String key)
```

## When to Apply

### Write Comments
- While designing (before implementation)
- For every public interface
- For non-obvious implementation details
- When refactoring (update as you go)
- For complex algorithms
- To explain "why" behind decisions

### Don't Write Comments
- For self-explanatory code
- When better code would eliminate need
- For implementation details in interfaces
- That repeat what code says
- That will immediately become obsolete

## Examples

### BAD: Repeats Code
```javascript
// Add horizontal scroll bar
hScrollBar = new JScrollBar(JScrollBar.HORIZONTAL);
add(hScrollBar, BorderLayout.SOUTH);

// Add vertical scroll bar  
vScrollBar = new JScrollBar(JScrollBar.VERTICAL);
add(vScrollBar, BorderLayout.EAST);

// Initialize caret position
caretX = 0;
caretY = 0;
```

### GOOD: Provides Information
```javascript
// Scroll bars are added to the window's south and east borders.
// They will automatically appear/disappear based on content size.
hScrollBar = new JScrollBar(JScrollBar.HORIZONTAL);
add(hScrollBar, BorderLayout.SOUTH);
vScrollBar = new JScrollBar(JScrollBar.VERTICAL);
add(vScrollBar, BorderLayout.EAST);

// Caret initially positioned at start of document (char 0, line 0)
caretX = 0;  // Character position within line
caretY = 0;  // Line number in document
```

### BAD: Vague Implementation Comment
```python
# If there is a LOADING readRpc using same session as PKHash
# pointed to by assignPos, and last PKHash in that readRPC is 
# smaller than current assigning PKHash, then we put assigning
# PKHash into that readRPC.
```

### GOOD: Higher-Level Intent
```python
# Try to append the current key hash onto an existing RPC to the
# desired server that hasn't been sent yet.
```

### BAD: Missing Precision
```java
// Current offset in response buffer
uint32_t offset;

// Contains all line widths inside document and number of appearances
private TreeMap<Integer, Integer> lineWidths;
```

### GOOD: Precise Details
```java
// Position in this buffer of the first object that hasn't been
// returned to the client.
uint32_t offset;

// Holds statistics about line lengths of the form <length, count>
// where length is number of characters in a line (including the
// newline), and count is number of lines with exactly that many
// characters. If there are no lines with a particular length,
// then there is no entry for that length.
private TreeMap<Integer, Integer> numLinesWithLength;
```

### BAD: Implementation in Interface
```java
/**
 * This class implements the client side framework for index range lookups.
 * It manages a single LookupIndexKeys RPC and multiple IndexedRead RPCs.
 * Client side just includes "IndexLookup.h" in its header to use IndexLookup
 * class. Several parameters can be set in the config below:
 * - Number of concurrent indexedRead RPCs
 * - Max number of PKHashes an indexedRead RPC can hold at a time
 * - Size of active PKHashes
 */
class IndexLookup { ... }
```

### GOOD: Interface Abstraction Only
```java
/**
 * This class is used by client applications to make range queries using
 * indexes. Each instance represents a single range query.
 * 
 * To start a range query, create an instance of this class. Then call
 * getNext() to retrieve objects in the desired range. For each object
 * returned by getNext(), invoke getKey(), getKeyLength(), getValue(),
 * and getValueLength() to get information about that object.
 */
class IndexLookup { ... }
```

### GOOD: Method with Complete Documentation
```python
def copy(offset: int, length: int, dest: bytearray) -> int:
    """Copy a range of bytes from buffer to external location.
    
    Args:
        offset: Index within buffer of first byte to copy
        length: Number of bytes to copy
        dest: Where to copy bytes; must have room for at least length bytes
        
    Returns:
        Actual number of bytes copied, which may be less than length if
        the requested range extends past the end of the buffer. Returns
        0 if there is no overlap between requested range and actual buffer.
    """
```

### GOOD: Cross-Module Documentation
```python
# In Status enum definition:
class Status(Enum):
    STATUS_OK = 0
    STATUS_UNKNOWN_TABLET = 1
    STATUS_WRONG_VERSION = 2
    # ...
    
    # NOTE: If you add a new status value, you must also:
    # (1) Update STATUS_MAX_VALUE to equal the largest status value
    # (2) Add entries to tables in Status.cc
    # (3) Add new exception class to ClientException.h
    # (4) Add case in ClientException::throwException
    # (5) Add static class for exception in Java ClientException.java
    # (6) Add case in Java ClientException.java to throw exception
    # (7) Add exception to Status enum in Java Status.java
```

### GOOD: Implementation Strategy Comment
```python
def process_requests(requests):
    # Process in three phases:
    # Phase 1: Validate all requests and collect into batches
    # Phase 2: Execute batches in parallel
    # Phase 3: Collect results and send responses
    
    # Phase 1: Validation and batching
    batches = {}
    for request in requests:
        # ... validation ...
    
    # Phase 2: Parallel execution
    results = execute_parallel(batches)
    
    # Phase 3: Response collection
    return collect_responses(results)
```

### GOOD: Why Comment
```javascript
if (numProcessedHashes < readRpc[i].numHashes) {
    // Some key hashes couldn't be looked up in this request (either
    // because they aren't stored on the server, the server crashed,
    // or there wasn't enough space in the response message). Mark
    // the unprocessed hashes so they will get reassigned to new RPCs.
    for (p = removePos; p < insertPos; p++) {
        // ...
    }
}
```

## Guidelines

### Interface Comment Checklist
- ✓ High-level description of what it does
- ✓ All parameters documented with precision
- ✓ Return value documented
- ✓ All side effects listed
- ✓ All exceptions listed
- ✓ All preconditions stated
- ✗ No implementation details
- ✗ No discussion of how it works internally

### Variable Comment Checklist
- ✓ What variable represents (nouns, not verbs)
- ✓ Units if applicable
- ✓ Boundary conditions
- ✓ Null semantics
- ✓ Ownership/lifetime
- ✓ Invariants
- ✗ Not how it's manipulated

### Implementation Comment Guidelines
- Keep near the code they describe
- Push down to narrowest scope
- Abstract away from details
- Explain why, not just what
- Describe overall strategy

## Maintaining Comments

### Keep Comments Near Code
- In same file as code, not in commit messages
- Right next to declaration/implementation
- Easier to see when code changes
- More likely to be updated

### Avoid Duplication
- Document each decision exactly once
- Reference external documentation instead of copying
- Use cross-references to central documentation
- Update in one place only

### Check Before Committing
- Scan all changes
- Ensure comments updated
- Check for obsolete comments
- Verify new code is documented

## Red Flags
- **Comment repeats code**: Information already obvious from code
- **Implementation contaminates interface**: Interface docs describe how, not what
- **Hard to describe**: Indicates potential design problem
- **Outdated comments**: Not updated when code changed
- **No comments**: Public interfaces without documentation

## Benefits
- Easier to understand code
- Better designs (comments as design tool)
- Less time spent reading code
- Fewer misunderstandings and bugs
- Easier maintenance
- Better onboarding
