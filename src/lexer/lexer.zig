const std = @import("std");
const nova = @import("nova");
pub const Token = @import("token.zig").Token;
pub const Kind = @import("token.zig").Kind;

pub const LexerError = error{UnknownChar};

pub const Lexer = struct {
    source: []const u8,
    c: u8 = 0,
    cur: usize = 0,

    pub fn new(source: []const u8) Lexer {
        return .{ .source = source };
    }

    pub fn next(self: *Lexer) LexerError!Token {
        const eql = std.mem.eql;

        self.skipWhitespace();

        switch (self.c) {
            // Check for identifiers
            'a'...'z', 'A'...'Z', '_' => {
                const ident = try self.readIdent();
                // Keywords
                if (eql(u8, ident, "val")) return .{ .word = ident, .kind = .Val };
                if (eql(u8, ident, "mut")) return .{ .word = ident, .kind = .Mut };
                if (eql(u8, ident, "con")) return .{ .word = ident, .kind = .Con };
                if (eql(u8, ident, "func")) return .{ .word = ident, .kind = .Func };
                if (eql(u8, ident, "struct")) return .{ .word = ident, .kind = .Struct };
                return .{ .word = ident, .kind = .Identifier };
            },
            // Check for numberics
            '0'...'9' => {
                const number = try self.readNumeric();
                return .{ .word = number, .kind = .NumberLit };
            },
            '|' => switch (try self.peekC()) {
                ':' => return self.makeToken(.Assign, 2),
                else => return self.makeToken(.Pipe, 1),
            },
            '"' => {
                const string = try self.readString();
                return .{ .word = string, .kind = .StringLit };
            },
            '\'' => {
                const char = try self.readChar();
                return .{ .word = char, .kind = .CharLit };
            },
            '-' => switch (try self.peekC()) {
                '>' => return self.makeToken(.RArrow, 2),
                else => return self.makeToken(.Sub, 1),
            },
            '{' => return self.makeToken(.OBrace, 1),
            '}' => return self.makeToken(.CBrace, 1),
            '[' => return self.makeToken(.OBrack, 1),
            ']' => return self.makeToken(.CBrack, 1),
            '(' => return self.makeToken(.OParen, 1),
            ')' => return self.makeToken(.CParen, 1),
            ':' => return self.makeToken(.Colon, 1),
            '+' => return self.makeToken(.Add, 1),
            '*' => return self.makeToken(.Mul, 1),
            '\\' => return self.makeToken(.Div, 1),
            ',' => return self.makeToken(.Comma, 1),
            else => return LexerError.UnknownChar,
        }

        return Token.EOF;
    }

    fn makeToken(self: *Lexer, kind: Kind, len: usize) Token {
        defer self.cur += len;
        const end = self.cur + len;
        return Token{ .word = self.source[self.cur..end], .kind = kind };
    }

    fn readIdent(self: *Lexer) LexerError![]const u8 {
        const start = self.cur;
        var end = self.cur;
        while (std.ascii.isAlphanumeric(self.c)) : (end += 1) {
            defer self.cur += 1;
            self.c = self.source[self.cur];
        }
        self.cur -= 1;
        return self.source[start .. end - 1];
    }

    fn readNumeric(self: *Lexer) LexerError![]const u8 {
        const start = self.cur;
        var end = self.cur;
        while (std.ascii.isDigit(self.c)) : (end += 1) {
            defer self.cur += 1;
            self.c = self.source[self.cur];
        }
        self.cur -= 1;
        return self.source[start .. end - 1];
    }

    // TODO: read escape characters
    fn readString(self: *Lexer) LexerError![]const u8 {
        defer self.cur += 1;
        self.cur += 1;
        self.c = self.source[self.cur];
        const start = self.cur;
        var end = self.cur;
        while (self.c != '"') : (end += 1) {
            defer self.cur += 1;
            self.c = self.source[self.cur];
        }
        self.cur -= 1;
        return self.source[start .. end - 1];
    }

    fn readChar(self: Lexer) LexerError![]const u8 {
        _ = self;
        nova.unimplemented("readChar");
    }

    fn skipWhitespace(self: *Lexer) void {
        while (self.cur < self.source.len and std.ascii.isWhitespace(self.source[self.cur])) {
            self.cur += 1;
        }
        if (self.cur < self.source.len) {
            self.c = self.source[self.cur];
        } else {
            self.c = 0;
        }
    }
    fn peekC(self: *Lexer) LexerError!u8 {
        return self.source[self.cur + 1];
    }

    fn nextC(self: *Lexer) LexerError!u8 {
        defer self.cur += 1;
        return self.source[self.cur];
    }
};
