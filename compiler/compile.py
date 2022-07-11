# Import everything from AST library, used in both AST and compile.py
from ast import *

# Parse AST to Python
ast = eval(open("compilationInput.txt").read())

# Fix missing locations since this otherwise throws <TypeError: required field "lineno" missing from stmt>
fix_missing_locations(ast)

# Executed parsed code
eval(compile(ast, "<ast>", 'exec'))
