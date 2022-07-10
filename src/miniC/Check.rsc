module miniC::Check

import miniC::AST;
import miniC::Syntax;
import miniC::Parser;
import miniC::CST2AST;
import IO;

/*
 * Well-formedness checker
 */

public void checkHardwareConfiguration() {
	start[MiniCRoot] miniCRoot = parseExampleMiniC();
	AbsMiniCRoot abstractMiniCRoot = cst2ast(miniCRoot);
	print(abstractMiniCRoot);
}

// Check if variables are assigned correct values according to their type
public void checkVariableTypes(AbsMiniCRoot root) {

}