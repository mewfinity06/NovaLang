const Token = @import("../lexer/token.zig").Token;
const Kind = @import("../lexer/token.zig").Kind;

pub const Node = union(enum) {
    stmt: StmtList,
    eof,
};

pub const StmtList = union(enum) {
    empty,
    full: struct { list: ?*StmtList, rest: Stmt },
};

pub const Stmt = union(enum) {
    decl: Decl,
    if_stmt: IfStmt,
    while_stmt: WhileStmt,
    return_stmt: ReturnStmt,
    expr_stmt: ExprStmt,
};

pub const Decl = union(enum) {
    variable_decl: VariableDecl,
};

pub const IfStmt = union(enum) { empty };

pub const WhileStmt = union(enum) { empty };

// return <EXPR>
pub const ReturnStmt = struct {
    expr: Expr,
};

pub const ExprStmt = union(enum) {
    expr: Expr,
};

// (mut | val | const | static) <IDENT> (: Type)? (:= | =) <EXPR>
pub const VariableDecl = struct {
    protection: Token,
    name: Token,
    kind: ?Token,
    expr: Expr,
};

pub const Expr = union(enum) {
    comparison: Comparison,
};

pub const Comparison = struct {
    op: Token,
    lhs: Term,
    rhs: Term,
};

pub const Term = struct {
    op: Token,
    lhs: Factor,
    rhs: Factor,
};

pub const Factor = struct {
    op: Token,
    lhs: Primary,
    rhs: Primary,
};

pub const Primary = union(enum) {
    dot: struct {
        lhs: *Primary,
        rhs: Token,
    },
    call: struct {
        lhs: *Primary,
        rhs: CallArguments,
    },
    atom: Atom,
};

pub const CallArguments = union(enum) {
    empty,
    ArgumentList,
};

pub const ArgumentList = struct {
    list: ?*ArgumentList,
    arg: Argument,
};

pub const Argument = union(enum) {
    arg: Expr,
    named_arg: struct {
        lhs: Token,
        rhs: Expr,
    },
};

pub const Atom = union(enum) {
    paren: *Expr,
    block: BlockBody,
    ident: Token,
    num: Token,
    string: Token,
};

pub const BlockBody = struct {};
