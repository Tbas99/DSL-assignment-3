module C::Syntax

/*
 * Define a concrete syntax for a modified version of C. 
 * The language specification can be found in the associated technical documentation.
 */
 
// Take care of whitespace when parsing
layout Whitespace = [\ \t\n\r]* !>> [\ \t\n\r];

// We can have either our main method or imports in the root
start syntax C 
	= cDef: "int" "main" "()" MainBody mainBody
	| importDef: "#import" Import import
	;
syntax Import 
	= 
	;

syntax MainBody 
	=
	;