module miniC::Check

import miniC::AST;
import miniC::Syntax;
import miniC::Parser;
import miniC::CST2AST;
import miniC::Compile;
import IO;

import python::AST;

/*
 * Well-formedness checker
 */

public void checkHardwareConfiguration() {
	start[MiniCRoot] miniCRoot = parseExampleMiniC();
	AbsMiniCRoot abstractMiniCRoot = cst2ast(miniCRoot);
	print(abstractMiniCRoot);
	print("\n\n");
	AbsModule pythonModule = compileProgram(abstractMiniCRoot);
	print(pythonModule);
	print("\n\n");
}