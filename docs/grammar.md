Program -> Expr
Program -> Expr Expr

Expr -> VariableDecl
Expr -> FnDecl
Expr -> Return
Expr -> BinaryOp
Expr -> %ident
Expr -> %num

VariableDecl -> 'val'    %ident ':'  Expr '=' Expr ';'
VariableDecl -> 'mut'    %ident ':'  Expr '=' Expr ';'
VariableDecl -> 'const'  %ident ':'  Expr '=' Expr ';'
VariableDecl -> 'static' %ident ':'  Expr '=' Expr ';'
VariableDecl -> 'mut'    %ident ':=' Expr ';'
VariableDecl -> 'val'    %ident ':=' Expr ';'
VariableDecl -> 'const'  %ident ':=' Expr ';'
FnDecl       -> 'const'  %ident ':' 'fn' '(' FnArgs ')' '->' Expr '=' '{' FnBody '}'

FnArgs -> ''
FnArgs -> %ident ':' Expr
FnArgs -> %ident '?' Expr
FnArgs -> %ident ':' Expr ',' FnArgs
FnArgs -> %ident '?' Expr ',' FnArgs

FnBody -> ''
FnBody -> Expr
FnBody -> Expr Expr

Return -> 'return' Expr ';'

BinaryOp -> IdentOrNum '*' Expr
BinaryOp -> IdentOrNum '/' Expr
BinaryOp -> IdentOrNum '+' Expr
BinaryOp -> IdentOrNum '-' Expr

IdentOrNum -> %ident
IdentOrNum -> %num

%ident -> /[a-zA-Z_][a-zA-Z0-9_]*/
%num -> /[0-9]+/
