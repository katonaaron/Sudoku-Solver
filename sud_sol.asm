TITLE Sudoku Solver - Solution
COMMENT *Contains procedures for solving the sudoku*

IF1
	INCLUDE C:\TASM\sudoku\sud_ct.mac
	INCLUDE C:\TASM\sudoku\sud_sol.mac
ENDIF

SOL_CODE SEGMENT PARA PUBLIC 'CODE'
	ASSUME CS:SOL_CODE
	
	PUBLIC SOLVE
	
	;Solves the sudoku. Modifies the given memory location and 
	;replaces every '0' with the value that corresponds to the solution.
	;Input:	DS:DX = The address to the memory location where the sudoku grid is stored.
	;				Its size is MSIZE, defined in "sud_ct.mac"
	;Output: AX = ESUCC if the problem is solved, AX = ENOSOL is the problem could not be solved
	SOLVE PROC FAR
		ASSUME CS:SOL_CODE
		PUSH SI							;Backup the registers that are used
		PUSH BX
		PUSH CX
		
		CALL GET_EMPTY					;Searches for the first '0'. The pointer is returned in SI and BX.
		CMP AX,0						;If GET_EMPTY returned 0, no empty cells left, the problem is solved.
		JE RET_TRUE						;Success will be returned.
		
		MOV CX,'1'						;CX contains the character that is tried to be inserted.
		L3:								;L3 interates to all the digits and tries to insert them in the empty cell. Increments CX on each run.
			CALL IS_SAFE				;Check if the character in CL is safe to be inserted in the current position given by SI and BX		
			CMP AX,0					;If it is not safe, continue the loop
			JE	L3_CONT
										;The character can be safely inserted.
			MOV BYTE PTR [SI][BX],CL	;The character in CL is inserted to the empty spot.
			
			CALL SOLVE					;Recursion is used to insert a character to the next empty spot.			
			CMP AX,ESUCC				;If a solution was found, return success
			JE	RET_TRUE
										;There is no solution when this character is inserted. 
			MOV BYTE PTR [SI][BX],'0'	;So this cell is erased and the loop is continued.
			
			L3_CONT:
			INC CX						;This digit should not be inserted, 
			CMP CX,'9'					;we try again with the next digit
			JBE	L3
			
		JMP RET_FALSE					;No digit can be safely inserted to the empty spot. No solution was found.
		
		RET_TRUE:						;The solution was found
		MOV AX,ESUCC					;Return success
		JMP RETURN
		
		RET_FALSE:						;No solution was found
		MOV AX,ENOSOL					;Return error
		
		RETURN:
		POP CX							;Restore the registers
		POP BX
		POP SI
		RET
	SOLVE ENDP
	
	;Searches for an empty cell ('0') in the sudoku grid. Returns pointer to the first occurence.
	;Input: DS:DX = The address to the memory location where the sudoku grid is stored.
	;				Its size is MSIZE, defined in "sud_ct.mac"
	;Output: AX = 1 if an empty cell was found, AX = 0 if no empty was found	
	;		 SI = Address of the line on which the first '0' was found
	;		 BX = Offset from SI, the column on which the first '0' was found
	GET_EMPTY PROC NEAR		
		MOV SI,DX							;Move to SI the starting address
		MOV AX,DX							;AX will store the terminating adress of SI
		ADD AX,MSIZE						;AX = starting address + size of the memory location (MSIZE)
		
		L1:									;L1 modifies SI on each run
			MOV BX,0						;Points to the first element on the line
			L2:								;L2 modifies BX on each run
				CMP BYTE PTR [SI][BX],'0'	;Checks if the current pointed value is empty
				JE FOUND					;If an empty value was found, return 1
						
				INC BX						;[SI][BX] is not empty, we increment BX to check the next cell
				CMP BX,NR_DCOL
				JB	L2
			
			ADD SI,NR_COL					;We increment SI to check the cells on the next line
			CMP SI,AX
			JB L1
			
		MOV AX,0							;No empty cell was found. Return 0
		RET
		
		FOUND:
			MOV AX,1						;An empty cell was found. Return 1
			RET
	GET_EMPTY ENDP
	
	
	;Checks if a given character(digit) can be safely inserted to the given position.
	;Input: DS:DX = The address to the memory location where the sudoku grid is stored.
	;				Its size is MSIZE, defined in "sud_ct.mac"
	;		CL = The character
	;		SI = Address of the current line
	;		BX = Offset from SI, the current column
	;Output: AX = 1 if the character can be safely inserted, AX = 0 otherwise
	IS_SAFE PROC NEAR
		CALL USED_IN_ROW			;Check if the character appears in the same row
		CMP AX,0
		JNE RET_FALSE1
		
		CALL USED_IN_COL			;Check if the character appears in the same column
		CMP AX,0
		JNE RET_FALSE1
		
		CALL USED_IN_BOX			;Check if the character appears in the same 3x3 box
		CMP AX,0
		JNE RET_FALSE1
		
		CMP BYTE PTR [SI][BX],'0'	;Check if the cell is indeed empty
		JE RET_TRUE1
		
		RET_FALSE1:
		MOV AX,0					;Not safe, return 0
		RET
		
		RET_TRUE1:
		MOV AX,1					;Safe, return 1
		RET
	IS_SAFE ENDP
	
	
	;Checks if a given character appears in a given row
	;Input: CL = The character
	;		SI = Address of the current row
	;Output: AX = 1 if the character appears in the row, AX = 0 otherwise
	USED_IN_ROW PROC NEAR
		PUSH BX							;Backup BX
		
		MOV BX,0						;Start from the first column
		L4:								;L4 increments the column (BX) on each run
			CMP BYTE PTR [SI][BX],CL	;Check if the character appears in the position
			JE FOUND2					;If it is found, return 1
			
			INC BX						;Search for the character in the next cell
			CMP BX,NR_DCOL				
			JB	L4
			
		MOV AX,0						;The character was not found, so 0 is returned
		JMP RETURN2
		
		FOUND2:
		MOV AX,1						;The character was found, so 1 is returned
		
		RETURN2:
		POP BX							;Restore BX
		RET
	USED_IN_ROW ENDP
	
	
	;Checks if a given character appears in a given column
	;Input: DS:DX = The address to the memory location where the sudoku grid is stored.
	;				Its size is MSIZE, defined in "sud_ct.mac"
	;		CL = The character
	;		BX = Number of the current column
	;Output: AX = 1 if the character appears in the row, AX = 0 otherwise
	USED_IN_COL PROC NEAR
		PUSH SI							;Backup SI
		
		MOV SI,DX							;Move to SI the starting address
		MOV AX,DX							;AX will store the terminating adress of SI
		ADD AX,MSIZE						;AX = starting address + size of the memory location (MSIZE)
		
		L5:									;L5 modifies SI to point to the next row on each run
			CMP BYTE PTR [SI][BX],CL		;Check if the character appears in the position
			JE FOUND3						;If it is found, return 1
			
			ADD SI,NR_COL					;Search for the character in the next cell
			CMP SI,AX
			JB L5

			
		MOV AX,0							;The character was not found, so 0 is returned
		JMP RETURN3
		
		FOUND3:
		MOV AX,1							;The character was found, so 1 is returned
		
		RETURN3:
		POP SI								;Restore SI
		RET
	USED_IN_COL ENDP
	
	
	;Checks if a given character appears in the 3x3 box of the given position
	;Input: DS:DX = The address to the memory location where the sudoku grid is stored.
	;				Its size is MSIZE, defined in "sud_ct.mac"
	;		CL = The character
	;		SI = Address of the current line
	;		BX = Offset from SI, the current column
	;Output: AX = 1 if the character appears in the box, AX = 0 otherwise
	USED_IN_BOX PROC NEAR
		PUSH SI								;Backup the registers that are used
		PUSH BX
		PUSH BP
		
		ROW_NUM SI							;Calculates the number of the row
		MOV SI,AX							;Saves the the number of the row in SI
		BOX_START SI						;Calculates the number of the row at the start of the box
		ROW_ADDR AX							;Calculates the pointer to the row at the start of the box
		MOV SI,AX							;Saves it to SI
		
		BOX_START BX						;Calculates the number of the column at the start of the box
		MOV BX,AX							;Saves it to BX	
		
		MOV AX,SI							;AX will store the pointer to the row, for which L6 will exit.
		ADD AX,33							;AX = box_start_row + 3 * number_columns
		PUSH AX								;Push to the stack the exiting value of L6
		PUSH BX								;Push to the stack the pointer to the starting column of the box
		MOV BP,SP							;These elements are accessed trough the BP
		
		
		MOV AX,BX							;AX will store the value, for which L7 will exit if BX reaches it.
		ADD AX,3							;AX = box_start_column + number_of_box_columns
		L6:
			MOV BX,[BP]						;Move to BX the starting column of the box	
			L7:
				CMP BYTE PTR [SI][BX],CL	;Check if the character appears in the position
				JE FOUND4					;If it is found, return 1
				
				INC BX						;Search for the character in the next cell
				CMP BX,AX
				JB L7
			
			ADD SI,11						;Search for the character in the next row
			CMP SI,[BP + 2]					
			JB L6
		
		MOV AX,0							;The character was not found. Return 0
		JMP RETURN4
		
		FOUND4:
		MOV AX,1							;The character was found. Return 1
		
		RETURN4:
		ADD SP,4							;Pop the two elements from the stack
		POP BP								;Restore the registers
		POP BX
		POP SI
		RET
	USED_IN_BOX ENDP
	
	
SOL_CODE ENDS

END