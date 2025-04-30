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
; TFT_DRAWSQUARE COLOR IN R11
;------------------------
TFT_DRAWSQUARE FUNCTION
	PUSH{R6-R9,LR}
	MOV R6,R1
	ADD R7,R6,#50
	MOV R8,R2
	ADD R9,R8,#50
	BL TFT_Filldraw4INP
	POP{R6-R9, PC}
	ENDFUNC
;------------------------
; TFT_DrawMap 
;------------------------
TFT_DrawMap    FUNCTION
	PUSH {R0-R12, LR}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color BLUE
    MOV R11, #Blue
	BL TFT_Filldraw4INP
	
	MOV R6,#10
	MOV R7,#310
	MOV R8,#40
	MOV R9,#440 
    ; Fill screen with playing area
    MOV R11, #White
	BL TFT_Filldraw4INP
	
	;Now all screen in blue, which is the background
	;We need to get the level map to draw it 
	LDR R0, =Level1Map   ; Load address of Level Map into R0
    MOV R11,#Green 	 ; square color
	
	MOV R1,#10		;START X
	MOV R3,#0		;START row
	
ROW_LOOP
    CMP R3, #6			; Check if all 6 rows processed
    BEQ FINISH_MAP
	ADD R7, R0,R3		; R7 = ADDRESS OF CURRENT ROW
    LDR R9, [R7]		; R9 HAS THE CELLS OF THIS ROW 

    MOV R4, #0          ;START COL
    MOV R2, #40			; START Y

COL_LOOP
    CMP R4, #8          ; Check all 8 columns
    BEQ Next_Row_MAP

    MOV R10, #1
    LSL R10, R4      ; R10 = (1 << Column)

    TST R9, R10         ; Test if bit is 1
    BEQ SkipDraw        ; If 0, skip
    ; If bit is 1, draw a wall block which is square
    BL TFT_DRAWSQUARE 	
SkipDraw
    ADD R2, #50		; Move to next column (50 pixels left)
    ADD R4, #1
    B COL_LOOP

Next_Row_MAP
    ADD R1, #50   ; Move ROW position 50 pixels UP
    ADD R3, #1
    B ROW_LOOP

FINISH_MAP
	POP {R0-R12, LR}
	ENDFUNC



;------------------------
; Draw_Snake_Movement
; Inputs : R3 -> StartCell , R4-> EndCell , R7 -> Input Status
;------------------------
Draw_Snake_Movement FUNCTION
	PUSH {R0-R12, LR}
	
	
	MOV R10 , R3
	BL Get_Coordinates
	
;R6 -> X_START_OF START CELL
;R8 -> Y_START_OF START CELL
	MOV R11, #Yellow
;SET COLOR
	MOV R0, #15
;DELAY
	
	CMP R7 , #1
	BNE SKIP_UP
	
;-----------
; Input -> UP 
;-----------
	
	
UP_LOOP	
	
	ADD R7 , R6 , #50
	ADD R9 , R8 , #50
	BL TFT_Filldraw4INP
	
	ADD R3 , R3 , #8
	ADD R8 , R8 , #50
	CMP R3 , R4
	BNE UP_LOOP
	
	B DRAW_HEAD

SKIP_UP

	CMP R7 , #2
	BNE SKIP_DOWN
	
	;-----------
	;Input -> Down
	;-----------


DOWN_LOOP

	ADD R7 , R6 , #50
	ADD R9 , R8 , #50
	BL TFT_Filldraw4INP
	
	SUB R3 , R3 , #8
	SUB R8 , R8 , #50
	CMP R3 , R4
	BNE DOWN_LOOP
	
	B DRAW_HEAD

	
	
SKIP_DOWN
	
	CMP R7 , #4
	BNE SKIP_LEFT
	
;-----------
;Input -> UP
;-----------
	ADD R9, R8, #50    ;CONSTANT X
LEFT_LOOP

	ADD R7, R6, #50
	BL TFT_Filldraw4INP
	BL delay
	
	ADD R6, #25
	ADD R7, #25
	BL TFT_Filldraw4INP
	BL delay
	
	ADD R3, R3, #1
	ADD R6, #25
	CMP R3, R4
	BNE LEFT_LOOP
	
	B DRAW_HEAD
	
SKIP_LEFT

	CMP R7 , #8
	BNE SKIP_RIGHT
	
	;-----------
	;Input -> RIGHT
	;-----------
	
RIGHT_LOOP

	ADD R7 , R6 , #50
	ADD R9 , R8 , #50
	BL TFT_Filldraw4INP
	
	SUB R3 , R3 , #1
	SUB R6 , R6 , #50
	CMP R3 , R4
	BNE RIGHT_LOOP
	
	B DRAW_HEAD
	
	
SKIP_RIGHT

DRAW_HEAD

	ADD R7 , R6 , #50
	ADD R9 , R8 , #50
	MOV R0 , #Black
	BL TFT_Filldraw4INP
	
	
	POP {R0-R12, PC}
	ENDFUNC
	
	
;------------------------
; Get_Coordinates
; INPUT : R10 -> Number of cell
; Output : Variables -> X,Y Start Cell
;------------------------
Get_Coordinates FUNCTION
	PUSH{R0-R4,LR}
	
	MOV R5, #50
	AND R4, R10, #7			; REMAINDER
	MUL R3, R4, R5			; 50 * REMAINDER
	ADD R6, R3 , #10        ; X START = 10 + 50 * REMINDER
	
	
    MOV R4, R10, LSR #3     ; Perform logical shift right by 3 bits (divide by 8)
	MUL R3, R4, R5			; 50 * RESULT IN R4
	ADD R8, R3, #40        ; Y START = 10 + 50 * CELL / 8
	
	POP{R0-R5,PC}
	ENDFUNC


;------------------------
; Move_Snake Input R7
;------------------------
Move_Snake FUNCTION
	PUSH {R0-R12, LR}
	LDR R0, =SnakeMap; load the address

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

LoopUp
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
        BNE LoopDown

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
		MOV R2, #1             ;R2= 0....00000001
        LSL R2, R2, R5         ;R2= 0....00100000
		
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