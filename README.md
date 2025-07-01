# Nova Lang

## How-To's

### Variables

```odin
// Mutable
mut foo := 42;

// Immutable
val bar := 69;

// Constants
con BAZ := foo + bar;
```

### Functions

```odin
// All functions are constant
con add : fn(a: i32, b: i32) -> i32 = { a + b }
con sub : fn(a: i32, b: i32) -> i32 = {
    return a + b;
}
```
