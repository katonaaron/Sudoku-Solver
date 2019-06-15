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
	;Output: AX = ESUCC on success, AX = an error code from "sud_ct.mac" on error
	READ PROC FAR
		PUSH DX				;Backup the registers that are used
		PUSH BX
		
		FOPEN				;Open the file
		
		JNC READFILE		;Check the CF for error
		MOV AX,EFOPEN		;An error has occured on opening the file. Assign the corresponding error code
		JMP RETURN			;Jump to the last instructions
		
		READFILE:
		MOV DX,BX			;Move to DX the address of the destination memory location = input parameter
		MOV BX,AX			;Move to BX the file handle that FOPEN returned			   = input parameter
		FREAD MSIZE			;Read MSIZE bytes from the input file
		
		JNC NR_BYTES		;Check the CF for error
		MOV AX,EFREAD		;An error has occured on reading the file. Assign the corresponding error code
		JMP CLOSEFILE		;Jump to the last instructions
	
		NR_BYTES:			;FREAD returns the number of bytes read. It needs to be equal with MSIZE.
		CMP AX,MSIZE		;AX is compared to MSIZE to determine if indeed MSIZE bytes were read.
		JE	SUCCESS			
		MOV AX,EFORMAT		;The number of bytes that were read are not the same as MSIZE. Assign the error code.
		JMP CLOSEFILE		;Jump to the last instructions
	
		SUCCESS:
		MOV AX,ESUCC		;The data was successfully read from the file. ESUCC = success
		
		CLOSEFILE:		
		FCLOSE				;Close the file
		
		RETURN:
		POP BX				;Restore the registers
		POP DX
		RET
	READ ENDP
	
IN_CODE ENDS

END
