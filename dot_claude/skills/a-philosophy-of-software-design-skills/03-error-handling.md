# Define Errors Out of Existence

## Core Principle
Exception handling is a significant source of complexity. The best way to handle exceptions is to design them out of existence whenever possible.

## Why Exceptions Add Complexity
1. Disrupts normal control flow
2. Increases code paths to consider  
3. Often handled far from where they occur
4. Easy to forget to handle
5. Creates dependencies between error source and handlers
6. Adds cognitive load for every caller

## Strategies to Eliminate Exceptions

### 1. Define Errors Out of Existence
Design APIs so exceptions cannot occur:
- Make semantics work for all inputs
- Remove preconditions that cause errors
- Handle edge cases internally

### 2. Mask Exceptions
Detect and handle exceptions at a low level so higher levels don't see them:
- Retry operations automatically
- Use default values
- Continue with reduced functionality

### 3. Exception Aggregation
Handle multiple related exceptions in a single place:
- Catch at a higher level where context exists
- Group similar error handling
- Reduce scattered try-catch blocks

### 4. Just Crash
For errors that are truly unrecoverable:
- Crash immediately with a clear message
- Don't pretend you can handle the unhandleable
- Better than corrupt state or silent failure

## Special Cases

### Eliminate Special Cases
Special cases are a major source of complexity:
- Each special case = conditional logic
- Creates cognitive load
- Harder to reason about behavior
- Source of bugs

**Instead**: Design so special cases don't exist or are handled uniformly

## When to Apply

### Good Candidates for Elimination
- Boundary conditions (empty, null, zero)
- Missing optional parameters
- Resource not found (sometimes)
- Out-of-bounds access
- Configuration errors with sensible defaults

### Keep as Exceptions
- Caller errors that indicate bugs
- Truly exceptional conditions
- Security violations
- Unrecoverable system failures

## Examples

### BAD: Exceptions Proliferate
```python
def get_user_preferences(user_id):
    user = db.get_user(user_id)
    if user is None:
        raise UserNotFoundError(user_id)
    
    prefs = db.get_preferences(user_id)
    if prefs is None:
        raise PreferencesNotFoundError(user_id)
    
    if not prefs.is_valid():
        raise InvalidPreferencesError(user_id)
    
    return prefs

# Every caller must handle 3 different exceptions:
try:
    prefs = get_user_preferences(user_id)
except UserNotFoundError:
    # handle
except PreferencesNotFoundError:
    # handle  
except InvalidPreferencesError:
    # handle
```

### GOOD: Defined Out of Existence
```python
def get_user_preferences(user_id):
    """Get preferences for user, or defaults if none exist.
    
    Returns valid preferences in all cases. Never raises exceptions
    for missing user or preferences - returns system defaults instead.
    """
    user = db.get_user(user_id)
    if user is None:
        return DEFAULT_PREFERENCES
    
    prefs = db.get_preferences(user_id)
    if prefs is None or not prefs.is_valid():
        return DEFAULT_PREFERENCES
    
    return prefs

# Simple usage - no exception handling needed:
prefs = get_user_preferences(user_id)
```

### BAD: Substring with Exceptions (Java)
```java
// Old Java substring: throws exception for invalid indices
String text = "Hello, World!";
try {
    String sub = text.substring(100, 200);  // Throws StringIndexOutOfBoundsException
} catch (StringIndexOutOfBoundsException e) {
    // Have to handle exception
}
```

### GOOD: Substring Defined to Work (Principle)
```java
// Better design: define behavior for all inputs
String text = "Hello, World!";
String sub = text.substring(100, 200);  // Returns "" (empty) if indices out of range
// No exception handling needed
```

### BAD: File Deletion with Error
```python
def delete_file(path):
    """Delete file at path. Raises FileNotFoundError if file doesn't exist."""
    if not os.path.exists(path):
        raise FileNotFoundError(path)
    os.remove(path)

# Caller has to handle exception:
try:
    delete_file(temp_file)
except FileNotFoundError:
    pass  # Already gone, that's fine
```

### GOOD: Define Error Away
```python
def delete_file(path):
    """Ensure file at path does not exist after this call.
    
    If file exists, it is deleted. If it doesn't exist, this is a no-op.
    Result: file is guaranteed not to exist after call returns.
    """
    if os.path.exists(path):
        os.remove(path)
    # No exception - operation always succeeds

# Simple usage:
delete_file(temp_file)  # No try-catch needed
```

### BAD: Special Cases Scattered
```javascript
function processOrder(order) {
    // Special case: free orders
    if (order.total === 0) {
        return processFreeOrder(order);
    }
    
    // Special case: guest checkout
    if (!order.customerId) {
        return processGuestOrder(order);
    }
    
    // Special case: store pickup
    if (order.shippingMethod === 'PICKUP') {
        return processPickupOrder(order);
    }
    
    // Special case: international
    if (order.country !== 'US') {
        return processInternationalOrder(order);
    }
    
    // Finally, normal case
    return processNormalOrder(order);
}
```

### GOOD: Special Cases Integrated
```javascript
function processOrder(order) {
    // Normalize order to remove special cases
    const normalizedOrder = {
        ...order,
        total: Math.max(0, order.total),
        customerId: order.customerId || generateGuestId(),
        shipping: getShippingStrategy(order),
        taxes: calculateTaxes(order)
    };
    
    // Single path handles all cases uniformly
    return executeOrderWorkflow(normalizedOrder);
}
```

### GOOD: Exception Masking
```python
class ConfigManager:
    def get_config(self, key, default=None):
        """Get configuration value with automatic fallback.
        
        Masks all exceptions internally:
        - File not found -> returns default
        - Parse errors -> returns default  
        - Network errors -> returns cached value or default
        
        Callers never need to handle exceptions.
        """
        try:
            # Try primary config source
            return self._remote_config.get(key)
        except NetworkError:
            # Fall back to cache
            try:
                return self._cache.get(key)
            except CacheError:
                pass
        except (KeyError, ParseError):
            pass
        
        # All exceptions masked - return default
        return default

# Usage is simple:
timeout = config.get_config('timeout', default=30)
```

### GOOD: Exception Aggregation
```python
class DataImporter:
    def import_data(self, file_path):
        """Import data from file, handling all errors at top level."""
        errors = []
        
        try:
            data = self._read_file(file_path)
            data = self._parse_data(data)
            data = self._validate_data(data)
            self._save_to_database(data)
        except (IOError, ParseError, ValidationError, DatabaseError) as e:
            # Single place to handle all import-related errors
            errors.append(f"Import failed: {e}")
            self._log_error(e)
            self._notify_admin(e)
            return ImportResult(success=False, errors=errors)
        
        return ImportResult(success=True, errors=[])
```

### GOOD: Just Crash
```python
def initialize_critical_resource():
    """Initialize resource required for application to function.
    
    This resource is absolutely required. If initialization fails,
    the application cannot function and should not start.
    """
    try:
        resource = setup_resource()
    except ResourceError as e:
        # Don't try to continue - crash with clear message
        print(f"FATAL: Cannot initialize critical resource: {e}")
        print("Application cannot start. Check configuration and try again.")
        sys.exit(1)
    
    return resource
```

## Guidelines

### Designing for No Exceptions
1. Ask: "What if this input is invalid? Can I define a sensible behavior?"
2. Consider: "Can I use defaults instead of errors?"
3. Question: "Is this really exceptional, or just an edge case?"
4. Design: "How can callers use this without thinking about errors?"

### When to Use Exceptions
Use exceptions for:
- Programmer errors (bugs in calling code)
- Truly unrecoverable situations
- External resource failures that must be handled specially
- Security violations

Don't use exceptions for:
- Expected variations in input
- Optional missing values
- Boundary conditions
- Situations with reasonable default behavior

### Reducing Special Cases
1. Identify all special cases in a design
2. For each, ask: "Can I eliminate this special case?"
3. Consider: "Can I handle this uniformly with the general case?"
4. Design abstractions that work for all cases

## Red Flags
- Methods with many exception clauses
- Try-catch blocks scattered throughout code
- Same exception handled in multiple places
- Exceptions for common/expected conditions
- Deep nesting of exception handlers
- Complex exception hierarchies
- Proliferation of custom exception types

## Benefits
- Simpler calling code
- Fewer error-handling paths
- Less cognitive load
- More robust (fewer forgotten error cases)
- Easier to reason about behavior
- More testable
