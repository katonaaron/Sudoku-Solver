COMMENT *VALIDATES THE INPUT SUDOKU MAP*

IF1
	INCLUDE C:\TASM\sudoku\sud_ct.mac
ENDIF

VAL_CODE SEGMENT PARA PUBLIC 'CODE'	
	ASSUME CS:VAL_CODE
	
	PUBLIC	VALIDATE
	
	;VALIDATES THE INPUT
	;INPUT: DS:DX - THE MAP THAT WAS READ
	;OUTPUT: AX - 0 IF VALID, EFORMAT IF INVALID
	VALIDATE PROC FAR
		PUSH SI
		PUSH BX
		
		MOV SI,DX
		MOV AX,DX
		ADD AX,88
		
		L1:
			MOV BX,0
			L2:
				CMP BX,9
				JB VAL_NUM
				
				;VALIDATE CRLF
				CMP WORD PTR [SI][BX],0A0DH
				JNE INVALID
				JMP L2_CONT
				
				VAL_NUM:
				CMP BYTE PTR [SI][BX],'0'
				JB	INVALID
				CMP BYTE PTR [SI][BX],'9'
				JA	INVALID
				
				L2_CONT:
				INC BX
				CMP BX,9
				JBE	L2
			
			ADD SI,11
			CMP SI,AX
			JBE L1
			
		MOV AX,ESUCC
		JMP RETURN
		
		INVALID:
		MOV AX,EFORMAT
			
		RETURN:
		POP BX
		POP SI
		RET
	VALIDATE ENDP
	
VAL_CODE ENDS

END
