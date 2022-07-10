module miniC::CST2AST

import miniC::Syntax;
import miniC::AST;
import String;

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

// Convert file constructs to abstract construct
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

// Convert includes to abstract construct
public AbsIncludeBody mapFileConstruct(IncludeBody body) {
	AbsIncludeBody abstractIncludeBody =
		includeBody("<body.includeName>");
		
	return abstractIncludeBody;
}

// Convert parameters from 'main' to abstract construct
public AbsParameterBody mapFileConstruct(ParameterBody paramBody) {
	AbsParameterBody abstractParameterBody = 
		parameterBody(mapFileConstructs(paramBody.parameters));
		
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

// Convert main method constructs to abstract construct
public AbsMainBody mapFileConstruct(MainBody main) {
	AbsMainBody abstractMainBody = 
		mainBody(mapFileConstructs(main.mainContent));
		
	return abstractMainBody;
}
public list[AbsMainContent] mapFileConstructs(MainContent* mainConstructs) {
	list[AbsMainContent] abstractMainContent =
		[mapFileConstruct(construct) | (MainContent construct <- mainConstructs)];
		
	return abstractMainContent;
}
public AbsMainContent mapFileConstruct(MainContent mainConstruct) {
	switch(mainConstruct) {
		case (MainContent)`<Statement statemnt>`:
			return statement(mapFileConstruct(statemnt));
		case (MainContent)`<Construct constrt>`:
			return construct(mapFileConstruct(constrt));
		case (MainContent)`return <Integer returnValue>;`:
			return returnCall(mapDataTypes(returnValue));
		default:
			throw "No such construct exists";
	}
}

// Convert constructs to abstract construct
public AbsConstruct mapFileConstruct(Construct constructType) {
	switch(constructType) {
		case (Construct)`<IfConstruct ifStatement> <ElseIfConstruct* elseifStatement> <ElseConstruct* elseStatement>`:
			return ifElse(mapFileConstruct(ifStatement), mapFileConstructs(elseifStatement), mapFileConstructs(elseStatement));
		case (Construct)`<ForLoopConstruct forLoopStatement>`:
			return forLoop(mapFileConstruct(forLoopStatement));
		case (Construct)`<WhileLoopConstruct whileLoopStatement>`:
			return whileLoop(mapFileConstruct(whileLoopStatement));
		default:
			throw "No such construct exists";
	}
}
public list[AbsConstructBody] mapFileConstructs(ConstructBody* constructBody) {
	list[AbsConstructBody] abstractConstructBody =
		[mapFileConstruct(construct) | (ConstructBody construct <- constructBody)];
		
	return abstractConstructBody;
}
public AbsConstructBody mapFileConstruct(ConstructBody constructBody) {
	switch(constructBody) {
		case (ConstructBody)`<Statement nestedStmnt>`:
			return nestedStatement(mapFileConstruct(nestedStmnt));
		case (ConstructBody)`<Construct nestedConstrt>`:
			return nestedConstruct(mapFileConstruct(nestedConstrt));
		default:
			throw "No such construct exists";
	}
}

// Convert different types of constructs (If statement)
public AbsIfConstruct mapFileConstruct(IfConstruct ifStatement) {
	AbsIfConstruct abstractIfConstruct =
		ifConstruct(mapFileConstructs(ifStatement.ifConditions), mapFileConstructs(ifStatement.ifBody));
		
	return abstractIfConstruct;
}
public list[AbsIfConstruct] mapFileConstructs(IfConstruct+ ifStatements) {
	list[AbsIfConstruct] abstractIfConstructs =
		[mapFileConstruct(construct) | (IfConstruct construct <- ifStatements)];
		
	return abstractIfConstructs;
}
public list[AbsIfCondition] mapFileConstructs(IfCondition+ ifConditions) {
	list[AbsIfCondition] abstractIfCondition =
		[mapFileConstruct(construct) | (IfCondition construct <- ifConditions)];
		
	return abstractIfCondition;
}
public AbsIfCondition mapFileConstruct(IfCondition ifCondition) {
	AbsIfCondition abstractIfCondition =
		ifEquality(mapFileConstructs(ifCondition.equalityComparison));
		
	return abstractIfCondition;
}
public list[AbsElseIfConstruct] mapFileConstructs(ElseIfConstruct* elseifStatement) {
	list[AbsElseIfConstruct] abstractElseIfConstruct =
		[mapFileConstruct(construct) | (ElseIfConstruct construct <- elseifStatement)];
		
	return abstractElseIfConstruct;
}
public AbsElseIfConstruct mapFileConstruct(ElseIfConstruct elif) {
	AbsElseIfConstruct abstractElseIfConstruct =
		elseIfConstruct(mapFileConstructs(elif.elseifStatements));
		
	return abstractElseIfConstruct;
}
public list[AbsElseConstruct] mapFileConstructs(ElseConstruct* elseStatements) {
	list[AbsElseConstruct] abstractElseConstruct =
		[mapFileConstruct(construct) | (ElseConstruct construct <- elseStatements)];
		
	return abstractElseConstruct;
}
public AbsElseConstruct mapFileConstruct(ElseConstruct elseStatement) {
	AbsElseConstruct abstractElseConstruct =
		elseConstruct(mapFileConstructs(elseStatement.elseBody));
		
	return abstractElseConstruct;
}
// Convert different types of constructs (For Loop)
public AbsForLoopConstruct mapFileConstruct(ForLoopConstruct forLoopStatement) {
	AbsForLoopConstruct abstractForLoopConstruct =
		forLoopConstruct(mapFileConstructs(forLoopStatement.forLoopConditions), mapFileConstructs(forLoopStatement.forLoopBody));
		
	return abstractForLoopConstruct;
}
public list[AbsForLoopCondition] mapFileConstructs(ForLoopCondition+ forLoopConditions) {
	list[AbsForLoopCondition] abstractForLoopConditions =
		[mapFileConstruct(construct) | (ForLoopCondition construct <- forLoopConditions)];
		
	return abstractForLoopConditions;
}
public AbsForLoopCondition mapFileConstruct(ForLoopCondition forLoopCondition) {
	switch(forLoopCondition) {
		case (ForLoopCondition)`<ForLoopVariable+ loopVariables>;`:
			return initialization(mapFileConstructs(loopVariables));
		case (ForLoopCondition)`<Comparison+ inequalities>;`:
			return condition(mapFileConstructs(inequalities));
		case (ForLoopCondition)`<Assignment+ loopUpdates>;`:
			return update(mapFileConstructs(loopUpdates));
		case (ForLoopCondition)`<Assignment+ loopUpdates>`:
			return update(mapFileConstructs(loopUpdates));
		default:
			throw "No such construct exists";
	}
}
public list[AbsForLoopVariable] mapFileConstructs(ForLoopVariable+ loopVariables) {
	list[AbsForLoopVariable] abstractForLoopVariables =
		[mapFileConstruct(construct) | (ForLoopVariable construct <- loopVariables)];
		
	return abstractForLoopVariables;
}
public AbsForLoopVariable mapFileConstruct(ForLoopVariable loopVariable) {
	AbsForLoopVariable abstractForLoopVariable =
		forLoopVariable("<loopVariable.variableType>", "<loopVariable.variableName>", mapFileConstruct(loopVariable.variableValue));
		
	return abstractForLoopVariable;
}
// Convert different types of constructs (While Loop)
public AbsWhileLoopConstruct mapFileConstruct(WhileLoopConstruct whileLoopStatement) {
	AbsWhileLoopConstruct abstractWhileLoopConstruct =
		whileLoopConstruct(mapFileConstructs(whileLoopStatement.whileLoopConditions), mapFileConstructs(whileLoopStatement.whileLoopBody));
		
	return abstractWhileLoopConstruct;
}
public list[AbsWhileLoopCondition] mapFileConstructs(WhileLoopCondition+ whileLoopConditions) {
	list[AbsWhileLoopCondition] abstractWhileLoopConditions =
		[mapFileConstruct(construct) | (WhileLoopCondition construct <- whileLoopConditions)];
		
	return abstractWhileLoopConditions;
}
public AbsWhileLoopCondition mapFileConstruct(WhileLoopCondition condition) {
	AbsWhileLoopCondition abstractWhileLoopCondition =
		whileEquality(mapFileConstructs(condition.equalityComparison));
		
	return abstractWhileLoopCondition;
}

// Convert statement to abstract construct
public AbsStatement mapFileConstruct(Statement statement) {
	switch(statement) {
		case (Statement)`<Declaration variableDeclaration>;`:
			return declaration(mapFileConstruct(variableDeclaration));
		case (Statement)`<Assignment variableAssignment>;`:
			return assignment(mapFileConstruct(variableAssignment));
		case (Statement)`<FunctionCall externalFunctionCall>;`:
			return functionCall(mapFileConstruct(externalFunctionCall));
		default:
			throw "No such construct exists";
	}
}
// Convert different types of statements (Declaration)
public AbsDeclaration mapFileConstruct(Declaration declaration) {
	switch(declaration) {
		case (Declaration)`<Type variableType> <Identifier variableName>`:
			return withoutAssignment("<variableType>", "<variableName>");
		case (Declaration)`<Type variableType> <Assignment variableAssignment>`:
			return withAssignment("<variableType>", mapFileConstruct(variableAssignment));
		default:
			throw "No such construct exists";
	}
}
// Convert different types of statements (Assignment)
public list[AbsAssignment] mapFileConstructs(Assignment+ assignments) {
	list[AbsAssignment] abstractAssignments =
		[mapFileConstruct(construct) | (Assignment construct <- assignments)];
		
	return abstractAssignments;
}
public AbsAssignment mapFileConstruct(Assignment assignment) {
	switch(assignment) {
		case (Assignment)`<Identifier variableName> <AssignmentOperator assignmentOperator> <Arithmetic arithmeticValue>`:
			return arithmetic("<variableName>", "<assignmentOperator>", mapFileConstruct(arithmeticValue));
		case (Assignment)`<Identifier variableName> <AssignmentOperator assignmentOperator> <Comparison booleanValue>`:
			return boolean("<variableName>", "<assignmentOperator>", mapFileConstruct(booleanValue));
		default:
			throw "No such construct exists";
	}
}
// Convert different types of statements (Function call)
public AbsFunctionCall mapFileConstruct(FunctionCall call) {
	AbsFunctionCall abstractFunctionCall =
		function("<call.functionName>", mapFileConstructs(call.parameters));
		
	return abstractFunctionCall;
}
public list[AbsFunctionParameter] mapFileConstructs(FunctionParameter* params) {
	list[AbsFunctionParameter] abstractFunctionParameters =
		[mapFileConstruct(construct) | (FunctionParameter construct <- params)];
		
	return abstractFunctionParameters;
}
public AbsFunctionParameter mapFileConstruct(FunctionParameter parameter) {
	switch(parameter) {
		case (FunctionParameter)`<PossibleValue parameterName>,`:
			return functionParameter(mapFileConstruct(parameterName));
		case (FunctionParameter)`<PossibleValue parameterName>`:
			return functionParameter(mapFileConstruct(parameterName));
		case (FunctionParameter)`<FunctionCall functionCall>,`:
			return nestedFunctionCall(mapFileConstruct(functionCall));
		case (FunctionParameter)`<FunctionCall functionCall>`:
			return nestedFunctionCall(mapFileConstruct(functionCall));
		default:
			throw "No such construct exists";
	}
}

// Comparison operation
public list[AbsComparison] mapFileConstructs(Comparison+ comparisons) {
	list[AbsComparison] abstractComparisons =
		[mapFileConstruct(construct) | (Comparison construct <- comparisons)];
		
	return abstractComparisons;
}
public AbsComparison mapFileConstruct(Comparison comparison) {
	switch(comparison) {
		case (Comparison)`<Arithmetic leftValue> <ComparisonOperator comparisonOperator> <Arithmetic rightValue>`:
			return compArithmetic(mapFileConstruct(leftValue), "<comparisonOperator>", mapFileConstruct(rightValue));
		case (Comparison)`<Comparison leftComparison> <LogicalOperator logicalOperator> <Comparison rightComparison>`:
			return compLogical(mapFileConstruct(leftComparison), "<logicalOperator>", mapFileConstruct(rightComparison));
		case (Comparison)`<LogicalNegationOperator negation> <Comparison comparison>`:
			return compNegation("<negation>", mapFileConstruct(comparison));
		case (Comparison)`<FunctionCall functionCall>`:
			return compFunction(mapFileConstruct(functionCall));
		default:
			throw "No such construct exists";
	}
}

// Arithmetic operation
public AbsArithmetic mapFileConstruct(Arithmetic arithmetic) {
	switch(arithmetic) {
		case (Arithmetic)`<PossibleValue variableValue>`:
			return base(mapFileConstruct(variableValue));
		case (Arithmetic)`(<Arithmetic equation>)`:
			return braces(mapFileConstruct(equation));
		case (Arithmetic)`<Arithmetic leftEquation> <ArithmeticOperator operator> <Arithmetic rightEquation>`:
			return nested(mapFileConstruct(leftEquation), "<operator>", mapFileConstruct(rightEquation));
		default:
			throw "No such construct exists";
	}
}

// Value identities
public AbsPossibleValue mapFileConstruct(PossibleValue val) {
	switch(val) {
		case (PossibleValue)`<Integer integerValue>`:
			return integer(mapDataTypes(integerValue));
		case (PossibleValue)`<Double doubleValue>`:
			return double(mapDataTypes(doubleValue));
		case (PossibleValue)`<Identifier variableName>`:
			return variable("<variableName>");
		case (PossibleValue)`<String stringValue>`:
			return string("<stringValue>");
		default:
			throw "No such construct exists";
	}
}

// Concrete Datatype to rascal primitive conversion
public int mapDataTypes(Integer intgr) {
	return toInt("<intgr>");
}
public real mapDataTypes(Double dbl) {
	return toReal("<dbl>");
}