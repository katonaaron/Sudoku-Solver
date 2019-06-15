tasm /zi sudoku
tasm /zi sud_in
tasm /zi sud_sol
tasm /zi sud_val
tasm /zi sud_err
del sud_lib.lib
tlib sud_lib +sud_in +sud_sol +sud_val +sud_err
tlink /v sudoku,,,sud_lib


