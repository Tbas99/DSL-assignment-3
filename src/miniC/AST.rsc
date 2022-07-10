module miniC::AST

/*
 * Abstract MiniC Syntax Definition
 */

// Each variable is represented as a string rascal datatype
public alias Label = str; // Identifiers

// Root of a MiniC file
public data AbsMiniCRoot
	= root(list[AbsMiniC] miniCFile)
	;

// Contents of the root
public data AbsMiniC
	= mainDef(AbsParameterBody parameterBody, AbsMainBody mainBody)
	| includeDef(AbsIncludeBody includeBody)
	;

// Include wrapper
public data AbsIncludeBody
	= includeBody(str includeName)
	;

// Parameter wrapper
public data AbsParameterBody
	= parameterBody(list[AbsParameter] parameters)
	;
public data AbsParameter
	= parameter(str parameterValue)
	;

// Main method wrapper
public data AbsMainBody
	= mainBody(list[AbsMainContent] mainContent)
	;
public data AbsMainContent
	= statement(AbsStatement statement)
	| construct(AbsConstruct construct)
	| returnCall(int returnValue)
	;

// Construct wrapper
public data AbsConstruct
	= ifElse(AbsIfConstruct ifStatement, list[AbsElseIfConstruct] elseifStatement, list[AbsElseConstruct] elseStatement)
	| forLoop(AbsForLoopConstruct forLoopStatement)
	| whileLoop(AbsWhileLoopConstruct whileLoopStatement)
	;
public data AbsConstructBody
	= nestedStatement(AbsStatement statement)
	| nestedConstruct(AbsConstruct construct)
	;

// If statement Construct
public data AbsIfConstruct
	= ifConstruct(list[AbsIfCondition] ifConditions, list[AbsConstructBody] ifBody)
	;
public data AbsElseIfConstruct
	= elseIfConstruct(list[AbsIfConstruct] elseifStatement)
	;
public data AbsElseConstruct
	= elseConstruct(list[AbsConstructBody] elseBody)
	;
public data AbsIfCondition
	= ifEquality(list[AbsComparison] equalityComparison)
	;

// For loop construct
public data AbsForLoopConstruct
	= forLoopConstruct(list[AbsForLoopCondition] forLoopConditions, list[AbsConstructBody] forLoopBody)
	;
public data AbsForLoopCondition
	= initialization(list[AbsForLoopVariable] loopVariables)
	| condition(list[AbsComparison] inequalities)
	| update(list[AbsAssignment] loopUpdates)
	;
public data AbsForLoopVariable
	= variable(str variableType, Label variableName, AbsPossibleValue variableValue)
	;

// While loop construct
public data AbsWhileLoopConstruct
	= whileLoopConstruct(list[AbsWhileLoopCondition] whileLoopConditions, list[AbsConstructBody] whileLoopBody)
	;
public data AbsWhileLoopCondition
	= whileEquality(list[AbsComparison] equalityComparison)
	;

// Statement wrapper
public data AbsStatement
	= declaration(AbsDeclaration variableDeclaration)
	| assignment(AbsAssignment variableAssignment)
	| functionCall(AbsFunctionCall externalFunctionCall)
	;

// Declaration wrapper
public data AbsDeclaration
	= withoutAssignment(str variableType, Label variableName)
	| withAssignment(str variableType, AbsAssignment variableAssignment)
	;
	
// Assignment wrapper
public data AbsAssignment
	= arithmetic(Label variableName, str assignmentOperator, AbsArithmetic arithmeticValue)
	| boolean(Label variableName, str assignmentOperator, AbsComparison booleanValue)
	;

// Function call wrapper
public data AbsFunctionCall
	= function(Label functionName, list[AbsFunctionParameter] parameters)
	;
public data AbsFunctionParameter
	= functionParameter(AbsPossibleValue parameterName)
	| nestedFunctionCall(AbsFunctionCall functionCall)
	;
	
// Wrappers for comparison/arithmetic operations
public data AbsComparison
	= compArithmetic(AbsArithmetic leftValue, str comparisonOperator, AbsArithmetic rightValue)
	| compLogical(AbsComparison leftComparison, str logicalOperator, AbsComparison rightComparison)
	| compNegation(str negation, AbsComparison comparison)
	| compFunction(AbsFunctionCall functionCall)
	;
public data AbsArithmetic
	= base(AbsPossibleValue variableValue)
	| braces(AbsArithmetic equation)
	| nested(AbsArithmetic leftEquation, str arithmeticOperator, AbsArithmetic rightEquation)
	;
	
// Wrapper for different kind of values we can encounter
public data AbsPossibleValue
	= integer(int integerValue)
	| double(real doubleValue)
	| string(str stringValue)
	| variable(Label variableName)
	;