const std = @import("std");

pub const Token = struct {
    word: []const u8,
    kind: Kind,

    pub const EOF: Token = .{ .word = "eof", .kind = .Eof };

    pub fn new(word: []const u8, kind: Kind) Token {
        return .{ word, kind };
    }
};

pub const Kind = enum {
    // Tokens
    Pipe, // `|`
    Assign, // `|:`
    Colon, // `:`
    Sub, // `-`
    Add, // `+`
    Mul, // `*`
    Div, // `/`

    // Literals //
    Identifier,
    NumberLit,
    StringLit,
    CharLit,

    // EOF //
    Eof,
};
