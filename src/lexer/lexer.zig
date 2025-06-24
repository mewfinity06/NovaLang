const std = @import("std");
const Token = @import("token.zig").Token;

pub const Lexer = struct {
    source: []const u8,
    cur: usize = 0,

    pub fn new(source: []const u8) Lexer {
        return .{ .source = source };
    }

    pub fn next(self: *Lexer) !Token {
        self.skipWhitespace();

        return error.UnknownToken;
    }

    fn skipWhitespace(self: *Lexer) void {
        while (std.ascii.isWhitespace(self.source[self.cur])) : (self.cur += 1) {}
    }

    fn peekC(self: *Lexer) !u8 {
        return self.source[self.cur];
    }

    fn nextC(self: *Lexer) !u8 {
        defer self.cur += 1;
        return self.source[self.cur];
    }
};
