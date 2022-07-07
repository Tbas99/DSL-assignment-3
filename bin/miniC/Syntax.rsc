module miniC::Syntax

/*
 * Define a concrete syntax for a modified version of C. 
 * The language specification can be found in the associated technical documentation.
 */
 
// Take care of whitespace when parsing
layout Whitespace = [\ \t\n\r]* !>> [\ \t\n\r];

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
lexical String = [a-zA-Z] >> [a-zA-Z0-9];
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

// We can have either a main method or includes in the root
start syntax MiniC
	= mainDef: "int" "main" ParameterBody parameterBody MainBody mainBody
	| includeDef: "#include" IncludeBody+ includeBody
	;
	
syntax IncludeBody
	= includeBody: "\<" IncludeLexical includeName "\>"
	;

syntax ParameterBody
	= parameterBody: "(" Parameters* parameters ")"
	;

syntax Parameters
	= parameters: "int" "argc" "," "char" "*" "argv[]"
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
	= ifElse: IfConstruct+ ifStatement ElseIfConstruct* elseifStatement ElseConstruct* elseStatement
	| forLoop: ForLoopConstruct+ forLoopStatement
	| whileLoop: WhileLoopConstruct+ whileLoopStatement
	;

// Construct body can again have either a statement or another construct
syntax ConstructBody
	= statement: Statement statement
	| construct: Construct construct
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
	= equality: Comparison+ equalityComparison
	;


// Syntax related to for loop statements
syntax ForLoopConstruct
	= forLoopConstruct: "for" "(" ForLoopCondition+ forLoopConditions ")" "{" ConstructBody* forLoopBody "}"
	;
syntax ForLoopCondition
	= initialization: MultiVariableInitialization+ loopVariables ";"
	| condition: Comparison+ inequality ";"
	| update: Assignment+ // No closing ; for final expression
	;
syntax MultiVariableInitialization
	= variable: Type+ variableType Identifier+ variableName "=" Value+ variableValue ","?
	;


// Syntax related to while loop statements
syntax WhileLoopConstruct
	= whileLoopConstruct: "while" "(" WhileLoopCondition+ whileLoopConditions ")" "{" ConstructBody* whileLoopBody "}"
	;
syntax WhileLoopCondition
	= equality: Comparison+ equalityComparison
	;


// Syntax related to different type of statements
syntax Statement
	= declaration: Declaration+ variableDeclaration ";"
	| assignment: Assignment+ variableAssignment ";"
	| functionCall: FunctionCall+ externalFunctionCall ";"
	;
syntax Declaration
	= declaration: Type+ variableType Identifier+ variableName
	| declarationAssignment: Type+ variableType Assignment+ variableAssignment
	;
syntax Assignment
	= simple: Identifier+ variable "=" Value+ variableValue
	| arithmetic: Identifier+ variable "=" Arithmetic+ arithmeticValue
	| boolean: Identifier+ variable "=" Comparison+ booleanValue // Can also return a single function call
	;
syntax FunctionCall
	= function: Identifier+ functionName "(" FunctionParameters+ parameters ")"
	;
syntax FunctionParameters
	= parameter: Identifier+ parameterName ","?
	;


// Syntax related to different kinds of operations
syntax Comparison
	= arithmetic: Arithmetic+ leftValue ComparisonOperator+ comparisonOperator Arithmetic+ rightValue
	| logical: Comparison+ leftComparison LogicalOperator+ logicalOperator Comparison+ rightComparison
	| negation: LogicalNegationOperator+ negation Comparison+ comparison
	| function: FunctionCall+ functionCall // Functions can return comparisons!
	;
syntax Arithmetic
	= base: Value+ variableValue
	| nested: Arithmetic+ leftEquation ArithmeticOperator+ arithmeticOperator Arithmetic+ rightEquation
	;


// Define the possible values that could be present in some scopes
syntax Value
	= constant: Integer+
	| literal: String+
	| variable: Identifier+
	;