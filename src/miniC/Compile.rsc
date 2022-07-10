module miniC::Compile

import miniC::AST;
import IO;

import python::AST;

Expression extractValue(AbsPossibleValue variableValue) {
	if (integer(int integerValue) := variableValue) {
		// Return the corresponding value as an integer
		return Constant(integerValue);
	} else if (string(str stringValue) := variableValue) {
		// Return the corresponding value as a string
		return Constant(stringValue);
	} else if (variable(Label variableName) := variableValue) {
		// Return the corresponding value as a load
		return Name(variableName, Load());
	}
	throw "Failed to convert miniC AST to Python AST";
}

Calculation extractCalculation(str operator) {
	// Return corresponding calculation
	switch (operator) {
		case "+":
			return Add();
		case "-":
			return Sub();
		case "*":
			return Mult();
		case "/":
			return Div();
		case "%":
			return Mod();
		default:
			throw "Failed to convert miniC AST to Python AST";			
	}
}

Expression extractArithmatic(AbsArithmetic arithmatic) {
	if (base(AbsPossibleValue variableValue) := arithmatic) {
		// Return the base value
		return extractValue(variableValue);
	} else if (nested(AbsArithmetic leftEquation, str arithmeticOperator, AbsArithmetic rightEquation) := arithmatic) {
		// Return the nested calculation
		return BinOp(extractArithmatic(leftEquation), extractCalculation(arithmeticOperator), extractArithmatic(rightEquation));
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractFuntion(AbsFunctionCall func) {
	// Return the corresponding function
	if (function(Label functionName, list[AbsFunctionParameter] params) := func) {
		if (functionName == "printf") {
			// Only 1-argument printf is supported
			if (functionParameter(AbsPossibleValue parameterName) := params[0]) {
				return Expr(Call(Name("print", Load()), [extractValue(parameterName)], []));
			}
		} else if (functionName == "scanf") {
			// Only 2-argument scanf is supported
			if (functionParameter(AbsPossibleValue parameterName) := params[1]) {
				if (variable(Label variableName) := parameterName) {
					return Assign([Name(variableName, Store())], Call(Name("input", Load()), [], []));			
				}
			}
		}
		throw "Unknown function: " + functionName;
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractAssignment(AbsAssignment ass) {
	if (arithmetic(Label variableName, str assignmentOperator, AbsArithmetic arithmeticValue) := ass) {
		// Return the arithmatic operation performed
		return Assign([Name(variableName, Store())], extractArithmatic(arithmeticValue));
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractDeclaration(AbsDeclaration decl) {
	if (withoutAssignment(str variableType, Label variableName) := decl) {
		// Return the variable name with a None value
		return Assign([Name(variableName, Store())], Constant("None"));
	} else if (withAssignment(str variableType, AbsAssignment variableAssignment) := decl) {
		// Return the variable name with the corresponding value
		return extractAssignment(variableAssignment);
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractStatement(AbsStatement statement) {
	// Check the type of statement and extract the corresponding value
	if (declaration(AbsDeclaration decl) := statement) {
		return extractDeclaration(decl);
	} else if (assignment(AbsAssignment ass) := statement) {
		return extractAssignment(ass);
	} else if (functionCall(AbsFunctionCall func) := statement) {
		return extractFuntion(func);
	}
	// If the statement is unknown, throw exception
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractContent(AbsMainContent content) {
	// Check the type of statement and extract the corresponding value
	if (statement(AbsStatement stat) := content) {
		return extractStatement(stat);
	}
	
	else if (returnCall(int returnValue) := content) {
		return Expr(Call(Name("exit", Load()), [Constant(returnValue)], []));
	}
	throw "Failed to convert miniC AST to Python AST";
}

public AbsModule compileProgram(AbsMiniCRoot miniC){
	if (root(list[AbsMiniC] miniCFile) := miniC) {
		// Extract only the body from the miniC file
		if (mainDef(AbsParameterBody parameterBody, AbsMainBody body) := miniCFile[0]) {
			if (mainBody(list[AbsMainContent] mainContent) := body) {
				// On each part of the body, extract the content
				list[Statement] statements = [ extractContent(C) | AbsMainContent C <- mainContent ];
				return \Module(statements, []);
			}
		}
	}
	// If the body is unknown, throw exception
	throw "Failed to convert miniC AST to Python AST";
}
