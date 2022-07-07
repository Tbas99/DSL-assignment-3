module miniC::Compile

import Prelude;
import demo::lang::Pico::Abstract;
import demo::lang::Pico::Assembly;
import demo::lang::Pico::Load;

import python::AST; 
 
alias Instrs = list[Statement];

// Compile declarations

Instrs compileDecls(list[DECL] Decls) = [assign([name(Id, store())], constant(number(47), nothing()), nothing()) | decl(PicoId Id, TYPE _) <- Decls];

// Compile a Pico program

public Instrs compileProgram(PROGRAM P){
  if(program(list[DECL] Decls, list[STATEMENT] _) := P){
     return [*compileDecls(Decls)];
  } else
    throw "Cannot happen";
}

public Instrs compileProgram(str txt) = compileProgram(load(txt));