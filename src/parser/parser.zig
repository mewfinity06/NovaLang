const nova = @import("nova");
const NovaError = nova.NovaError;

const lexer = @import("../lexer/lexer.zig");
const Lexer = lexer.Lexer;

const token = @import("../lexer/token.zig");
const Token = token.Token;
const Kind = token.Kind;

const node = @import("node.zig");
const Node = node.Node;
const Expr = node.Expr;

pub const Parser = struct {
    l: *Lexer,
    cur_t: Token = Token.EOF,
    expected: Kind = .eof,

    const Self = @This();

    pub fn new(l: *Lexer) Self {
        return .{
            .l = l,
        };
    }

    pub fn next(self: *Self) ?Node {
        return self.nextInner() catch |e| switch (e) {
            NovaError.Unimplemented => return null,
            NovaError.UnknownToken => {
                nova.err("Unknown token kind: {any}\n", .{self.cur_t.kind});
                return null;
            },
            else => {
                nova.err("Unknown error type: {any}\n", .{e});
                return null;
            },
        };
    }

    fn nextInner(self: *Self) !Node {
        self.cur_t = try self.nextToken();

        return switch (self.cur_t.kind) {
            .eof => Node.eof,
            .@"const", .val, .mut => try self.parseDecl(),
            else => NovaError.UnknownToken,
        };
    }

    fn nextToken(self: *Self) !Token {
        const t = self.l.next();
        if (t == null) return error.NoToken;
        return t.?;
    }

    fn expect(self: *Self, kind: Kind) bool {
        self.expected = kind;
        return self.cur_t.kind == kind;
    }

    fn parseExpr(self: *Self) !Expr {
        _ = self;
        return nova.unimplemented("Parser.parseExpr");
    }

    fn parseDecl(self: *Self) !Node {
        const protection = self.cur_t;

        // Get name
        self.cur_t = try self.nextToken();
        if (!self.expect(.ident)) return NovaError.ExpectError;
        const name = self.cur_t;

        self.cur_t = try self.nextToken();
        const kind = if (self.expect(.assign))
            null
        else if (self.expect(.colon))
            try self.nextToken()
        else
            return NovaError.ExpectError;

        const expr = try self.parseExpr();

        return Node{ .stmt = .{ .full = .{ .list = null, .rest = .{ .decl = .{ .variable_decl = .{
            .protection = protection,
            .kind = kind,
            .name = name,
            .expr = expr,
        } } } } } };
    }
};
