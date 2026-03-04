# Deep Modules and Abstraction

## Core Principle
The best modules are deep: they have simple interfaces but powerful implementations. They hide complexity behind clean abstractions.

## Module Depth
**Deep modules**:
- Simple interface (small surface area)
- Powerful functionality (large implementation)
- High benefit-to-cost ratio
- Example: Unix file I/O (5 simple calls, complex implementation)

**Shallow modules**:
- Complex interface relative to functionality
- Low benefit-to-cost ratio  
- More cognitive load than value
- Example: Unnecessary wrapper methods

## Interface Design

### What Makes a Good Interface
- Describes WHAT the module does, not HOW
- Minimal parameters needed for common cases
- Hide implementation details completely
- Make common cases simple, rare cases possible
- Each parameter should provide significant value

### Interface vs Implementation
**Interface**: What callers need to know to use the module
- Method signatures
- High-level behavior
- Preconditions and postconditions
- Side effects
- Exception conditions

**Implementation**: How the module works internally
- Algorithms and data structures
- Internal helper methods
- Performance optimizations
- Error handling details

**Critical rule**: Keep implementation details OUT of the interface

## Information Hiding

### What to Hide
- Internal data structures
- Implementation algorithms
- Design decisions that might change
- Internal helper methods
- Temporary/intermediate values

### What to Expose
- Essential functionality
- Abstractions that won't change
- Critical configuration (sparingly)
- Intentional dependencies

### Information Leakage (Red Flag)
When a design decision is reflected in multiple modules:
- Temporal decomposition: Structure based on order of operations
- Shared knowledge: Multiple places know same implementation detail
- Default values: Duplicated across modules
- Format decisions: Multiple modules aware of data format

## When to Apply

### Create Deep Modules When:
- Building reusable components
- Defining APIs or interfaces
- Extracting common functionality
- Reducing system-wide dependencies

### Avoid Shallow Modules:
- Pass-through methods (just call another method)
- Getters/setters without value-add
- Decorators that add little functionality
- Method/class with complex interface, trivial implementation

## Examples

### BAD: Shallow Module
```python
class OrderProcessor:
    def process_order(self, order_id, customer_id, items, payment_method, 
                     shipping_address, billing_address, discount_code,
                     gift_wrap, gift_message, delivery_instructions, 
                     marketing_opt_in, save_payment_method):
        """Process an order with all these parameters."""
        # Minimal implementation - mostly just passes to other methods
        self._validate_customer(customer_id)
        self._validate_items(items)
        self._process_payment(payment_method)
        # ...
        
# Complex interface, simple implementation = SHALLOW
```

### GOOD: Deep Module
```python
class OrderProcessor:
    def process_order(self, order_id, customer_id):
        """Process the order identified by order_id for customer_id.
        
        Retrieves all order details from the order system, validates them,
        processes payment, arranges shipping, and sends confirmation.
        
        Returns: OrderConfirmation with tracking info and estimated delivery.
        Raises: OrderProcessingError if order cannot be completed.
        """
        # Rich implementation hiding complexity:
        # - Fetches order details from database
        # - Validates inventory, customer, payment
        # - Handles payment processing with retries
        # - Coordinates shipping logistics
        # - Manages notifications
        # - Handles edge cases internally
        # Simple interface, powerful implementation = DEEP
```

### BAD: Information Leakage
```java
// Multiple classes know about the file format
public class HTTPRequest {
    public void parse(String request) {
        String[] lines = request.split("\r\n");  // Format knowledge leaked
        // ...
    }
}

public class HTTPResponse {
    public String format() {
        return headers + "\r\n\r\n" + body;  // Same format knowledge leaked
    }
}

public class HTTPLogger {
    public void log(String message) {
        // Also needs to know about \r\n format to parse logs
    }
}
```

### GOOD: Hidden Information
```java
public class HTTPMessage {
    private static final String LINE_SEPARATOR = "\r\n";  // Single point of truth
    private static final String HEADER_END = "\r\n\r\n";
    
    // Only this class knows the format
    protected String[] splitLines(String message) {
        return message.split(LINE_SEPARATOR);
    }
    
    protected String joinLines(String[] lines) {
        return String.join(LINE_SEPARATOR, lines);
    }
}

public class HTTPRequest extends HTTPMessage {
    public void parse(String request) {
        String[] lines = splitLines(request);  // No format knowledge needed
    }
}

public class HTTPResponse extends HTTPMessage {
    public String format() {
        return joinLines(headerLines) + getHeaderEnd() + body;
    }
}
```

### BAD: Pass-Through (Shallow)
```typescript
class UserService {
    constructor(private repository: UserRepository) {}
    
    async getUser(id: string): Promise<User> {
        return this.repository.getUser(id);  // Just passes through
    }
    
    async updateUser(id: string, data: UserData): Promise<void> {
        return this.repository.updateUser(id, data);  // Just passes through
    }
}
```

### GOOD: Deep Abstraction
```typescript
class UserService {
    constructor(
        private repository: UserRepository,
        private cache: Cache,
        private validator: Validator,
        private notifier: Notifier
    ) {}
    
    async getUser(id: string): Promise<User> {
        // Hides caching, validation, error handling complexity
        const cached = await this.cache.get(id);
        if (cached) return cached;
        
        const user = await this.repository.getUser(id);
        if (!user) throw new UserNotFoundError(id);
        
        await this.cache.set(id, user);
        return user;
    }
    
    async updateUser(id: string, data: UserData): Promise<void> {
        // Hides validation, persistence, cache invalidation, notifications
        await this.validator.validate(data);
        
        await this.repository.updateUser(id, data);
        await this.cache.invalidate(id);
        await this.notifier.notifyUserUpdated(id);
    }
}
```

## Guidelines

### Designing Deep Modules
1. Start with the interface comment - what does it do?
2. List what callers MUST know vs what can be hidden
3. Minimize required knowledge in interface
4. Hide all implementation details
5. Consider: "Can I use this without reading the implementation?"

### Avoiding Shallow Modules
- Don't create classes for every small thing (classitis)
- Combine related methods into deeper abstractions
- Eliminate pass-through methods and layers
- Question: "Does this interface provide enough value for its complexity?"

### Information Hiding Checklist
- ✓ Hide data structures behind abstractions
- ✓ Isolate design decisions to single modules
- ✓ Use private/protected access appropriately
- ✓ Default values in one place only
- ✓ Format decisions encapsulated
- ✗ No temporal decomposition (read then write modules)
- ✗ No shared knowledge of internal structure
- ✗ No leaking of configuration details

## Red Flags
- **Shallow module**: Interface not much simpler than implementation
- **Information leakage**: Design decision appears in multiple modules
- **Pass-through method**: Method just calls another with similar signature
- **Temporal decomposition**: Code structure based on execution order

## Benefits
- Easier to understand (less to know)
- Easier to modify (changes localized)
- More reusable (flexible abstractions)
- Less cognitive load (simple interfaces)
- Better encapsulation (hidden complexity)
