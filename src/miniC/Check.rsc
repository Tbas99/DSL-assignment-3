module miniC::Check

import miniC::AST;
import miniC::Syntax;
import miniC::Parser;
import miniC::CST2AST;
import miniC::Compile;

// Other imports
import IO;

import python::AST;

/*
 * Well-formedness checker
 */

public bool checkLogicConstraints(AbsMiniCRoot root) {
	return (checkValidityDeclaration(root) && checkValidityManipulation(root) && checkVariablesInitialization(root));
}

// Check if variables are assigned correct values according to their type at declaration
public bool checkValidityDeclaration(AbsMiniCRoot root) {
	bool correctDeclaration = true;
	
	visit(root) {
		case withAssignment(str variableType, AbsAssignment variableAssignment): {
			correctDeclaration = correctAssignmentReturnType(variableAssignment, variableType);
			
			if (correctDeclaration == false) {
				return false;
			}
		}
	}
	
	return correctDeclaration;
}


// Check if variables are manipulated correctly throughout the program
public bool checkValidityManipulation(AbsMiniCRoot root) {
	bool correctVariableTreatment = true;
	
	// Look for all declarations and check if future manipulations satisfy the type constraint
	for (/declaration(AbsDeclaration variableDeclaration) := root) {
		switch(variableDeclaration) {
			case withoutAssignment(str variableType, Label variableName): {
				for (/arithmetic(Label equationVar, _, AbsArithmetic arithmeticValue) := root) {
					if (variableName == equationVar) {
						correctVariableTreatment = correctArithmeticReturnType(arithmeticValue, variableType);
						
						if (correctVariableTreatment == false) {
							return false;
						}
					}
				}
			}
			case withAssignment(str variableType, AbsAssignment variableAssignment): {
				for (/arithmetic(Label equationVar, _, AbsArithmetic arithmeticValue) := root) {
					if (variableAssignment.variableName == equationVar) {
						correctVariableTreatment = correctArithmeticReturnType(arithmeticValue, variableType);
						
						if (correctVariableTreatment == false) {
							return false;
						}
					}
				}
			}
		}
	}

	return correctVariableTreatment;
}

public bool checkVariablesInitialization(AbsMiniCRoot root) {
	bool allVariablesAreInitialized = true;

	// For each variable found...
	for (/variable(Label variableName) := root) {
		print(variableName);
		if (checkVariableInitialization(root, variableName) == false) {
			return false;
		}
	}
	
	return allVariablesAreInitialized;
}

// Check if variables are defined when they are used
public bool checkVariableInitialization(AbsMiniCRoot root, Label varName) {
	bool variableUsedIsInitialized = false;
	
	// There should be a matching declaration
	visit(root) {
		case withoutAssignment(str variableType, Label foundInitVarName): {
			if (varName == foundInitVarName) {
				variableUsedIsInitialized = true;
			}
		}
		case withAssignment(str variableType, AbsAssignment variableAssignment): {
			if (varName == variableAssignment.variableName) {
				variableUsedIsInitialized = true;
			}
		}
	}
	
	return variableUsedIsInitialized;
}


// Utility methods
public bool correctAssignmentReturnType(AbsAssignment variableAssignment, str expectedType) {
	bool correctAssignments = true;

	bottom-up visit(variableAssignment) {
		case double(_): {
			if (expectedType != "double") {
				correctAssignments = false;
			}
		}
		case integer(_): {
			if (expectedType != "int") {
				correctAssignments = false;
			}
		}
		case string(_): {
			if (expectedType != "string") {
				correctAssignments = false;
			}
		}
	}

	return correctAssignments;
}
public bool correctArithmeticReturnType(AbsArithmetic equation, str expectedType) {
	bool correctAssignments = true;
	
	bottom-up visit(equation) {
		case double(_): {
			if (expectedType != "double") {
				correctAssignments = false;
			}
		}
		case integer(_): {
			if (expectedType != "int") {
				correctAssignments = false;
			}
		}
		case string(_): {
			if (expectedType != "string") {
				correctAssignments = false;
			}
		}
	}

	return correctAssignments;
}


public void checkHardwareConfiguration() {
	start[MiniCRoot] miniCRoot = parseExampleMiniC();
	AbsMiniCRoot abstractMiniCRoot = cst2ast(miniCRoot);
	print(abstractMiniCRoot);
	print("\n\n");
	AbsModule pythonModule = compileProgram(abstractMiniCRoot);
	print(pythonModule);
	print("\n\n");
}