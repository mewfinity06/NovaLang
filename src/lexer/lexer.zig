const std = @import("std");
const nova = @import("nova");

const NovaError = nova.NovaError;

const token = @import("token.zig");
const Token = token.Token;
const Kind = token.Kind;

pub fn Lexer(name: []const u8, source: []const u8) struct {
    name: []const u8,
    source: []const u8,
    c: u8,
    cur: usize = 0,

    const Self = @This();

    pub fn next(self: *Self) ?Token {
        return self.next_inner() catch |e| switch (e) {
            NovaError.OutOfBounds => {
                nova.err("Reached out of bounds. Source len: {d}, cur len: {d}\n", .{ self.source.len, self.cur });
                return null;
            },
            NovaError.UnknownCharacter => {
                nova.err("Unknown character: `{c}`\n", .{self.c});
                return null;
            },
            NovaError.Unimplemented, NovaError.Todo => return null,
            else => {
                nova.err("Unhandled error: {any}\n", .{e});
                return null;
            },
        };
    }

    fn next_inner(self: *Self) !Token {
        try self.skipWhitespace();
        return switch (self.c) {
            'a'...'z', 'A'...'Z' => {
                const ident = try self.readIdent();
                return .{
                    .word = ident,
                    .kind = .ident,
                };
            },
            ':' => switch (try self.peekC()) {
                '=' => try self.makeToken(.assign, 2),
                else => try self.makeToken(.colon, 1),
            },
            else => return NovaError.UnknownCharacter,
        };
    }

    fn readIdent(self: *Self) ![]const u8 {
        const start = self.cur;
        while (self.cur < self.source.len and std.ascii.isAlphanumeric(self.c)) : (self.cur += 1)
            self.updateC();
        return self.source[start .. self.cur - 1];
    }

    fn updateC(self: *Self) void {
        self.c = self.source[self.cur];
    }

    fn makeToken(self: *Self, kind: Kind, len: usize) !Token {
        const start = self.cur;
        self.cur += len;
        self.updateC();
        return Token.new(self.source[start..self.cur], kind);
    }

    fn peekC(self: *Self) !u8 {
        if (self.cur + 1 >= self.source.len) return NovaError.OutOfBounds;
        return self.source[self.cur + 1];
    }

    fn nextC(self: *Self) !u8 {
        defer self.cur += 1;
        defer self.updateC();
        if (self.cur + 1 >= self.source.len) return NovaError.OutOfBounds;
        return self.source[self.cur];
    }

    fn skipWhitespace(self: *Self) !void {
        if (self.cur > self.source.len) return NovaError.OutOfBounds;
        while (self.cur < self.source.len and std.ascii.isWhitespace(self.c)) : (self.cur += 1)
            self.updateC();
    }
} {
    return .{
        .name = name,
        .source = source,
        .c = if (source.len > 0) source[0] else 0,
    };
}
