const std = @import("std");
const nova = @import("nova");

const lexer = @import("lexer/lexer.zig");
const Lexer = lexer.Lexer;
const LexerError = lexer.LexerError;
const Token = lexer.Token;

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();

    var l = Lexer.new(
        // This compiles
        // \\con foo |: 5
        // \\val bar | i8 : -5
        // \\con BAZ | string : "I am a string!"
        // // // // // //
        \\con add | func(a: i8, b: i8) -> i8 :   a + b
        \\con sub | func(a: i8, b: i8) -> i8 : { a + b }
    );
    while (true) {
        const t = l.next() catch |e| {
            switch (e) {
                LexerError.UnknownChar => {
                    // TODO: Add better eof check
                    if (l.cur >= l.source.len) return;
                    const unknown = l.source[l.cur];
                    nova.err("Unknown character `{c}`\n", .{unknown});
                    return;
                },
                else => unreachable,
            }
        };

        if (t.kind == Token.EOF.kind) return;

        nova.info("Found {s}\n", .{try t.fmt(allocator)});
    }
}
