const std = @import("std");
const nova = @import("nova");

const NovaError = nova.NovaError;

const token = @import("token.zig");
const Token = token.Token;
const Kind = token.Kind;

pub const Lexer = struct {
    file_name: []const u8,
    contents: [:0]const u8,
    cur: usize = 0,

    const Self = @This();

    pub fn new(file_name: []const u8, contents: [:0]const u8) Self {
        return .{
            .file_name = file_name,
            .contents = contents,
        };
    }

    pub fn next(self: *Self) ?Token {
        return self.nextInner() catch |e| switch (e) {
            NovaError.UnknownCharacter => {
                const c = self.contents[self.cur];
                nova.err("Unknown character `{c}` found\n", .{c});
                return null;
            },
            NovaError.Unimplemented => return null,
            else => {
                nova.err("Unknown error type {any}\n", .{e});
                return null;
            },
        };
    }

    fn nextInner(self: *Self) !Token {
        const eql = std.mem.eql;

        try self.skipWhitespace();
        const c = self.contents[self.cur];
        return switch (c) {
            0 => Token.EOF,
            'a'...'z', 'A'...'Z', '_' => {
                const ident = try self.readIdent();

                // Check for keywords
                if (eql(u8, ident, "mut")) return Token.new(ident, .mut);
                if (eql(u8, ident, "val")) return Token.new(ident, .val);
                if (eql(u8, ident, "const")) return Token.new(ident, .@"const");
                if (eql(u8, ident, "static")) return Token.new(ident, .static);

                return Token.new(ident, .ident);
            },
            '0'...'9' => {
                const numeric = try self.readNumeric();
                return Token.new(numeric, .numeric);
            },
            '"' => {
                const string = try self.readString();
                return Token.new(string[0 .. string.len - 1], .string);
            },
            ':' => switch (try self.peekN(1)) {
                '=' => try self.makeToken(.assign, 2),
                else => try self.makeToken(.colon, 1),
            },
            '-' => switch (try self.peekN(1)) {
                '>' => try self.makeToken(.arrow, 2),
                else => try self.makeToken(.dash, 1),
            },
            '/' => switch (try self.peekN(1)) {
                '/' => {
                    const comment = try self.readComment();
                    return Token.new(comment, .comment);
                },
                else => try self.makeToken(.fslash, 1),
            },
            '=' => try self.makeToken(.equals, 1),
            '.' => try self.makeToken(.dot, 1),
            ';' => try self.makeToken(.semicolon, 1),
            '(' => try self.makeToken(.oparen, 1),
            ')' => try self.makeToken(.cparen, 1),
            '{' => try self.makeToken(.obrack, 1),
            '}' => try self.makeToken(.cbrack, 1),
            '[' => try self.makeToken(.osquare, 1),
            ']' => try self.makeToken(.csquare, 1),
            ',' => try self.makeToken(.comma, 1),
            '?' => try self.makeToken(.question, 1),
            '!' => try self.makeToken(.bang, 1),
            '&' => try self.makeToken(.amper, 1),
            '|' => try self.makeToken(.pipe, 1),
            else => NovaError.UnknownCharacter,
        };
    }

    fn makeToken(self: *Self, kind: Kind, len: usize) !Token {
        defer self.cur += len;
        return .{
            .word = self.contents[self.cur .. self.cur + len],
            .kind = kind,
        };
    }

    fn peekN(self: *Self, n: usize) !u8 {
        if (self.cur + n >= self.contents.len) return NovaError.OutOfBounds;
        return self.contents[self.cur + n];
    }

    fn skipWhitespace(self: *Self) !void {
        while (self.cur < self.contents.len and std.ascii.isWhitespace(self.contents[self.cur])) self.cur += 1;
    }

    fn readIdent(self: *Self) ![]const u8 {
        const start = self.cur;
        while (self.cur < self.contents.len and std.ascii.isAlphanumeric(self.contents[self.cur]) or self.contents[self.cur] == '_') self.cur += 1;
        return self.contents[start..self.cur];
    }

    // TODO: Read floating numbers...
    fn readNumeric(self: *Self) ![]const u8 {
        const start = self.cur;
        while (self.cur < self.contents.len and std.ascii.isDigit(self.contents[self.cur])) self.cur += 1;
        return self.contents[start..self.cur];
    }

    fn readString(self: *Self) ![]const u8 {
        // skip the first "
        self.cur += 1;
        const start = self.cur;
        while (self.cur < self.contents.len and self.contents[self.cur] != '"') self.cur += 1;
        // skip the second "
        self.cur += 1;
        return self.contents[start..self.cur];
    }

    fn readComment(self: *Self) ![]const u8 {
        // skip the `//`
        self.cur += 2;
        const start = self.cur;
        while (self.cur < self.contents.len and self.contents[self.cur] != '\n') self.cur += 1;
        return self.contents[start..self.cur];
    }
};

//const expect = std.testing.expect;

//test "lexing" {
//    const name = "hello_world.nova";
//    const contents: [:0]const u8 =
//        \\const printf := std.io.printf;
//        \\
//        \\const main : fn() -> void = {
//        \\    printf("Hello world!\n");
//        \\}
//    ;
//
//    var l = Lexer.new(name, contents);
//
//    try expect(l.next().?.kind == .keyword);
//}
