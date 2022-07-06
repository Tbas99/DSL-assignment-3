module C::Syntax

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

// Define types
lexical Type = "double" | "char" | "int";

// Define program constructs
lexical ConstructKeyword 
	= "if" | "else"
	| "do" | "while"
	| "for" | "break"
	;

// Define binary operators
lexical ArithmeticOperator
	= "*" | "/" | "%" | "+" | "-"
	;
lexical LogicalOperator
	= "\<" | "\>" | "\<=" | "\>=" | "==" | "!=" | "&&" | "||"
	;

// Define separate import lexical as 'types' could be used in the name
lexical IncludeLexical
	= [a-zA-Z]+".h"
	;

// We can have either a main method or includes in the root
start syntax C 
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
	=
	;