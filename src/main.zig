const std = @import("std");
const eql = std.mem.eql;

const clap = @import("clap");
const nova = @import("nova");
const NovaError = nova.NovaError;

const lexer = @import("lexer/lexer.zig");
const Lexer = lexer.Lexer;

const parser = @import("parser/parser.zig");
const Parser = parser.Parser;

pub fn main() !void {
    var da = std.heap.DebugAllocator(.{}){};
    defer _ = da.deinit();
    const alloc = da.allocator();

    // Init clap
    const params = comptime clap.parseParamsComptime(
        \\-r, --run         Run the given file
        \\-v, --version     Prints the version
        \\-h, --help        Displays this help message
        \\-f, --file <str>  File to run, needed for --test and --run
        \\    --test <str>  Tests the (lexer | parser)
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
    if (res.args.run != 0) {
        const file_to_run = if (res.args.file) |f| f else {
            nova.err("You must provide a file!\n", .{});
            return;
        };

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
        var p = Parser.new(&l);

        while (p.next()) |n| {
            nova.info("Found {any}\n", .{n});
            if (n == .eof) break;
        }

        return;
    }
    if (res.args.@"test") |test_section| {
        const file_to_run = if (res.args.file) |f| f else {
            nova.err("You must provide a file!\n", .{});
            return;
        };

        // Get path
        var path_buffer: [std.fs.max_path_bytes]u8 = undefined;
        const path = try std.fs.realpath(file_to_run, &path_buffer);

        // Open the file
        const file = try std.fs.openFileAbsolute(path, .{});
        defer file.close();

        const size = (try file.stat()).size;
        const file_buffer: [:0]const u8 = try file.readToEndAllocOptions(alloc, size, null, @enumFromInt(0), 0);
        defer alloc.free(file_buffer);

        if (!eql(u8, test_section, "lexer") and !eql(u8, test_section, "parser")) {
            nova.err("Unknown test parameter `{x}`, expected `lexer` or `parser`\n", .{test_section});
            return;
        }

        // Test lexer
        if (eql(u8, test_section, "lexer")) {
            nova.testing("Lexer");

            var l = Lexer.new(path, file_buffer);
            while (l.next()) |t| {
                if (t.kind == .eof) break;
                nova.info("Found {any} => `{s}`\n", .{ t.kind, t.word });
            }
        }

        // Test parser
        if (eql(u8, test_section, "parser")) {
            nova.testing("Parser");

            var l = Lexer.new(path, file_buffer);
            var p = Parser.new(&l);

            while (p.next()) |n| {
                if (n == .eof) break;
                nova.info("Found {any}\n", .{n});
            }
        }
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
