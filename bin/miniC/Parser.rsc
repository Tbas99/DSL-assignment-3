module miniC::Parser

import miniC::Syntax;
import ParseTree;

/*
 * Define the parser for the MiniC language. The name of the function must be parseMiniC.
 * This function receives as a parameter the path of the file to parse represented as a loc, and returns a parse tree that represents the parsed program.
 * Note: Define loc as -> loc src = |project://path_to_file|;
 * Example of loc definition: loc src = |project://DSLD2022/src/test/resources/reverseNumber.miniC|;
 */
public start[MiniC] parseMiniC(loc l) {
	return parse(#start[MiniC], l);
}

public Tree parseMiniCTree(loc l) {
	return parse(#start[MiniC], l);
}



/*
 * Auxiliary functions
 */

// Parse ambigious example
public start[MiniC] parseAmb() {
	loc src = |project://DSLD2022/src/test/resources/factorial.miniC|;
	return parse(#start[MiniC], src, allowAmbiguity=true);
}

// Parsing string instead of loc (for troubleshooting purposes hence the parameter allowAmbiguity)
public start[MiniC] parseMiniCString(str txt, bool allowAmbiguity) {
	return parse(#start[MiniC], txt, allowAmbiguity=allowAmbiguity);
}

// Parse basic example
public start[MiniC] parseExampleMiniC() {
	loc src = |project://DSLD2022/src/test/resources/reverseNumber.miniC|;
	return parse(#start[MiniC], src);
}