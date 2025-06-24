const std = @import("std");
const nova = @import("nova");

const Lexer = @import("lexer.zig").Lexer;
const LexerError = @import("lexer.zig").LexerError;
const Token = @import("lexer/token.zig").Token;

pub fn main() !void {
    var lexer = Lexer.new(
        \\con foo |: 5
        \\val bar | i8 : -5
        \\con BAZ | string : "I am a string!"
    );
    while (true) {
        const t = lexer.next() catch |e| {
            switch (e) {
                LexerError.UnknownChar => {
                    // TODO: Add better eof check
                    if (lexer.cur >= lexer.source.len) return;
                    const unknown = lexer.source[lexer.cur];
                    nova.err("Unknown character `{c}`", .{unknown});
                    return;
                },
                else => unreachable,
            }
        };

        if (t.kind == Token.EOF.kind) return;

        nova.info("Found {} (`{s}`)\n", .{ t.kind, t.word });
    }
}
