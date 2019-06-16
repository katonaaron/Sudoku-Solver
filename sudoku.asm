TITLE Sudoku Solver - Main
COMMENT	*The main program of the sudoku solver. Calls the procedures from the other modules*

;External procedures
EXTRN	READ:FAR		;sud_in.asm
EXTRN 	SOLVE:FAR		;sud_sol.asm
EXTRN	VALIDATE:FAR	;sud_val.asm
EXTRN	PERROR:FAR		;sud_err.asm

;Macro libraries
IF1
	INCLUDE C:\TASM\sudoku\sud_ct.mac
	INCLUDE C:\TASM\sudoku\sud_io.mac
ENDIF

DATA SEGMENT PARA PUBLIC 'DATA'
	MAP 	DB	MSIZE DUP('_'),'$'				;This memory location stores the sudoku grid, including the CRLF.
												;The elements of this matrix are accessed as: 
												;Map[i][j] == [SI][BX], where SI = address_of_Map + i * nr_of_columns
												;							  BX = j
	PATH	DB	'C:\TASM\sudoku\sudoku.txt',0	;The path to the input file from which the sudoku grid is read
DATA ENDS

STACK1 SEGMENT PARA STACK 'STACK'
	DW 256 DUP(?)		;256 words are allocated for the stack
STACK1 ENDS

CODE SEGMENT PARA PUBLIC 'CODE'
	START PROC FAR
		ASSUME CS:CODE,DS:DATA,SS:STACK1
		
		PUSH DS			;Initialization for returning
		XOR AX,AX
		PUSH AX
		MOV AX,DATA		;Changes the data segment to DATA
		MOV DS,AX
		
		
		LEA DX,PATH		;Loads the address of the path and the address of the map
		LEA BX,MAP		;They are the input parameters of the READ procedure
		CALL READ		;Calls the function that reads from the input file
		CMP	AX,ESUCC	;The returned value is checked for errors
		JNE PERR		;On error, jump to PERR (print error)
		
		
		LEA DX,MAP		;Loads the adress of the map = input parameter
		CALL VALIDATE	;Calls the function that validates the input
		CMP	AX,ESUCC	;The returned value is checked for errors
		JNE PERR		;On error, jump to PERR (print error)

		LEA DX,MAP		;Loads the adress of the map = input parameter
		CALL SOLVE		;Calls the function that completes all the cells of the sudoku grid = solves the problem
		CMP	AX,ESUCC	;The returned value is checked for errors
		JNE PERR		;On error, jump to PERR (print error)
		
		PSTRING MAP		;There was no error so the result is printed
		RET				;The main program returns
		
		PERR:			
		CALL PERROR		;An error occured so the error message is printed,
		RET				;then the main program returns
	START ENDP
CODE ENDS

END START
