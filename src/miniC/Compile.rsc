module miniC::Compile

import miniC::AST;
import miniC::Check;
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
	if (arithmetic(Label variableName, str _, AbsArithmetic arithmeticValue) := ass) {
		// Return the arithmatic operation performed
		return Assign([Name(variableName, Store())], extractArithmatic(arithmeticValue));
	} else if (boolean(Label variableName, str _, AbsComparison booleanValue) := ass) {
		// Return the boolean operation performed
		return Assign([Name(variableName, Store())], extractComparison(booleanValue));
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractDeclaration(AbsDeclaration decl) {
	if (withoutAssignment(str _, Label variableName) := decl) {
		// Return the variable name with a None value
		return Assign([Name(variableName, Store())], Constant("None"));
	} else if (withAssignment(str _, AbsAssignment variableAssignment) := decl) {
		// Return the variable name with the corresponding value
		return extractAssignment(variableAssignment);
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractStatement(AbsStatement statement) {
	if (declaration(AbsDeclaration decl) := statement) {
		// Return the declaration performed
		return extractDeclaration(decl);
	} else if (assignment(AbsAssignment ass) := statement) {
		// Return the assignment performed
		return extractAssignment(ass);
	} else if (functionCall(AbsFunctionCall func) := statement) {
		// Return the functioncall performed
		return extractFuntion(func);
	}
	throw "Failed to convert miniC AST to Python AST";
}

BinOp extractBinOp(str operator) {
	// Return the corresponding binary operator
	switch (operator) {
		case "&&":
			return And();
		case "||":
			return Or();
		case "!":
			return Not();
		default:
			throw "Unknown operator: " + operator;
	}
}

CmpOp extractCmpOp(str operator) {
	// Return the corresponding compare operator
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
			throw "Unknown operator: " + operator;
	}
}

Expression extractComparison(AbsComparison comparison) {
	if (compArithmetic(AbsArithmetic leftValue, str comparisonOperator, AbsArithmetic rightValue) := comparison) {
		// Return the result of the arithmatic comparison
		return Compare(extractArithmatic(leftValue), [extractCmpOp(comparisonOperator)], [extractArithmatic(rightValue)]);
	} else if (compLogical(AbsComparison leftComparison, str logicalOperator, AbsComparison rightComparison) := comparison) {
		// Return the result of the logical comparison
		return BoolOp(extractBinOp(logicalOperator), [extractComparison(leftComparison), extractComparison(rightComparison)]);
	} else if (compNegation(str negation, AbsComparison comp) := comparison) {
		// Return the result of the negation comparison
		return UnaryOp(extractBinOp(negation), extractComparison(comp)); 
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractBody(AbsConstructBody body) {
	if (nestedStatement(AbsStatement statement) := body) {
		// Return the nested statement of the body
		return extractStatement(statement);
	} else if (nestedConstruct(AbsConstruct construct) := body) {
		// Return the nested construct of the body
		return extractConstruct(construct);
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractIfElse(AbsIfConstruct ifStatement, list[AbsElseIfConstruct] elseifStatement, list[AbsElseConstruct] elseStatement) {
	// Convert the miniC AST-style if-else to the Python AST-style if-else by recursively calling the body on the else function
	if (ifConstruct(list[AbsIfCondition] ifConditions, list[AbsConstructBody] ifBody) := ifStatement) {
		if (ifEquality(list[AbsComparison] comp) := ifConditions[0]) {
			// Extract the comparison and the body from the if-statement
			Expression expr = extractComparison(comp[0]);
			list[Statement] body = [ extractBody(B) | AbsConstructBody B <- ifBody ];
			if (size(elseifStatement) > 0) {
				// If there are else-ifs remaining, append them recursively to the else-body with an additional if-statement for the if-else condition
				if (elseIfConstruct(list[AbsIfConstruct] statement) := elseifStatement[0]) {
					return If(expr, body, [extractIfElse(statement[0], elseifStatement - elseifStatement[0], elseStatement)]);
				}
			} else if (size(elseStatement) > 0) {
				// If there is only an else remaining, append this recursively to the else-body without an if-statement
				if (elseConstruct(list[AbsConstructBody] elseBody) := elseStatement[0]) {
					list[Statement] eBody = [ extractBody(B) | AbsConstructBody B <- elseBody ];
					return If(expr, body, eBody);
				}
			} else {
				// If no elses are remaining, we have ended in our final recursive step, so return without another function call
				return If(expr, body, []);
			}
		}
	}
	throw "Failed to convert miniC AST to Python AST";
}

Statement extractForLoop(AbsForLoopConstruct construct) {
	// The for-loop is rewritten as a while-loop for easier compilation
	if (forLoopConstruct(list[AbsForLoopCondition] cond, list[AbsConstructBody] forLoopBody) := construct) {
		// Extract the initialization
		Statement initialize;
		if (initialization(list[AbsForLoopVariable] init) := cond[0]) {
			if (forLoopVariable(str _, Label variableName, AbsPossibleValue variableValue) := init[0]) {
				initialize = Assign([Name(variableName, Store())], extractValue(variableValue));
			} else {
				throw "Failed to convert miniC AST to Python AST";
			}
		} else if (update(list[AbsAssignment] init) := cond[0]) {
			initialize = extractAssignment(init[0]);
		} else {
			throw "Failed to convert miniC AST to Python AST";
		}
		
		// Construct the loop
		if (condition(list[AbsComparison] cmp) := cond[1] && update(list[AbsAssignment] loopUpdates) := cond[2]) {
			// We construct a while-loop to parse the C-style for loop
			Expression expr = extractComparison(cmp[0]);
			list[Statement] body = [ extractBody(B) | AbsConstructBody B <- forLoopBody ] + extractAssignment(loopUpdates[0]);
			// We return an always-true if-statement to add the initialization before the while loop
			Statement loop = While(expr, body, []);
			return If(Constant(1), [initialize, loop], []);
		}
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
	if (forLoop(AbsForLoopConstruct forLoopStatement) := construct) {
		return extractForLoop(forLoopStatement);
	} else if (whileLoop(AbsWhileLoopConstruct whileLoopStatement) := construct) {
		return extractWhileLoop(whileLoopStatement);
	} else if (ifElse(AbsIfConstruct ifStatement, list[AbsElseIfConstruct] elseifStatement, list[AbsElseConstruct] elseStatement) := construct) {
		return extractIfElse(ifStatement, elseifStatement, elseStatement);
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
	// Well-formedness check before compilation
	if (checkLogicConstraints(miniC) == false) {
		throw "Failed well-formedness check";
	}

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
					print("Includes are not supported yet for Python compilation.\n\n");
			}
		}
	}
	// If the body is unknown, throw exception
	throw "Failed to convert miniC AST to Python AST";
}
