const std = @import("std");
const nova = @import("nova");
const clap = @import("clap");

const lexer = @import("lexer/lexer.zig");
const Lexer = lexer.Lexer;
const LexerError = lexer.LexerError;
const Token = lexer.Token;

// Make sure to update this every time a new param is added
const NUM_OF_PARAMS: usize = 4;

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();

    // Clap
    const params = comptime clap.parseParamsComptime(
        \\-h, --help         Display this message and exit.
        \\-v, --version      Display nova version
        \\-t, --tests         Run the tests
        \\-r, --run <str>    Run your file
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
        .allocator = allocator,
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0) return try help(&params);
    if (res.args.tests != 0) nova.unimplemented("test flag");
    if (res.args.run) |name| {
        // TODO: Buffered read
        var file = try std.fs.cwd().openFile(name, .{});
        defer file.close();
        const file_size = (try file.stat()).size;
        const buffer = try allocator.alloc(u8, file_size);
        try file.reader().readNoEof(buffer);

        var l = Lexer.new(buffer);
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
                }
            };

            if (t.kind == .Eof) return;
            nova.info("Found {s}\n", .{try t.fmt(allocator)});
        }
    }
}

fn help(params: *const [NUM_OF_PARAMS]clap.Param(clap.Help)) !void {
    const stderr = std.io.getStdErr().writer();
    _ = try stderr.write("Usage: nova ");
    _ = try clap.usage(stderr, clap.Help, params);
    _ = try stderr.write("\n\n");
    return clap.help(stderr, clap.Help, params, .{});
}
