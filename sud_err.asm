TITLE Sudoku Solver - Errors
COMMENT *Contains a procedure for printing error messages*

IF1
	INCLUDE C:\TASM\sudoku\sud_ct.mac	
	INCLUDE C:\TASM\sudoku\sud_io.mac
ENDIF

ERR_DATA SEGMENT PARA PUBLIC 'DATA'
	;Error messages
	ERR_SUCC		DB	'Error: No error$'
	ERR_UNEXP		DB	'Error: Unexpected error$'
	ERR_FOPEN		DB	'Error: The file could not be opened$'
	ERR_FREAD		DB	'Error: The file could not be read$'
	ERR_FORMAT		DB	'Error: Invalid input format$'
	ERR_NOT_SOLVED	DB	'Error: The sudoku could not be solved. Invalid input$'
ERR_DATA ENDS

ERR_CODE SEGMENT PARA PUBLIC 'CODE'	
	ASSUME CS:ERR_CODE,DS:ERR_DATA
	
	PUBLIC	PERROR
	
	;Prints an error message for the given error code.
	;Input: AX = error code, defined in "sud_ct.mac"
	;Output: none
	PERROR PROC FAR
		PUSH DS					;Backup the registers that are used
		PUSH AX
		
		PUSH AX					;Backup AX
		MOV AX,ERR_DATA			;Changes the data segment 
		MOV DS,AX				;to ERR_DATA
		POP AX					;Restore AX
	
		CMP AX,ESUCC			;AX is compared to each error code
		JE SUCCESS				;If it matches an error code, it jumps to the line
								;where the corresponding error message is printed
		CMP AX,EFOPEN
		JE	E_FOPEN
		
		CMP	AX,EFREAD
		JE	E_FREAD
		
		CMP AX,EFORMAT
		JE	FORMAT
		
		CMP AX,ENOSOL
		JE	NO_SOL
		
		PSTRING	ERR_UNEXP		;The error code doesn't match the ones from "sud_ct.mac"
		JMP FINALLY				;Prints the "unexpected error" message and jumps to the last instructions
		
		SUCCESS:				;The error message is printed, then a jump is made to the last instructions
			PSTRING ERR_SUCC
			JMP FINALLY
		E_FOPEN:
			PSTRING ERR_FOPEN
			JMP FINALLY
		E_FREAD:
			PSTRING ERR_FREAD
			JMP FINALLY
		FORMAT:
			PSTRING ERR_FORMAT
			JMP	FINALLY
		NO_SOL:
			PSTRING ERR_NOT_SOLVED
			JMP FINALLY
		
		FINALLY: 				;The registers are restored, and 
		POP AX					;the program returns
		POP DS
		RET
	PERROR ENDP
	
ERR_CODE ENDS

END
