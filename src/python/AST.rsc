module python::AST

extend util::Maybe;

alias Identifier = str;

// Root module for the Python AST
data AbsModule(loc src=|unknown:///|)
  = \Module(list[Statement] body, list[TypeIgnore] typeIgnores);

// Statements are presented in the body of the root, loop and statement
data Statement(loc src=|unknown:///|)
  = Assign(list[Expression] targets, Expression \val)
  | Expr(Expression \value)
  | \While(Expression \test, list[Statement] body, list[Statement] orElse)
  | \If(Expression \test, list[Statement] body, list[Statement] orElse)
  ;

// Conditional expressions for statement checking
data Expression(loc src=|unknown:///|)
  = BinOp(Expression lhs, Calculation calc, Expression rhs)
  | BoolOp(BinOp op, list[Expression] exps)
  | UnaryOp(BinOp op, Expression exp)
  | ExprBetweenBraces(Expression expr)
  ;

// Declarations, function calls and comparisons
data Expression
  = Constant(str \strValue)
  | Constant(int \intValue)
  | Constant(real \doubleValue)
  | Call(Expression func, list[Expression] args, list[Keyword] keywords)
  | Compare(Expression lhs, list[CmpOp] ops, list[Expression] comparators)
  ;

// Variable usage
data Expression
  = Name(Identifier id, ExprContext ctx)
  ;

// Arithmatic calculations
data Calculation
  = Add()
  | Sub()
  | Mult()
  | Div()
  | Mod()
  ;

// Functions to store or load variable names and function names from and to memory
data ExprContext
  = Store()
  | \Load()
  ;

// Comparison checks for statements
data CmpOp 
  = Eq() 
  | NotEq() 
  | Lt() 
  | LtE() 
  | Gt() 
  | GtE()
  ;
  
// Comparison checks for booleans
data BinOp
 = Or()
 | And()
 | Not()
 ;

// List of keywords for function calls (is always empty)
data Keyword(loc src = |unknown:///|) 
  = \keyword(Maybe[Identifier] arg, Expression \value);

// List of typeignores for root (is always empty)
data TypeIgnore 
  = typeIgnore(int lineno, str \tag);
