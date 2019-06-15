COMMENT *Procedures for solving the sudoku*

IF1
	INCLUDE C:\TASM\sudoku\sud_ct.mac
ENDIF

BOX_START MACRO POS
	PUSH DX
	PUSH CX
	
	MOV DX,0
	MOV AX,POS
	MOV CX,3
	
	DIV CX
	MOV AX,POS
	SUB AX,DX
	
	POP CX
	POP DX
ENDM

SOL_CODE SEGMENT PARA PUBLIC 'CODE'
	ASSUME CS:SOL_CODE
	
	PUBLIC SOLVE
	
	SOLVE PROC FAR
		ASSUME CS:SOL_CODE
		PUSH SI
		PUSH BX
		PUSH CX
		
		CALL GET_EMPTY
		
		CMP AX,0
		JE RET_TRUE
		
		MOV CX,'1'
		L3:
			CALL IS_SAFE
			
			CMP AX,0
			JE	L3_CONT
			
			MOV BYTE PTR [SI][BX],CL
			
			CALL SOLVE
			
			CMP AX,ESUCC
			JE	RET_TRUE
			
			MOV BYTE PTR [SI][BX],'0'
			
			L3_CONT:
			INC CX
			CMP CX,'9'
			JBE	L3
			
		JMP RET_FALSE
		
		
		RET_TRUE:
		MOV AX,ESUCC
		JMP RETURN
		
		RET_FALSE:
		MOV AX,ENOSOL
		
		RETURN:
		POP CX
		POP BX
		POP SI
		RET
	SOLVE ENDP
	
	GET_EMPTY PROC NEAR
		
		MOV SI,DX
		MOV AX,DX
		ADD AX,MSIZE
		
		L1:
			MOV BX,0
			L2:
				CMP BYTE PTR [SI][BX],'0'
				JE FOUND
				INC BX
				CMP BX,NR_DCOL
				JB	L2
			
			ADD SI,NR_COL
			CMP SI,AX
			JB L1
			
		MOV AX,0
		RET
		
		FOUND:
			MOV AX,1
			RET
	GET_EMPTY ENDP
	
	IS_SAFE PROC NEAR
		CALL USED_IN_ROW
		CMP AX,0
		JNE RET_FALSE1
		
		CALL USED_IN_COL
		CMP AX,0
		JNE RET_FALSE1
		
		CALL USED_IN_BOX
		CMP AX,0
		JNE RET_FALSE1
		
		CMP BYTE PTR [SI][BX],'0'
		JE RET_TRUE1
		
		RET_FALSE1:
		MOV AX,0
		RET
		
		RET_TRUE1:
		MOV AX,1
		RET
	IS_SAFE ENDP
	
	USED_IN_ROW PROC NEAR
		PUSH BX
		
		MOV BX,0
		L4:
			CMP BYTE PTR [SI][BX],CL
			JE FOUND2
			INC BX
			CMP BX,NR_DCOL
			JB	L4

			
		MOV AX,0
		JMP RETURN2
		
		FOUND2:
		MOV AX,1
		
		RETURN2:
		POP BX
		RET
	USED_IN_ROW ENDP
	
	USED_IN_COL PROC NEAR
		PUSH SI
		MOV AX,DX
		ADD AX,MSIZE
		
		MOV SI,DX
		L5:
			CMP BYTE PTR [SI][BX],CL
			JE FOUND3
			ADD SI,NR_COL
			CMP SI,AX
			JB L5

			
		MOV AX,0
		JMP RETURN3
		
		FOUND3:
		MOV AX,1
		
		RETURN3:
		POP SI
		RET
	USED_IN_COL ENDP
	
	USED_IN_BOX PROC NEAR
		PUSH SI
		PUSH BX
		PUSH BP
		
		
		PUSH BX
		PUSH DX
		MOV AX,SI
		SUB AX,DX
		MOV DX,0
		MOV BX,11
		DIV BX
		MOV SI,AX
		POP DX
		POP BX
		
		BOX_START SI
		
		PUSH BX
		MOV BL,11
		MUL BL
		ADD AX,DX
		MOV SI,AX
		POP BX
		
		
		BOX_START BX
		MOV BX,AX
		
		PUSH SI
		PUSH BX
		
		MOV BP,SP
		
		L6:
			MOV BX,[BP]
			L7:
				CMP BYTE PTR [SI][BX],CL
				JE FOUND4
				INC BX
				
				MOV AX,[BP]
				ADD AX,3
				CMP BX,AX
				JB L7
			ADD SI,11
			
			MOV AX,[BP + 2]
			ADD AX,33
			CMP SI,AX
			JB L6
		
		MOV AX,0
		JMP RETURN4
		
		FOUND4:
		MOV AX,1
		
		RETURN4:
		ADD SP,4
		POP BP
		POP BX
		POP SI
		RET
	USED_IN_BOX ENDP
	
	
SOL_CODE ENDS

END