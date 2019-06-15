tasm /zi sudoku.asm
tasm /zi sud_in.asm
tasm /zi sud_sol.asm
tasm /zi sud_val.asm
tasm /zi sud_err.asm
del sud_lib.lib
tlib sud_lib.lib +sud_in.obj +sud_sol.obj +sud_val.obj +sud_err.obj
tlink /v sudoku.obj,,,sud_lib.lib