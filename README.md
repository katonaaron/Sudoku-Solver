# Sudoku-Solver
The “Sudoku Solver” receives an instance of a Sudoku problem, solves it, and prints the result.
## The Rules of Sudoku
A grid of 9x9 cells is given, divided in three 3x3 boxes. Some cells are filled, the others are empty. One must fill all the empty cells with digits between 1 and 9 such that the result must have no duplicates in any row, column or 3x3 box. 
## Input and Output
The program reads the grid from the “sudoku.txt” file. This file must contain 9 lines, each line must have 9 digits between 0 and 9, and each line must end in CRLF. The 0 digit represents the empty cells that will be filled. The result will be printed to the console: a 9x9 grid, each line terminated in CRLF, and all zeroes replaced by a non-zero digit. This result will follow the rules of Sudoku.
## The Algorithm
A backtracking algorithm is used. Starting from the top left corner, the program searches for the first occurrence of an empty cell. Then it tries to insert the digits from 1 to 9 to that cell, one by one. If the insertion of the digit won’t case duplicates in the column, row or the 3x3 box of the empty cell, the solver function recursively calls itself, to fill in the next empty cell. If no digit can be placed in the current empty cell, the program backtracks to the previous cell and gives it a new value. When all the empty cells are completed, the Sudoku is solved.
## Modules and Procedures
### sudoku.asm
The START procedure is the entry point of the program. It initializes the stack for returning and the data segment, calls all the other functions and passes the parameters via the registers. The four main procedures are called from here: READ, VALIDATE, SOLVE and PERROR. If any of the first three functions return a non-zero value in AX, the error message corresponding to the error code is printed using PERROR and the procedure returns immediately.
### sud_ct.mac
Contains constants: the error codes and the size of the memory location that contains the Sudoku grid.
### sud_io.mac
Contains macros for opening, closing and reading from a file, and for printing a string to the console.
### sud_in.asm
The READ procedure opens the file corresponding to the path that was given as a parameter, reads the sudoku grid, checks the number of bytes read, and closes the file. If the operations were successful returns ESUCC = success, else an error code.
### sud_err.asm
The PERROR procedure for the error code received as a parameter, it prints the corresponding error message to the console.
### sud_val.asm
The VALIDATE procedure checks if the given input respects the required input format.
### sud_sol.asm
The SOLVE procedure behaves as described in the “The Algorithm” paragraph. It uses the GET_EMPTY, IS_SAFE, USED_IN_ROW, USED_IN_COL, USED_IN_BOX helper NEAR procedures to find the first empty cell and respectively to determine if the given digit can be safely inserted in the current empty cell.
### sud_sol.mac
Contains macros that are used to calculate the starting address of the box of a given cell.
