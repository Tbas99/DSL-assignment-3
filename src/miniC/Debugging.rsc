module miniC::Debugging

import ParseTree;
import IO;
import analysis::grammars::Ambiguity;
import Exception;
import miniC::Syntax;

public void determineAmbiguity(Tree t) {
	print(diagnose(t));
}

/* Auxiliary function for debugging */
public void cst2astDebug(start[MiniC] miniC) {
	try 
		implode(#MiniC, miniC);
	catch IllegalArgument(_, m): 
		println(m);
	
	println("Finished");
}