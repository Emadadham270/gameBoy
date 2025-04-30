	AREA    MYDATA, DATA, READONLY
Level1Map
	DCB 0xD1
	DCB 0xD9
	DCB 0xCB
    DCB 0x81
	DCB 0xA5
	DCB 0x81

Leve1StartCell DCB 36
		;--- Colors ---
Red     	   EQU 0XF800 
Green   	   EQU 0x07E0
Blue    	   EQU 0x001F 
Yellow  	   EQU 0xFFE0
White   	   EQU 0xFFFF
Black		   EQU 0x0000	

	AREA USEABLE, DATA, READWRITE

SnakeMap
	DCB 0x00
	DCB 0x00
	DCB 0x00
    DCB 0x00
	DCB 0x00
	DCB 0x00
	
	AREA    CODEY, CODE, READONLY
    IMPORT  TFT_WriteCommand
    IMPORT  TFT_WriteData
    IMPORT  TFT_DrawImage
	IMPORT  TFT_Filldraw4INP
    IMPORT  delay
	IMPORT  GET_state
	

;------------------------
; TFT_DrawMap
;------------------------
TFT_DrawMap    FUNCTION
	PUSH {R0-R12, LR}
	;TODO
	
	POP {R0-R12, PC}
	ENDFUNC

;------------------------
; Draw_Snake_Movement
;------------------------
Draw_Snake_Movement FUNCTION
	PUSH {R0-R12, LR}
	;TODO
	
	POP {R0-R12, PC}
	ENDFUNC

;------------------------
; Move_Snake Input R7
;------------------------
Move_Snake FUNCTION
	PUSH {R0-R12, LR}
	LDRB R0, =SnakeMap; load the address

	MOV R12 , R7
	AND R12, #0x000F
	
	CMP R12 , #1
	BEQ MOVE_UPS
	  
	CMP R12 , #2
	BEQ MOVE_DOWNS
	 
	CMP R12 , #4
	BEQ MOVE_LEFTS
	 
	CMP R12 , #8
	BEQ MOVE_RIGHTS
	 
MOVE_UPS
		MOV R4, R3   			; R4 = our “current cell index”
        ; split R3 into row/col
        MOV R6, R4, LSR #3      ; R6 = row = R4/8
        AND R5, R4, #7          ; R5 = col = R4%8

        ; compute pointer to that row in the byte array
        ADD R1, R0, R6          ; R1 = &SnakeMap[row]
        ; compute bitmask = 1<<col in R2
        MOV R2, #1
        LSL R2, R2, R5

        ; if we’re already in the top row (row==0), there is nothing below
        CMP R6, #5
        BEQ Return               ; R4 still = start

LoopUP
        ; move one row “up”
        ADDS R6, R6, #1          ; row++
        ; R6 will remain <=5 as long as we branched here
        ADDS R1, R1, #1          ; row-pointer++

        LDRB R7, [R1]            ; R7 = map[row]
        TST R7, R2              ; test the bit at “col”
        BNE Return           ; if bit==1 ? wall

        ; it was 0 ? valid; mark it visited by setting bit to 1
        ORR R7, R7, R2
        STRB R7, [R1]

        ; record that we have moved one row up
        ADD R4, R4, #8          ; new index = old index + 8

        ; if we still have another row below, loop
        CMP R6, #5
        BNE LoopUp

        ; we fell off after marking the downmost cell; that’s our result
        B Return
        ; as soon as we hit a 1-bit, we stop.
        ; R4 still holds the index one row below (the last valid cell).

	
MOVE_DOWNS
		MOV R4, R3              ; R4 = our “current cell index”
        ; split R3 into row/col
        MOV R6, R4, LSR #3      ; R6 = row = R4/8
        AND R5, R4, #7          ; R5 = col = R4%8

        ; compute pointer to that row in the byte array
        ADD R1, R0, R6          ; R1 = &SnakeMap[row]
        ; compute bitmask = 1<<col in R2
        MOV R2, #1
        LSL R2, R2, R5

        ; if we’re already in the bottom row (row==0), there is nothing below
        CMP R6, #0
        BEQ Return               ; R4 still = start

LoopDown
        ; move one row “down”
        SUBS R6, R6, #1          ; row--
        ; R6 will remain >=0 as long as we branched here
        SUB R1, R1, #1          ; row-pointer--

        LDRB R7, [R1]            ; R7 = map[row]
        TST R7, R2              ; test the bit at “col”
        BNE Return           ; if bit==1 ? wall

        ; it was 0 ? valid; mark it visited by setting bit to 1
        ORR R7, R7, R2
        STRB R7, [R1]

        ; record that we have moved one row down
        SUB R4, R4, #8          ; new index = old index - 8

        ; if we still have another row below, loop
        CMP R6, #0
        BNE LoopUp

        ; we fell off after marking the downmost cell; that’s our result
        B Return
        ; as soon as we hit a 1-bit, we stop.
        ; R4 still holds the index one row below (the last valid cell).


MOVE_LEFTS
		MOV R4, R3   			; R4 = our “current cell index”
        ; split R3 into row/col
        MOV R6, R4, LSR #3      ; R6 = row = R4/8
        AND R5, R4, #7          ; R5 = col = R4%8

        ; compute pointer to that row in the byte array
        ADD R1, R0, R6          ; R1 = &SnakeMap[row]
        ; compute bitmask = 1<<col in R2
        MOV R2, #1
        LSL R2, R2, R5

        ; if we’re already in the left side  , there is nothing below
        CMP R5, #7
        BEQ Return               ; R4 still = start

LoopLEFT
        ; move one colomn "left"
        ADDS R5, R5, #1          ; colomn++
        ; R5 will remain <=7 as long as we branched here
        ;ADDS R1, R1, #1       ; row-pointer++
		MOV R2, #1
        LSL R2, R2, R5
		
        LDRB R7, [R1]            ; R7 = map[row]
        TST R7, R2              ; test the bit at “col”
        BNE Return           ; if bit==1 ? wall

        ; it was 0 ? valid; mark it visited by setting bit to 1
        ORR R7, R7, R2
        STRB R7, [R1]

        ; record that we have moved one colomn left
        ADD R4, R4, #1        ; new index = old index + 8

        ; if we still have another row below, loop
        CMP R5, #7
        BNE LoopLEFT

        ; we fell off after marking the downmost cell; that’s our result
        B Return
        ; as soon as we hit a 1-bit, we stop.
        ; R4 still holds the index one row below (the last valid cell).

	
MOVE_RIGHTS
		MOV R4, R3   			; R4 = our “current cell index”
        ; split R3 into row/col
        MOV R6, R4, LSR #3      ; R6 = row = R4/8
        AND R5, R4, #7          ; R5 = col = R4%8

        ; compute pointer to that row in the byte array
        ADD R1, R0, R6          ; R1 = &SnakeMap[row]
        ; compute bitmask = 1<<col in R2
        MOV R2, #1
        LSL R2, R2, R5

        ; if we’re already in the right	side  , there is nothing below
        CMP R5, #0
        BEQ Return               ; R4 still = start

LoopRGHIT
        ; move one colomn "left"
        SUBS R5, R5, #1          ; colomn--
        ; R5 will remain <=0 as long as we branched here
        ;ADDS R1, R1, #1       ; row-pointer++
		MOV R2, #1
        LSL R2, R2, R5
		
        LDRB R7, [R1]            ; R7 = map[row]
        TST R7, R2              ; test the bit at “col”
        BNE Return           ; if bit==1 ? wall

        ; it was 0 ? valid; mark it visited by setting bit to 1
        ORR R7, R7, R2
        STRB R7, [R1]

        ; record that we have moved one colomn left
        SUB R4, R4, #1        ; new index = old index + 8

        ; if we still have another row below, loop
        CMP R5, #0
        BNE LoopRGHIT

        ; we fell off after marking the downmost cell; that’s our result
        B Return
        ; as soon as we hit a 1-bit, we stop.
        ; R4 still holds the index one row below (the last valid cell).

	 
Return
	POP {R0-R12, PC}
	ENDFUNC

;------------------------
; Check_End
;------------------------
Check_End FUNCTION
	PUSH {R0-R12, LR}
	;TODO
	
	POP {R0-R12, PC}
	ENDFUNC
	END