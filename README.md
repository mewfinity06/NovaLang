# NovaLang

compiled language
smart & simple as all langauges should be

## Goals (hopes & dreams)

written in Zig version 0.15.0-dev.870+710632b45

### Milestones

- [ ] Lexing
- [ ] Parsing
- [ ] Code generation
  - [ ] [QBE](https://c9x.me/compile/)
  - [ ] [LLVM](https://llvm.org/docs/GettingStarted.html)
  - [ ] Our own backend? Mayhaps!
    - x86_64-Linux   (fasm)
    - x86_64-Windows (fasm)
    - aarch64-Linux  (gas)
- [ ] **&#x2605;&#x2605; Self-hosting &#x2605;&#x2605;**

### Design

- [ ] C interop
- [ ] Full control over memory

## Syntax and Semantics

### Variables

```js
// mutable foo
mut foo |: 5

// immutable bar, typed
val bar | i8 : -5

// constant BAZ, never mutable
con BAZ | string : "You can't even make me into a mutable!"
```

### Functions

```js
// all functions are marked as `con`
con add | func(a: i8, b: i8) -> i8 :   a + b
con sub | func(a: i8, b: i8) -> i8 : { a - b }

// all functions have a return type
con void_return  | func() -> void : {}

con no_return_valid   | func() -> void : "And I shall be never returned!";
con no_return_invalid | func() -> void : "And I will crash... I am expected to return!"

// function calls
val five_plus_two |: add(5, 2) // 7
val fun_math      |: sub(a: five_plus_two, b: 5 + 2) // 0

// lambdas
con math | func(cal: func(a: i8, b: i8), a: i8) -> i8 : cal(a, 7)

val and_i_am_14 |: math(
  adder: |a: i8, b: i8| a + b,
  a    : 7
)

```

### Structs

#### Struct decleration

```js
con Person | struct : {
  name: string,
  job : string,
  age : u8, 
}

con your_overlord |: Person {
  name: "Ashton",
  job : "Programmer",
  age : 18, 
}

con some_unknown_man | Person : {} // zero initialized memver
```
#### Struct functions and constants

```js
// ...snip... //

con Person.say_hello | func(self: _) -> void : {
  printf("Hello! My name is {} and I am {} years old!\n", self.name, self.name)
  printf("My job is {}\n", self.job);
}

con Person.birthday | func(mut self: _) -> err|void : {
  if self.age >= 99 {
    return err.Dead
  }
  self.age |+ 1
}

```
