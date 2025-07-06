const std = @import("std");

const clap = @import("clap");
const nova = @import("nova");
const NovaError = nova.NovaError;

const lexer = @import("lexer/lexer.zig");
const Lexer = lexer.Lexer;

pub fn main() !void {
    var da = std.heap.DebugAllocator(.{}){};
    defer _ = da.deinit();
    const alloc = da.allocator();

    // Init clap
    const params = comptime clap.parseParamsComptime(
        \\-r, --run <str>    Run the given file
        \\-v, --version      Prints the version
        \\-h, --help         Displays this help message
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
        .allocator = alloc,
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    // Parse over clap arguments
    if (res.args.help != 0) return usage(&params);
    if (res.args.version != 0) return nova.info("Nova version: {s}\n", .{nova.VERSION});
    if (res.args.run) |file_to_run| {
        // Get path
        var path_buffer: [std.fs.max_path_bytes]u8 = undefined;
        const path = try std.fs.realpath(file_to_run, &path_buffer);

        // Open the file
        const file = try std.fs.openFileAbsolute(path, .{});
        defer file.close();

        const size = (try file.stat()).size;
        const file_buffer: [:0]const u8 = try file.readToEndAllocOptions(alloc, size, null, @enumFromInt(0), 0);
        defer alloc.free(file_buffer);

        var l = Lexer.new(path, file_buffer);

        while (l.next()) |t| {
            nova.info("Found `{s}` => {any}\n", .{ t.word, t.kind });
            if (t.kind == .eof) break;
        }
    } else {
        try usage(&params);
        return nova.err("You must provide a file to be read!\n", .{});
    }
}

// TODO: Pretty this up!!
fn usage(params: []const clap.Param(clap.Help)) !void {
    const stderr = std.io.getStdErr().writer();
    _ = try stderr.print("{s}\n", .{nova.ABOUT});
    _ = try stderr.print("Usage: ", .{});
    _ = try clap.usage(stderr, clap.Help, params);
    _ = try stderr.print("\n", .{});
    _ = try clap.help(stderr, clap.Help, params, .{});
}
