module miniC::Compile

import miniC::AST;
import IO;
import List;

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
	} else if (double(real doubleValue) := variableValue) {
		// Return the corresponding value as an double
		return Constant(doubleValue);
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
	} else if (braces(AbsArithmetic equation) := arithmatic) {
		// Return the equation between braces
		return ExprBetweenBraces(extractArithmatic(equation));
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractFuntion(AbsFunctionCall func) {
	// Return the corresponding function
	if (function(Label functionName, list[AbsFunctionParameter] params) := func) {
		// Use rascal List size function to get params
		if (functionName == "printf" && size(params) == 1) {
			// Only 1-argument printf is supported
			if (functionParameter(AbsPossibleValue parameterName) := params[0]) {
				return Expr(Call(Name("print", Load()), [extractValue(parameterName)], []));
			}
		} else if (functionName == "scanf" && size(params) == 2) {
			// Only 2-argument scanf is supported
			if (functionParameter(AbsPossibleValue param1) := params[0] && functionParameter(AbsPossibleValue param2) := params[1]) {
				if (string(Label var1) := param1 && variable(Label var2) := param2) {
					switch (var1) {
						case "\"%d\"":
							return Assign([Name(var2, Store())], Call(Name("int", Load()), [Call(Name("input", Load()), [], [])], []));							
						case "\"%s\"":
							return Assign([Name(var2, Store())], Call(Name("input", Load()), [], []));					
						case "\"%f\"":
							return Assign([Name(var2, Store())], Call(Name("float", Load()), [Call(Name("input", Load()), [], [])], []));		
						default:
							throw "Unknown variable type: " + var1;
					}	
				}
			}
		}
		throw "Unknown function: " + functionName + ". Either the number of parameters are invalid or the function is undefined.";
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
	throw "Failed to convert miniC AST to Python AST";
}

CmpOp extractCmpOp(str operator) {
	switch (operator) {
		case "\<":
			return Lt();
		case "\>":
			return Gt();
		case "\<=":
			return LtE();
		case "\>=":
			return GtE();
		case "==":
			return Eq();
		case "!=":
			return NotEq();
		default:
			throw "Failed to convert miniC AST to Python AST";
	}
}

Expression extractComparison(AbsComparison comparison) {
	if (compArithmetic(AbsArithmetic leftValue, str comparisonOperator, AbsArithmetic rightValue) := comparison) {
		return Compare(extractArithmatic(leftValue), [extractCmpOp(comparisonOperator)], [extractArithmatic(rightValue)]);
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractBody(AbsConstructBody body) {
	if (nestedStatement(AbsStatement statement) := body) {
		return extractStatement(statement);
	} else if (nestedConstruct(AbsConstruct construct) := body) {
		return extractConstruct(construct);
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractWhileLoop(AbsWhileLoopConstruct construct) {
	if (whileLoopConstruct(list[AbsWhileLoopCondition] conditions, list[AbsConstructBody] body) := construct) {
		// Extract the condition
		if (whileEquality(list[AbsComparison] equalityComparison) := conditions[0]) {
			Expression expr = extractComparison(equalityComparison[0]);
			list[Statement] pyBody = [ extractBody(B) | AbsConstructBody B <- body ];
			// Return the constructed while loop
			return While(expr, pyBody, []);
		}
		throw "Failed to convert miniC AST to Python AST";
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractConstruct(AbsConstruct construct) {
	// Check the construct and return it
	if (whileLoop(AbsWhileLoopConstruct whileLoopStatement) := construct) {
		return extractWhileLoop(whileLoopStatement);
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractContent(AbsMainContent content) {
	// Check the type of statement and extract the corresponding value
	if (statement(AbsStatement stat) := content) {
		return extractStatement(stat);
	} else if(construct(AbsConstruct construct) := content) {
		return extractConstruct(construct);
	} else if (returnCall(int returnValue) := content) {
		return Expr(Call(Name("exit", Load()), [Constant(returnValue)], []));
	}
	throw "Failed to convert miniC AST to Python AST";
}

public AbsModule compileProgram(AbsMiniCRoot miniC){
	if (root(list[AbsMiniC] miniCFile) := miniC) {
		// Extract only the body from the miniC file
		for (int n <- [0 .. size(miniCFile)]) {
			switch (miniCFile[n]) {
				case mainDef(_, AbsMainBody body): {
					if (mainBody(list[AbsMainContent] mainContent) := body) {
						// On each part of the body, extract the content
						list[Statement] statements = [ extractContent(C) | AbsMainContent C <- mainContent ];
						return \Module(statements, []);
					}
				}
				case includeDef(_):
					print("Includes are not supported yet for Python compilation.");
			}
		}
	}
	// If the body is unknown, throw exception
	throw "Failed to convert miniC AST to Python AST";
}
