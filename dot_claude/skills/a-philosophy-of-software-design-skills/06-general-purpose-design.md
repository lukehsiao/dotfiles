# General-Purpose Design and Abstraction

## Core Principle
Somewhat general-purpose interfaces are deeper, simpler, and easier to use than special-purpose ones. They provide better information hiding and are more likely to be reusable.

## Why General-Purpose is Better

### Deeper Classes
- General-purpose methods amortize learning cost across more uses
- Single interface serves multiple needs
- Reduces total system complexity
- Better information hiding

### Simpler to Use
- Fewer special cases to remember
- One approach handles many situations
- Less cognitive load
- More predictable behavior

### More Maintainable
- Changes affect fewer places
- Easier to extend
- Better encapsulation
- Fewer interfaces to maintain

## Somewhat General-Purpose
**Key insight**: Not fully general-purpose (that's too complex), but more general than strictly necessary for current needs.

### Sweet Spot
- Handles current use case simply
- Can handle related use cases without modification
- Doesn't anticipate every possible future need
- Balances generality with simplicity

### Not Too General
Avoid:
- Excessive configuration options
- Anticipating needs that may never arise
- Complex abstractions for simple cases
- "Frameworks" when simple code suffices

### Not Too Specific
Avoid:
- Hard-coded assumptions about one use case
- Multiple similar methods for different cases
- Interfaces that leak specific use case details
- Temporal decomposition

## When to Apply

### Design New Interfaces
- Ask: "What's the simplest general interface?"
- Consider: "What else might use this?"
- Question: "Am I exposing implementation details?"

### Refactor Existing Code
- When you find similar methods
- When special cases proliferate
- When modifying for new use case
- When interfaces feel awkward

## Different Layer, Different Abstraction

### Layer Principles
- Each layer should provide different abstraction
- Don't just pass through to next layer
- Add value at each layer
- Eliminate pass-through methods

### Pass-Through Problems
Pass-through methods are shallow:
- Just call another method with same signature
- Add no value
- Increase cognitive load
- Create dependencies without benefit

### When Duplication is OK
Interface duplication is acceptable when:
- Layers provide different abstractions
- Dispatcher pattern (routing to different implementations)
- Decorator adds significant functionality
- Different purposes despite similar signatures

## Examples

### BAD: Too Specific
```python
class TextEditor:
    def insert_char_after_selection(self, char):
        """Insert character after current selection."""
        pass
        
    def insert_char_at_cursor(self, char):
        """Insert character at cursor position."""
        pass
        
    def insert_char_at_position(self, line, col, char):
        """Insert character at specific position."""
        pass
        
    def delete_selection(self):
        """Delete selected text."""
        pass
        
    def delete_char_at_cursor(self):
        """Delete character at cursor."""
        pass
        
    def delete_line(self, line_num):
        """Delete entire line."""
        pass

# Six methods for variations of insert/delete
```

### GOOD: General-Purpose Interface
```python
class TextEditor:
    def insert(self, text, position=None):
        """Insert text at position.
        
        Args:
            text: Text to insert (can be single char or string)
            position: Where to insert. If None, uses current cursor/selection.
                     If selection exists, replaces selection.
                     
        This single method handles:
        - Insert at cursor
        - Insert at specific position
        - Replace selection
        - Insert character or multi-character string
        """
        pass
        
    def delete(self, start=None, end=None):
        """Delete text in range.
        
        Args:
            start: Start of range. If None, uses cursor/selection start.
            end: End of range. If None, uses cursor/selection end.
            
        This single method handles:
        - Delete selection
        - Delete character at cursor (end=None means one char)
        - Delete arbitrary range
        - Delete line (pass line start/end positions)
        """
        pass

# Two general methods replace six specific ones
```

### BAD: Too General
```python
class DataProcessor:
    def process(self, data, operation_type, config_dict, flags, options_array,
                callback_func, error_handler, retry_policy, timeout_ms,
                max_retries, validate_input, transform_output, cache_results,
                async_mode, batch_size, ...):
        """Process data with all possible options."""
        # Trying to handle every possible scenario
        # Complex configuration with many parameters
        pass

# Too many options, too configurable, too complex
```

### GOOD: Somewhat General
```python
class DataProcessor:
    def process(self, data, operation='default'):
        """Process data using specified operation.
        
        Args:
            data: Data to process
            operation: Operation name (default, validate, transform)
            
        Handles most common operations simply. For advanced needs,
        use configure() method to set additional options before calling process().
        """
        # Handles common cases simply
        # Advanced options available but not required
        pass
        
    def configure(self, **options):
        """Configure optional processing behavior.
        
        Only needed for non-default behavior. Common options:
        - timeout: Maximum processing time
        - retries: Number of retry attempts
        - cache: Whether to cache results
        """
        pass

# Simple default case, advanced options available but separate
```

### BAD: Pass-Through Methods
```java
// User interface layer
public class UserController {
    private UserService service;
    
    public User getUser(String id) {
        return service.getUser(id);  // Just passes through
    }
    
    public void updateUser(String id, UserData data) {
        service.updateUser(id, data);  // Just passes through
    }
    
    public void deleteUser(String id) {
        service.deleteUser(id);  // Just passes through
    }
}

// Service layer  
public class UserService {
    private UserRepository repository;
    
    public User getUser(String id) {
        return repository.getUser(id);  // Just passes through
    }
    
    public void updateUser(String id, UserData data) {
        repository.updateUser(id, data);  // Just passes through
    }
    
    public void deleteUser(String id) {
        repository.deleteUser(id);  // Just passes through
    }
}
```

### GOOD: Different Abstractions
```java
// Controller handles HTTP concerns
public class UserController {
    private UserService service;
    
    @GET("/users/{id}")
    public Response getUser(@PathParam("id") String id) {
        try {
            User user = service.getUser(id);
            return Response.ok(user).build();
        } catch (UserNotFoundException e) {
            return Response.status(404).build();
        }
    }
    
    @PUT("/users/{id}")
    public Response updateUser(@PathParam("id") String id, 
                              @Valid UserData data) {
        service.updateUser(id, data);
        return Response.noContent().build();
    }
}

// Service handles business logic and coordination
public class UserService {
    private UserRepository repository;
    private EmailService emailService;
    private AuditLogger auditLogger;
    
    public User getUser(String id) {
        User user = repository.findById(id);
        if (user == null) {
            throw new UserNotFoundException(id);
        }
        auditLogger.logAccess(id);
        return user;
    }
    
    public void updateUser(String id, UserData data) {
        User user = repository.findById(id);
        user.update(data);
        repository.save(user);
        emailService.sendUpdateNotification(user);
        auditLogger.logUpdate(id, data);
    }
}

// Each layer adds different abstraction
```

### BAD: Special Cases Proliferate
```typescript
class FileStorage {
    saveTextFile(path: string, content: string): void { }
    saveJsonFile(path: string, obj: object): void { }
    saveBinaryFile(path: string, data: Buffer): void { }
    saveImageFile(path: string, image: Image): void { }
    saveCsvFile(path: string, rows: string[][]): void { }
    
    readTextFile(path: string): string { }
    readJsonFile(path: string): object { }
    readBinaryFile(path: string): Buffer { }
    readImageFile(path: string): Image { }
    readCsvFile(path: string): string[][] { }
}

// Need new methods for each file type
```

### GOOD: General-Purpose with Options
```typescript
class FileStorage {
    save(path: string, content: string | Buffer, options?: SaveOptions): void {
        /**
         * Save content to file at path.
         * 
         * Handles any content type. Optional encoding/format can be specified
         * through options. Automatically detects format from file extension
         * if not specified.
         */
    }
    
    read(path: string, options?: ReadOptions): string | Buffer | object {
        /**
         * Read file contents from path.
         * 
         * Returns appropriate type based on file format. Use options to
         * specify desired format if auto-detection is insufficient.
         */
    }
}

// Two general methods handle all cases
```

### BAD: Exposing Implementation
```python
class OrderProcessor:
    def process_credit_card_order(self, order):
        """Process order paid with credit card."""
        pass
        
    def process_paypal_order(self, order):
        """Process order paid with PayPal."""
        pass
        
    def process_bank_transfer_order(self, order):
        """Process order paid with bank transfer."""
        pass

# Exposes payment implementation details
# New payment method = new public method = API change
```

### GOOD: Hiding Implementation
```python
class OrderProcessor:
    def process_order(self, order):
        """Process order regardless of payment method.
        
        Handles all payment types internally. Payment method is determined
        from order.payment_info. Adding new payment methods requires no
        API changes.
        """
        payment_method = order.payment_info.type
        processor = self._get_payment_processor(payment_method)
        processor.process(order)

# General interface hides payment implementation
# New payment methods added without API changes
```

## Guidelines

### Designing General-Purpose Interfaces

#### Questions to Ask
1. "What's the most general form of this operation?"
2. "Can I express this without special cases?"
3. "What implementation details am I exposing?"
4. "Would this work for related use cases?"
5. "Is this too specific to one scenario?"

#### Process
1. Identify the general concept behind specific requests
2. Design interface around the general concept
3. Verify it handles current use cases simply
4. Check it doesn't expose implementation details
5. Consider: does it handle likely future cases?

### Avoiding Too General
1. Don't anticipate every possible need
2. Avoid excessive configuration
3. Keep common cases simple
4. Add generality incrementally as needed
5. Resist "maybe we'll need..." thinking

### Separating General and Special-Purpose Code
When special-purpose code is needed:
- Keep it separate from general-purpose code
- Don't make general code aware of special cases
- Special code can call general code
- General code shouldn't call special code

Example:
```python
# General-purpose module
class DocumentStorage:
    def save(self, doc): pass
    def load(self, id): pass

# Special-purpose module (separate)
class LegalDocumentStorage:
    def __init__(self):
        self.storage = DocumentStorage()  # Uses general
        
    def save_with_encryption(self, doc):
        """Special handling for legal documents."""
        encrypted = self.encrypt(doc)
        self.storage.save(encrypted)  # Calls general
        self.audit_log.record(doc.id)  # Special-purpose concern
```

## Red Flags
- Multiple similar methods for slight variations
- Method names with "and" in them
- Many parameters with defaults
- Special case checks throughout code
- Hard-coded assumptions about use cases
- Interface exposes implementation details
- Pass-through methods adding no value

## Benefits
- Fewer methods to learn
- Simpler mental model
- Better information hiding
- More reusable code
- Easier to extend
- Less duplication
- More maintainable
