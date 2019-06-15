TITLE Sudoku Solver - Input
COMMENT *Contains a procedure for reading the sudoku from the input file*

IF1
	INCLUDE C:\TASM\sudoku\sud_ct.mac
	INCLUDE C:\TASM\sudoku\sud_io.mac
ENDIF

IN_CODE SEGMENT PARA PUBLIC 'CODE'	
	ASSUME CS:IN_CODE
	
	PUBLIC	READ
	
	;Reads the sudoku grid (and the CRLF at each line end) from the file
	;at the given path and stores it in the given memory address.
	;Input: DS:DX = Address of the path to the input file. The path is a string terminated in 0.
	;		DS:BX = Address of the memory location where the read data will be stored.
	;				Its size is MSIZE, defined in "sud_ct.mac".
	READ PROC FAR
		PUSH DX
		PUSH BX
		
		;Open the file
		FOPEN
		
		JNC READFILE
		MOV AX,EFOPEN
		JMP RETURN
		
		READFILE:
		MOV DX,BX
		MOV BX,AX
		FREAD MSIZE
		
		JNC SUCCESS
		MOV AX,EFREAD
		JMP CLOSEFILE
	
		SUCCESS:
		MOV AX,ESUCC
		
		CLOSEFILE:
		PUSH AX
		FCLOSE
		POP AX
		
		RETURN:
		POP BX
		POP DX
		RET
	READ ENDP
	
IN_CODE ENDS

END
