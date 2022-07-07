module miniC::Syntax

/*
 * Define a concrete syntax for a modified version of C. 
 * The language specification can be found in the associated technical documentation.
 */
 
// Take care of whitespace and comments when parsing
// We ignore comments due to the complexity of them, as they can appear anywhere in the program (similar to whitespaces)
layout Layout
     = (WhiteSpace | Comment)* !>> [\ \t\n\r] !>> "/*" !>> "//"
     ;
     
lexical WhiteSpace = [\ \t\n\r];

// Define standard string identifier
lexical Identifier = [$ A-Z _ a-z] !<< IdentifierChars \ProgramSyntax !>> [$ 0-9 A-Z _ a-z];
lexical IdentifierChars 
    = Letter
    | IdentifierChars LetterOrDigit
    ;
lexical Letter = [A-Za-z$_];
lexical LetterOrDigit = [A-Za-z$_0-9];

// Define keywords so that they are not used in identifiers
keyword ProgramSyntax
	= "main" // Any other syntax here?
	| Type | ConstructKeyword | ArithmeticOperator | LogicalOperator
	;
	
/* Formats */
lexical Integer = [0-9]+;
lexical String = [a-zA-Z]+ >> [a-zA-Z0-9];
lexical Double = [0-9]+("." [0-9]+)?;

// Define types
lexical Type = "double" | "string" | "int";

// Define program constructs
lexical ConstructKeyword 
	= "if" | "else" | "else if"
	| "do" | "while"
	| "for" | "break"
	;

// Define binary operators
lexical ArithmeticOperator
	= "*" | "/" | "%" | "+" | "-"
	;
lexical ComparisonOperator
	= "\<" | "\>" | "\<=" | "\>=" | "==" | "!="
	;
lexical LogicalOperator
	= "&&" | "||"
	;
lexical LogicalNegationOperator
	= "!"
	;

// Define separate import lexical as 'types' could be used in the name
lexical IncludeLexical
	= [a-zA-Z]+".h"
	;
	
// Define lexicals for comments
lexical Comment
	= MultiLineComment
	| EndOfLineComment
	;
lexical MultiLineComment
	= "/*" CommentContent
	;
lexical EndOfLineComment
	= "//" CommentCharacterContent* !>> [\n \r]
	;
lexical CommentContent
	= "*" CommentStarContent
	| NotStar
	;
lexical CommentStarContent
	= "/"
	| "*" CommentStarContent
	| NotStarNorSlash CommentContent
	;
lexical NotStar
	= CommentCharacterContent \ [*]
	| [\n \r]
	;
lexical NotStarNorSlash
	= CommentCharacterContent \ [* /]
	| [\n \r]
	;
lexical CommentCharacterContent
	= ![\\]
	;
	

// We can have either a main method or includes in the root
start syntax MiniC
	= mainDef: "int" "main" ParameterBody parameterBody MainBody mainBody
	| includeDef: "#include" IncludeBody+ includeBody
	;
	
syntax IncludeBody
	= includeBody: "\<" IncludeLexical includeName "\>"
	;

syntax ParameterBody
	= parameterBody: "(" Parameter* parameters ")"
	;

syntax Parameter
	= parameter: "int" "argc" "," "char" "*" "argv[]"
	;

syntax MainBody 
	= mainBody: "{" MainContent* mainContent "}"
	;
	
syntax MainContent
	= statement: Statement statement
	| construct: Construct construct
	| returnCall: "return" Integer returnValue ";"
	;


// Define the syntax for a programming construct
syntax Construct
	= ifElse: IfConstruct ifStatement ElseIfConstruct* elseifStatement ElseConstruct* elseStatement
	| forLoop: ForLoopConstruct forLoopStatement
	| whileLoop: WhileLoopConstruct whileLoopStatement
	;

// Construct body can again have either a statement or another construct
syntax ConstructBody
	= nestedStatement: Statement statement
	| nestedConstruct: Construct construct
	;


// Syntax related to If statements (since there are many variations)
syntax IfConstruct
	= ifConstruct: "if" "(" IfCondition+ ifConditions ")" "{" ConstructBody* ifBody "}"
	;
syntax ElseIfConstruct
	= elseIfConstruct: "else" IfConstruct+ elseifStatement
	;
syntax ElseConstruct
	= elseConstruct: "else" "{" ConstructBody* elseBody "}"
	;
syntax IfCondition
	= ifEquality: Comparison+ equalityComparison
	;


// Syntax related to for loop statements
syntax ForLoopConstruct
	= forLoopConstruct: "for" "(" ForLoopCondition+ forLoopConditions ")" "{" ConstructBody* forLoopBody "}"
	;
syntax ForLoopCondition
	= initialization: ForLoopVariable+ loopVariables ";"
	| condition: Comparison+ inequalities ";"
	| update: Assignment+ loopUpdates // No closing ; for final expression
	;
syntax ForLoopVariable
	= variable: Type variableType Identifier variableName "=" Value variableValue ","?
	;


// Syntax related to while loop statements
syntax WhileLoopConstruct
	= whileLoopConstruct: "while" "(" WhileLoopCondition+ whileLoopConditions ")" "{" ConstructBody* whileLoopBody "}"
	;
syntax WhileLoopCondition
	= whileEquality: Comparison+ equalityComparison
	;


// Syntax related to different type of statements
syntax Statement
	= declaration: Declaration variableDeclaration ";"
	| assignment: Assignment variableAssignment ";"
	| functionCall: FunctionCall externalFunctionCall ";"
	;
syntax Declaration
	= withoutAssignment: Type variableType Identifier variableName
	| withAssignment: Type variableType Assignment variableAssignment
	;
syntax Assignment
	= simple: Identifier variable "=" Value variableValue
	| arithmetic: Identifier variable "=" Arithmetic arithmeticValue
	| boolean: Identifier variable "=" Comparison booleanValue // Can also return a single function call
	;
syntax FunctionCall
	= function: Identifier functionName "(" FunctionParameter+ parameters ")"
	;
syntax FunctionParameter
	= functionParameter: Identifier parameterName ","?
	;


// Syntax related to different kinds of operations
// Optional TODO: Possibly have to add braces here
syntax Comparison
	= compArithmetic: Arithmetic leftValue ComparisonOperator comparisonOperator Arithmetic rightValue
	| left compLogical: Comparison leftComparison LogicalOperator logicalOperator Comparison rightComparison
	> left compNegation: LogicalNegationOperator negation Comparison comparison
	| left compFunction: FunctionCall functionCall // Functions can return comparisons!
	;
syntax Arithmetic
	= base: Value variableValue
	| left nested: Arithmetic leftEquation ArithmeticOperator arithmeticOperator Arithmetic rightEquation
	;


// Define the possible values that could be present in some scopes
syntax Value
	= constant: Integer integerValue
	| literal: String stringValue
	| variable: Identifier variableName
	;