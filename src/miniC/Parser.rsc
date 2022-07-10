module miniC::Parser

import miniC::Syntax;
import ParseTree;

/*
 * Define the parser for the MiniC language. The name of the function must be parseMiniC.
 * This function receives as a parameter the path of the file to parse represented as a loc, and returns a parse tree that represents the parsed program.
 * Note: Define loc as -> loc src = |project://path_to_file|;
 * Example of loc definition: loc src = |project://DSL-Design-2022-Assignment-3/src/test/resources/reverseNumber.miniC|;
 * Example of loc definition: loc src = |project://DSLD2022/src/test/resources/reverseNumber.miniC|;
 */
public start[MiniCRoot] parseMiniC(loc l) {
	return parse(#start[MiniCRoot], l);
}

public Tree parseMiniCTree(loc l) {
	return parse(#start[MiniCRoot], l);
}



/*
 * Auxiliary functions
 */

// Parse ambigious example
public start[MiniCRoot] parseAmb() {
	loc src = |project://DSL-Design-2022-Assignment-3/src/test/resources/factorial.miniC|;
	return parse(#start[MiniCRoot], src, allowAmbiguity=true);
}

// Parsing string instead of loc (for troubleshooting purposes hence the parameter allowAmbiguity)
public start[MiniCRoot] parseMiniCString(str txt, bool allowAmbiguity) {
	return parse(#start[MiniCRoot], txt, allowAmbiguity=allowAmbiguity);
}

// Parse basic example
public start[MiniCRoot] parseExampleMiniC() {
	loc src = |project://DSL-Design-2022-Assignment-3/src/test/resources/reverseNumber.miniC|;
	return parse(#start[MiniCRoot], src, allowAmbiguity=true);
}