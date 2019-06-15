TITLE Sudoku Solver - Validation
COMMENT *Contains a procedure for validating the input*

IF1
	INCLUDE C:\TASM\sudoku\sud_ct.mac
ENDIF

VAL_CODE SEGMENT PARA PUBLIC 'CODE'	
	ASSUME CS:VAL_CODE
	
	PUBLIC	VALIDATE
	
	;Validates the given memory location. The valid format is: 9 digits in the interval [0,9] + CRLF on each of the 9 lines
	;Input: DS:DX = Address of the memory location which should be validated.
	;				Its size is MSIZE, defined in "sud_ct.mac".
	;Output: AX = ESUCC if valid, AX = EFORMAT if invalid
	VALIDATE PROC FAR
		PUSH SI								;Backup the registers that are used
		PUSH BX
		
		MOV SI,DX							;Move to SI the starting address
		MOV AX,DX							;AX will store the terminating adress of SI
		ADD AX,MSIZE						;AX = starting address + size of the memory location (MSIZE)
		
		L1:									;L1 modifies SI on each run
			MOV BX,0						;Points to the first element on the line
			L2:								;L2 modifies BX on each run
				CMP BX,NR_DCOL				;If BX is in the interval [0, NR_DCOL], the corresponding charachter
				JB VAL_NUM					;should be a digit in the interval [0, 9], otherwise we check for CRLF.
				
				;Validate CRLF				;We reached the end of the line, so we check if it ends in CRLF
				CMP WORD PTR [SI][BX],0A0DH	;Compare the last two bytes to CRLF
				JNE INVALID					;Return an error if it is not equal
				JMP L2_CONT					;Continue the loop otherwise
				
				VAL_NUM:					;We validate the charachter to be a digit in the interval [0,9].
				CMP BYTE PTR [SI][BX],'0'	;If it's < '0' we return an error
				JB	INVALID
				CMP BYTE PTR [SI][BX],'9'	;If it's > '9' we return an error
				JA	INVALID
				
				L2_CONT:
				INC BX						;BX is incremented
				CMP BX,NR_DCOL				;If it reached the last column which contains digit, 
				JBE	L2						;it loops one more time to check CRLF
			
			ADD SI,NR_COL					;SI was incremented by the number of columns
			CMP SI,AX						;If it reached the terminating address, exits the loop
			JB 	L1
			
		MOV AX,ESUCC						;The format is valid. Return success.
		JMP RETURN
		
		INVALID:
		MOV AX,EFORMAT						;There was an invalid charachter. Return the error code.
			
		RETURN:
		POP BX								;Restore the registers
		POP SI
		RET
	VALIDATE ENDP
	
VAL_CODE ENDS

END
