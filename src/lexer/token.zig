pub const Token = struct {
    word: []const u8,
    kind: Kind,

    const Self = @This();

    pub const EOF: Self = .{
        .word = "EOF",
        .kind = .eof,
    };

    pub fn new(word: []const u8, kind: Kind) Self {
        return .{ .word = word, .kind = kind };
    }
};

pub const Kind = enum {
    // Many Tokens
    assign, // :=
    arrow, // ->
    // Single Tokens
    colon, // :
    semicolon, // ;
    equals, // =
    dot, // .
    oparen, // (
    cparen, // )
    obrack, // {
    cbrack, // }
    osquare, // [
    csquare, // ]
    dash, // -
    comma, // ,
    fslash, // /
    bslash, // \
    question, // ?
    bang, // !
    amper, // &
    pipe, // |

    comment,
    ident,
    numeric,
    string,
    keyword,
    eof,
};
