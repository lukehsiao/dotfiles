# Naming and Code Obviousness

## Core Principle
Good names are a form of documentation. They reduce complexity by making code obvious and reducing the need to read implementation details or documentation.

## What Makes Code Obvious
Code is obvious when someone can read it quickly, without much thought, and their first guesses about behavior will be correct. Obvious code:
- Makes intent clear immediately
- Uses familiar patterns consistently
- Provides information that readers need
- Hides information that isn't needed
- Avoids surprises

## Naming Principles

### 1. Create a Mental Image
A good name conveys what the entity is AND what it is not:
- Readers should be able to guess meaning without seeing declaration
- Focus on most important aspects
- Use 2-3 words maximum
- Be specific, not generic

### 2. Be Precise
Avoid vague or generic names:
- ❌ `data`, `info`, `manager`, `handler`, `processor`
- ❌ `count`, `status`, `result`, `value`
- ✓ `activeUserCount`, `httpResponse`, `parseResult`, `maxRetries`

### 3. Be Consistent  
Use the same name for the same concept everywhere:
- Pick a name for each common usage and stick to it
- Never use the name for anything else
- Make the purpose narrow enough for uniform behavior
- Example: Always use `fileBlock` for file blocks, `diskBlock` for disk blocks

### 4. Choose Predicates for Booleans
Boolean variables should be predicates that clearly indicate true/false:
- ✓ `isActive`, `hasPermission`, `canExecute`, `shouldRetry`
- ❌ `status`, `flag`, `state`, `mode`

## Length Guidelines
- **Short names (i, j, x, y)**: Only for tiny scopes (loop variables visible in a few lines)
- **Medium names (2-3 words)**: Most variables and methods
- **Longer names**: When entity is used across large scope or represents complex concept
- **Rule**: Greater distance from declaration to use = longer name needed

## Making Code Obvious

### Good Techniques
1. **Good names**: Precise, meaningful, consistent
2. **Consistency**: Similar things done similarly, dissimilar things done differently
3. **White space**: Use blank lines to separate logical blocks
4. **Conventions**: Follow expected patterns
5. **Strategic comments**: Explain non-obvious aspects
6. **Simple control flow**: Minimize nesting and branches

### Things That Make Code Less Obvious
1. **Event-driven programming**: Unclear flow of control
2. **Generic containers**: `Pair<Integer, Boolean>` - what do they mean?
3. **Declaration/allocation mismatch**: `List<T> x = new ArrayList<T>()`
4. **Violating expectations**: Code that works differently than similar code
5. **Nonobvious code**: Behavior cannot be understood with quick read

## When to Apply

### During Writing
- Choosing variable/method/class names
- Structuring control flow
- Deciding on abstractions
- Writing comments

### During Review
- When code is confusing
- When you have to think hard to understand
- When behavior could be misunderstood
- When similar code exists elsewhere

## Examples

### BAD: Generic Names
```python
# What kind of count? Count of what?
def getCount():
    return count

# What status? What does true/false mean?
status = True

# Which manager? What does it manage?
class DataManager:
    pass

# x and y could mean anything
x = calculate_position()
y = get_next_value()
```

### GOOD: Precise Names
```python
def getActiveUserCount():
    return activeUserCount

# Clear what it represents
cursorVisible = True

class OrderProcessingCoordinator:
    pass

# Clear what these represent
charIndexInLine = calculate_position()
lineIndexInFile = get_next_value()
```

### BAD: Inconsistent Names
```python
# Uses 'block' for two different things
def read_file():
    block = get_file_block(5)  # Logical block in file
    # ... later ...
    block = get_disk_block(10)  # Physical block on disk
    # Now 'block' is ambiguous - which type?
```

### GOOD: Consistent Names
```python
def read_file():
    fileBlock = get_file_block(5)   # Always fileBlock for file blocks
    diskBlock = get_disk_block(10)  # Always diskBlock for disk blocks
    # Clear distinction
```

### BAD: Generic Boolean Names
```python
# What does True mean? What does False mean?
blinkStatus = True
flag = check_condition()
state = is_ready()
```

### GOOD: Predicate Boolean Names
```python
cursorVisible = True  # Clear: True = visible, False = not visible
shouldRetry = check_condition()
isReady = is_ready()
```

### BAD: Too Short for Scope
```python
# Used across many functions
i = fetch_user_preferences()
# ... 50 lines later ...
update_profile(i)  # What is 'i'? Have to scroll back
```

### GOOD: Appropriate Length
```python
userPreferences = fetch_user_preferences()
# ... 50 lines later ...
update_profile(userPreferences)  # Clear what this is
```

### BAD: Nonobvious Generic Container
```java
// What do the values mean?
public Pair<Integer, Boolean> checkStatus() {
    return new Pair<>(currentTerm, false);
}

// Usage is unclear
Pair<Integer, Boolean> result = checkStatus();
int term = result.getKey();      // What is key?
boolean status = result.getValue(); // What does value represent?
```

### GOOD: Specific Structure
```java
public class StatusResult {
    public final int currentTerm;
    public final boolean isLeader;
    
    public StatusResult(int currentTerm, boolean isLeader) {
        this.currentTerm = currentTerm;
        this.isLeader = isLeader;
    }
}

// Usage is obvious
StatusResult result = checkStatus();
int term = result.currentTerm;
boolean leader = result.isLeader;
```

### BAD: Poor Whitespace
```python
def process_data(items):
    for item in items:
        if item.is_valid():
            result=calculate(item)
            if result>threshold:
                store(result)
            else:
                discard(result)
    return total
```

### GOOD: Good Whitespace
```python
def process_data(items):
    # Process each valid item
    for item in items:
        if not item.is_valid():
            continue
            
        result = calculate(item)
        
        if result > threshold:
            store(result)
        else:
            discard(result)
    
    return total
```

### BAD: Violates Expectations
```javascript
// Looks like it just creates an object, but actually...
public static void main(String[] args) {
    new RaftClient(myAddress, serverAddresses);
    // Program continues running in background threads!
    // Violates expectation that main() exit = program exit
}
```

### GOOD: Meets Expectations
```javascript
public static void main(String[] args) {
    // Start client - continues running in background threads
    RaftClient client = new RaftClient(myAddress, serverAddresses);
    client.start();
    // Comment makes non-obvious behavior clear
}
```

### BAD: Event Handler Without Context
```typescript
// When is this called? By whom? In what state?
function onDataReceived(data: Buffer) {
    process(data);
}
```

### GOOD: Documented Event Handler  
```typescript
/**
 * Called by the network layer when a complete data packet arrives.
 * Always invoked on the network I/O thread.
 * 
 * @param data Complete packet data, already validated
 */
function onDataReceived(data: Buffer) {
    process(data);
}
```

## Guidelines for Choosing Names

### Start with These Questions
1. "If someone sees this name alone, what will they guess it means?"
2. "Is there a better name that paints a clearer picture?"
3. "Does this name focus on what's most important?"
4. "Is this name consistent with similar entities?"
5. "Would I be confused if I saw this name in 6 months?"

### Red Flags
- **Vague name**: Could refer to many different things
- **Hard to pick name**: Suggests unclear design
- Generic words: data, info, manager, handler, processor, value, result
- Single letter (outside tiny loop)
- Same name used for different purposes
- Name requires comment to explain

### Name Length Decision Tree
```
Is scope < 10 lines AND meaning obvious from context?
  YES -> Short name OK (i, j, temp, etc.)
  NO  -> Continue
  
Is this a common concept used everywhere?
  YES -> Establish one consistent name (2-3 words)
  NO  -> Continue
  
Does entity represent something complex or unusual?
  YES -> Longer, more descriptive name
  NO  -> Medium length (2-3 words)
```

## Consistency Patterns

### Establish Conventions
- Loop variables: `i` for outer, `j` for inner
- Counts: `numItems`, `itemCount`, `totalItems`
- Indices: `itemIndex`, `startIndex`, `currentPosition`
- Booleans: `isValid`, `hasData`, `canExecute`, `shouldRetry`
- Maximum: `maxRetries`, `maxSize`, `maxValue`
- Results: `parseResult`, `validationResult`, `queryResult`

### Apply Consistently
- Always use conventions once established
- Never use conventional name for different purpose  
- Document conventions for team

## Benefits of Good Names and Obvious Code
- Reduces time to understand code
- Fewer bugs from misunderstanding
- Easier to modify correctly
- Less documentation needed
- Faster code reviews
- Better onboarding for new developers
