# Tern Lang

Check docs for must up-to-date syntax

## How-To's

### Variables

```rust
// Mutable
mut foo := 42;

// Immutable
val bar := 69;

// Constants
const BAZ := foo + bar;
```

### Functions

```rust
// All functions are constant
const add : fn(a: i32, b: i32) -> i32 = { a + b }
const sub : fn(a: i32, b: i32) -> i32 = {
    return a + b;
}
```
