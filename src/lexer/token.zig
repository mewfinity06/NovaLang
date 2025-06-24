const std = @import("std");
const nova = @import("nova");

pub const Token = struct {
    word: []const u8,
    kind: Kind,

    pub const EOF: Token = .{ .word = "eof", .kind = .Eof };

    pub fn new(word: []const u8, kind: Kind) Token {
        return .{ word, kind };
    }

    pub fn fmt(self: Token, allocator: std.mem.Allocator) ![]const u8 {
        const allocPrint = std.fmt.allocPrint;
        return switch (self.kind) {
            .Identifier => try allocPrint(allocator, "Identifier -> `{s}`", .{self.word}),
            .StringLit, .NumberLit, .CharLit => try allocPrint(allocator, "{s} -> `{s}`", .{ self.kind.fmt(), self.word }),
            else => try allocPrint(allocator, "{s}", .{self.kind.fmt()}),
        };
    }
};

pub const Kind = enum {
    // Keywords //
    Mut,
    Val,
    Con,

    Func,
    Struct,

    // Tokens //
    Pipe, // `|`
    Assign, // `|:`
    RArrow, // `->`
    Colon, // `:`
    Sub, // `-`
    Add, // `+`
    Mul, // `*`
    Div, // `/`
    Comma, // `,`
    OParen, // `(`
    CParen, // `)`
    OBrace, // `{`
    CBrace, // `}`
    OBrack, // '['
    CBrack, // `]`
    // Literals //
    Identifier,
    NumberLit,
    StringLit,
    CharLit,

    // EOF //
    Eof,

    pub fn fmt(self: Kind) []const u8 {
        return switch (self) {
            .Mut => "Mut",
            .Val => "Val",
            .Con => "Con",
            .Func => "Func",
            .Struct => "Struct",
            .Pipe => "Pipe",
            .Assign => "Assign",
            .Colon => "Colon",
            .Sub => "Sub",
            .Add => "Add",
            .Mul => "Mul",
            .Div => "Div",
            .Comma => "Comma",
            .OParen => "OParen",
            .CParen => "CParen",
            .OBrace => "OBrace",
            .CBrace => "CBrace",
            .OBrack => "OBrack",
            .CBrack => "CBrack",
            .RArrow => "RArrow",
            .Identifier => "Identifier",
            .NumberLit => "NumberLit",
            .StringLit => "StringLit",
            .CharLit => "CharLit",
            .Eof => "Eof",
        };
    }
};
