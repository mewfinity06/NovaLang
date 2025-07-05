const std = @import("std");
const print = std.debug.print;

pub const VERSION: []const u8 = "0.0.0";
pub const ABOUT: []const u8 =
    \\Nova is a simple compiled language written in Zig
;

pub const NovaError = error{
    // Lexer Errors
    UnknownCharacter, OutOfBounds,
    // Universal Errors
    Unimplemented, Todo, __UNREACHABLE__ };

pub fn info(comptime fmt: []const u8, args: anytype) void {
    print("\x1b[92mINFO\x1b[0m: ", .{});
    print(fmt, args);
}

pub fn warn(comptime fmt: []const u8, args: anytype) void {
    print("\x1b[38;5;208mWARNING\x1b[0m: ", .{});
    print(fmt, args);
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    print("\x1b[91mERROR\x1b[0m: ", .{});
    print(fmt, args);
}

pub fn unimplemented(comptime whence: []const u8) NovaError {
    print("\x1b[91mUNIMPLEMENTED\x1b[0m: {s}\n", .{whence});
    return NovaError.Unimplemented;
}

pub fn todo(comptime item: []const u8) NovaError {
    print("\x1b[91mTODO\x1b[0m: {s}\n", .{item});
    return NovaError.Todo;
}
