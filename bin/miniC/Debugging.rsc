module miniC::Debugging

import ParseTree;
import IO;
import analysis::grammars::Ambiguity;
import Exception;
import miniC::Syntax;
import util::ValueUI;

public void determineAmbiguity(Tree t) {
	text(diagnose(t), 4);
	//print(diagnose(t));
}


/* Auxiliary function for debugging */
public void cst2astDebug(start[MiniCRoot] miniC) {
	try 
		implode(#MiniCRoot, miniC);
	catch IllegalArgument(_, m): 
		println(m);
	
	println("Finished");
}