const std = @import("std");
const print = std.debug.print;

pub const VERSION: []const u8 = "0.0.0";
pub const ABOUT: []const u8 =
    \\Nova is a simple compiled language written in Zig
;

pub const NovaError = error{
    // Lexer Errors
    UnknownCharacter, OutOfBounds,
    // Parser Errors
    UnknownToken, ExpectError,
    // Universal Errors
    Unimplemented, Todo, __UNREACHABLE__ };

const Color = struct {
    pub const info = "\x1b[92m";
    pub const warn = "\x1b[38;5;208m";
    pub const err = "\x1b[91m";
    pub const reset = "\x1b[0m";
};

pub fn info(comptime fmt: []const u8, args: anytype) void {
    print("{s}[INFO]{s} ", .{ Color.info, Color.reset });
    print(fmt, args);
}

pub fn warn(comptime fmt: []const u8, args: anytype) void {
    print("{s}[WARNING]{s} ", .{ Color.warn, Color.reset });
    print(fmt, args);
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    print("{s}[ERROR]{s} ", .{ Color.err, Color.reset });
    print(fmt, args);
}

pub fn unimplemented(comptime whence: []const u8) NovaError {
    print("{s}[UNIMPLEMENTED]{s} {s}\n", .{ Color.err, Color.reset, whence });
    return NovaError.Unimplemented;
}

pub fn todo(comptime item: []const u8) NovaError {
    print("{s}[TODO]{s} {s}\n", .{ Color.info, Color.reset, item });
    return NovaError.Todo;
}

pub fn testing(comptime item: []const u8) void {
    print("{s}[TESTING]{s} {s}\n", .{ Color.info, Color.reset, item });
}
