const std = @import("std");
const print = std.debug.print;

pub fn info(comptime fmt: []const u8, args: anytype) void {
    print("INFO: ", .{});
    print(fmt, args);
}

pub fn warn(comptime fmt: []const u8, args: anytype) void {
    print("WARNING: ", .{});
    print(fmt, args);
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    print("ERROR: ", .{});
    print(fmt, args);
}

pub fn unimplemented(place: []const u8) noreturn {
    err("unimplemented `{s}`\n", .{place});
    unreachable;
}
