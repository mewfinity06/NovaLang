# Functions

## Form

Functions are similar to variables but must be const

 - 'const' %ident ':' <FNBODY> '=' '{' <EXPR> '}' ';'

## Examples

```
const add : fn (a: i32, b: i32) -> i32 = {
    return a + b;
};

// Implicit return
const sub : fn (a, b: i32) -> i32 = { a - b };

// Calling functions
const five_plus_two := add(5, 7);
const thirty := sub(a: 38, b: 8);

```
