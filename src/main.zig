const std = @import("std");
const print = std.debug.print;

pub const NovaError = error{
    // Lexing Errors

    // Parsing Errors

    // General Errors
    Unimplemented,
    Todo,
};

pub fn info(comptime fmt: []const u8, args: anytype) void {
    print("INFO: \n", .{});
    print(fmt, args);
}

pub fn warn(comptime fmt: []const u8, args: anytype) void {
    print("WARN: ", .{});
    print(fmt, args);
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    print("ERR: ", .{});
    print(fmt, args);
}

pub fn unimplemented(comptime whence: []const u8) NovaError {
    print("Unimplemented: {s}\n", .{whence});
    return .Unimplemented;
}

pub fn todo(comptime items: []const u8) NovaError {
    print("TODO: {s}\n", .{items});
    return .Todo;
}
