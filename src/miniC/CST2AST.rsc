module miniC::CST2AST

import miniC::Syntax;
import miniC::AST;
import IO;

/*
 * Maps Concrete MiniC Syntax to Abstract Syntax
 */

public AbsMiniCRoot cst2ast(start[MiniCRoot] miniC) {
	// Unwrap the concrete syntax
	MiniCRoot fileRoot = miniC.top;
	
	// Construct the abstract syntax, iteratively
	AbsMiniCRoot abstractMiniCRoot = 
		root(mapFileConstructs(fileRoot.miniCFile));
	
	// Return the abstract syntax
	return abstractMiniCRoot;
}

public list[AbsMiniC] mapFileConstructs(MiniC+ fileContents) {
	list[AbsMiniC] abstractMiniCFileComponents =
		[mapFileConstruct(construct) | (MiniC construct <- fileContents)];
	
	return abstractMiniCFileComponents;
}

public AbsMiniC mapFileConstruct(MiniC fileComponent) {
	switch(fileComponent) {
		case (MiniC)`int main <ParameterBody parameterBody> <MainBody mainBody>`:
			return mainDef(mapFileConstruct(parameterBody), mapFileConstruct(mainBody));
		case (MiniC)`#include <IncludeBody includeBody>`:
			return includeDef(mapFileConstruct(includeBody));
		default:
			throw "No such construct exists";
	}
}

// TODO: Create mapping for main body and include body

public AbsParameterBody mapFileConstruct(ParameterBody parameterBody) {
	AbsParameterBody abstractParameterBody = 
		parameterBody(mapFileConstructs(parameterBody.parameters));
		
	return abstractParameterBody;
}

public list[AbsParameter] mapFileConstructs(Parameter* parameters) {
	list[AbsParameter] abstractParameters =
		[mapFileConstruct(construct) | (Parameter construct <- parameters)];
		
	return abstractParameters;
}

public AbsParameter mapFileConstruct(Parameter param) {
	switch(param) {
		case (Parameter)`int argc, string argv`:
			return parameter("int argc, string argv");
		default:
			throw "No such construct exists";
	}
}

