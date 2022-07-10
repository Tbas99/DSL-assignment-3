module miniC::Plugin

import ParseTree;
import util::IDE;
import miniC::Check;
import miniC::Parser;
import miniC::CST2AST;

bool checkWellformedness(loc fil) {
	// Parsing
	&T resource = parseMiniC(fil);
	
	// Transform the parse tree into an abstract syntax tree
	&T ast = cst2ast(resource);
	
	// Check the well-formedness of the program
	return checkLogicConstraints(ast);
}

void main() {
	registerLanguage("MiniC - DSLD", "miniC", Tree(str _, loc path) {
		return parseMiniC(path);
  	});
}