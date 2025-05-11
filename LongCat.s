	AREA    MYDATA, DATA, READONLY
Level1Map
	DCB 0x81
	DCB 0xA5
	DCB 0x81
    DCB 0xCB
	DCB 0xD9
	DCB 0xC1
Level2Map
	DCB 0x00
	DCB 0x08
	DCB 0x80
    DCB 0x10
	DCB 0x54
	DCB 0x04
Level3Map
	DCB 0x8C
	DCB 0xA0
	DCB 0x88
    DCB 0xE0
	DCB 0x80
	DCB 0x80
	
Leve1StartCell 
			   DCB 36
			   DCB 36
			   DCB 19
		;--- Colors ---
Red     	   EQU 0XF800 
Green   	   EQU 0x07E0
Blue    	   EQU 0x001F 
Yellow  	   EQU 0xFFE0
White   	   EQU 0xFFFF
Black		   EQU 0x0000	
Pink 		   EQU 0xF81F  
LightPink      EQU 0xFC9E  ; Lighter pink
DeepPink       EQU 0xF8B2  ; Deeper pink with a bit more blue
Brown      	   EQU 0x8200  ; Brown
Cyan           EQU 0x07FF  ; Cyan (full green + full blue)
LightBlue      EQU 0x841F
Orange         EQU 0xFD20 
Beige		   EQU 0xF7B6
Lavender 	   EQU 0x9C3F
Purple		   EQU 0x600F
Violet		   EQU 0x881F
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
	IMPORT CatFace
	EXPORT MainGame_LongCat	
	EXPORT Draw_Snake_Movement
	EXPORT TFT_DRAWSQUARE
		

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
    MOV R11, #LightPink ;34an BARBIEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
	BL TFT_Filldraw4INP
	
	MOV R6,#10
	MOV R7,#310
	MOV R8,#40
	MOV R9,#440 
    ; Fill screen with playing area
    MOV R11, #White
	
	BL TFT_Filldraw4INP
	
	;Now all screen in blue, which is the background

    MOV R11,#Green 	 	 ; square color
	
	MOV R1,#10		;START X
	MOV R3,#0		;START row
	
ROW_LOOP
    CMP R3, #6			; Check if all 6 rows processed
    BEQ FINISH_MAP
	
	LDR R0, =SnakeMap       ; Load address of Level Map into R0
    LDRB R9, [R0, R3]		; R9 HAS THE CELLS OF THIS ROW 

    MOV R4, #0          ;START COL
    MOV R2, #40			;START Y

COL_LOOP
    CMP R4, #8          ; Check all 8 columns
    BEQ Next_Row_MAP

    MOV R10, #1
    LSL R10, R4      ; R10 = (1 << Column)

    TST R9, R10         ; Test if bit is 1
    BEQ SkipDraw        ; If 0, skip
	MOV R11,#Cyan
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
	POP {R0-R12, PC}
	ENDFUNC



;------------------------
; Draw_Snake_Movement
; Inputs : R3 -> StartCell , R4-> EndCell , R7 -> Input Status
;------------------------
Draw_Snake_Movement FUNCTION
	PUSH {R0-R2, R4-R12, LR}
	
	MOV R7,R10
	MOV R10 , R3
	BL Get_Coordinates
	CMP R3, R4
	BEQ DRAW_HEAD
;R6 -> X_START_OF START CELL
;R8 -> Y_START_OF START CELL
	MOV R11, #Blue
;SET COLOR
	MOV R0, #15
;DELAY
	
	CMP R7 , #1
	BNE SKIP_Left
	; status: 1 -> up, 2->down, 4->left, 8->right
;-----------
; Input -> UP 
;-----------
	
; Filldraw4Input: R6,R7-column start/end   R8,R9-page start/end
;------------------------

	 
Left_LOOP	
	ADD R7, R6, #50
	ADD R9, R8, #50
	BL TFT_Filldraw4INP
	BL delay
	
	
	ADD R3, R3, #1
	;ADD R8, #25
	ADD R8, #50
	CMP R3 , R4
	BNE Left_LOOP
	
	B DRAW_HEAD

SKIP_Left

	CMP R7 , #2
	BNE SKIP_Right
	
	;-----------
	;Input -> Down
	;-----------

	
Right_LOOP
	ADD R7, R6, #50
	ADD R9, R8, #50
	BL TFT_Filldraw4INP
	BL delay
	
	SUB R3, R3, #1
	;SUB R8, #25
	SUB R8, #50
	CMP R3 , R4
	BNE Right_LOOP
	
	B DRAW_HEAD

	
	
SKIP_Right
	
	CMP R7 , #4
	BNE SKIP_Up
	
;-----------
;Input -> UP
;-----------
	;ADD R9, R8, #50    ;CONSTANT X
Up_LOOP
	ADD R9, R8, #50    
	ADD R7, R6, #50
	BL TFT_Filldraw4INP
	BL delay
	
	
	ADD R3, R3, #8
	;ADD R6, #25
	ADD R6, #50
	CMP R3, R4
	BNE Up_LOOP
	
	B DRAW_HEAD
	
SKIP_Up

	CMP R7 , #8
	BNE SKIP_Down
	
	;-----------
	;Input -> RIGHT
	;-----------
	;ADD R9, R8, #50    ;CONSTANT X
Down_LOOP
	ADD R9, R8, #50
	ADD R7, R6, #50
	BL TFT_Filldraw4INP
	BL delay
	
	SUB R3, R3, #8
	;SUB R6, #25
	SUB R6, #50
	CMP R3 , R4
	BNE Down_LOOP
	
	B DRAW_HEAD
	
	
SKIP_Down
	
DRAW_HEAD
	PUSH{R1,R2,R3}
	MOV R1,R6
	MOV R2,R8	
	LDR R3,=CatFace
	BL TFT_DrawImage
	POP{R1,R2,R3}
	
	POP {R0-R2, R4-R12, PC}
	ENDFUNC
	
;------------------------
; Get_Coordinates
; INPUT : R10 -> Number of cell
; Output : Variables -> X,Y Start Cell
;------------------------
Get_Coordinates FUNCTION
	PUSH{R0-R5,LR}
	
	MOV R5, #50
	
    MOV R4, R10, LSR #3     ; Perform logical shift right by 3 bits (divide by 8)
	MUL R3, R4, R5			; 50 * RESULT IN R4
	ADD R6, R3, #10         ; X START = 10 + 50 * (CELL / 8)
	
	
	AND R4, R10, #7			; REMAINDER
	MUL R3, R4, R5			; 50 * REMAINDER
	ADD R8, R3, #40        ; Y START = 40 + 50 * REMAINDER
		
	POP{R0-R5,PC}
	ENDFUNC


;------------------------
; Move_Snake Input R10
;------------------------
Move_Snake FUNCTION
	PUSH {R0-R2, R5-R7, R10, LR}
	MOV R1 , R10
	AND R1, #0x000F
	
	CMP R1 , #4
	BEQ MOVE_UPS
	  
	CMP R1 , #8
	BEQ MOVE_DOWNS
	 
	CMP R1 , #1
	BEQ MOVE_LEFTS
	 
	CMP R1 , #2
	BEQ MOVE_RIGHTS
	
	B Return
	 
MOVE_UPS
	LDR R0, =SnakeMap; load the address
	MOV R4, R3   			; R4 = our “current cell index”
    ; split R3 into row/col
    MOV R6, R4, LSR #3      ; R6 = row = R4/8
    AND R5, R4, #7          ; R5 = col = R4%8
	
    ; compute bitmask = 1<<col in R2
    MOV R2, #1
    LSL R2, R2, R5

    ; if we’re already in the top row (row==0), there is nothing below
    CMP R6, #5
    BEQ Return               ; R4 still = start

LoopUp
	LDR R0, =SnakeMap; load the address
    ; move one row “up”
    ADD R6, #1          ; row++
    ; R6 will remain <=5 as long as we branched here
    LDRB R7, [R0, R6]            ; R7 = map[row]
    TST R7, R2              ; test the bit at “col”
    BNE Return           ; if bit==1 ? wall

    ; it was 0 ? valid; mark it visited by setting bit to 1
    ORR R7, R7, R2
    STRB R7, [R0, R6]

    ; record that we have moved one row up
    ADD R4, #8          ; new index = old index + 8

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
    ; compute bitmask = 1<<col in R2
    MOV R2, #1
    LSL R2, R2, R5
    ; if we’re already in the bottom row (row==0), there is nothing below
    CMP R6, #0
    BEQ Return               ; R4 still = start

LoopDown
	LDR R0, =SnakeMap; load the address
    ; move one row “down”
    SUB R6, #1          ; row--
    ; R6 will remain >=0 as long as we branched here

    LDRB R7, [R0, R6]            ; R7 = map[row]
    TST R7, R2              ; test the bit at “col”
    BNE Return           ; if bit==1 ? wall

    ; it was 0 ? valid; mark it visited by setting bit to 1
    ORR R7, R7, R2
    STRB R7, [R0, R6]

    ; record that we have moved one row down
    SUB R4, #8          ; new index = old index - 8

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

    ; compute bitmask = 1<<col in R2
    MOV R2, #1
    LSL R2, R2, R5

    ; if we’re already in the left side  , there is nothing below
    CMP R5, #7
    BEQ Return               ; R4 still = start

LoopLEFT
	LDR R0, =SnakeMap; load the address
	; move one colomn "left"
    ADD R5, #1         ; colomn++
    ; R5 will remain <=7 as long as we branched here
	MOV R2, #1              ;R2= 0....00000001
    LSL R2, R2, R5          ;R2= 0....00100000
    LDRB R7, [R0, R6]       ; R7 = map[row]
    TST R7, R2              ; test the bit at “col”
    BNE Return           	; if bit==1 ? wall

    ; it was 0 ? valid; mark it visited by setting bit to 1
    ORR R7, R7, R2
    STRB R7, [R0, R6]

    ; record that we have moved one colomn left
    ADD R4, #1        ; new index = old index + 8

    ; if we still have another row below, loop
    CMP R5, #7
    BNE LoopLEFT

    ; we fell off after marking the leftmost cell; that’s our result
    B Return
    ; as soon as we hit a 1-bit, we stop.
    ; R4 still holds the index one row below (the last valid cell).

	
MOVE_RIGHTS
	MOV R4, R3   			; R4 = our “current cell index”
    ; split R3 into row/col
    MOV R6, R4, LSR #3      ; R6 = row = R4/8
    AND R5, R4, #7          ; R5 = col = R4%8

    ; compute bitmask = 1<<col in R2
    MOV R2, #1
    LSL R2, R2, R5

    ; if we’re already in the right	side  , there is nothing below
    CMP R5, #0
    BEQ Return               ; R4 still = start

LoopRGHIT
	LDR R0, =SnakeMap; load the address
    ; move one colomn "left"
    SUB R5, #1          ; colomn--
    ; R5 will remain <=0 as long as we branched here
	MOV R2, #1
    LSL R2, R2, R5
    LDRB R7, [R0, R6]    ; R7 = map[row]
    TST R7, R2           ; test the bit at “col”
    BNE Return           ; if bit==1 ? wall

    ; it was 0 ? valid; mark it visited by setting bit to 1
    ORR R7, R7, R2
    STRB R7, [R0, R6]

    ; record that we have moved one colomn right
    SUB R4, #1        ; new index = old index + 8

    ; if we still have another column right, loop
    CMP R5, #0
    BNE LoopRGHIT

    ; we fell off after marking the rightmost cell; that’s our result
    B Return
    ; as soon as we hit a 1-bit, we stop.
    ; R4 still holds the the last valid cell.

	 
Return
	POP {R0-R2, R5-R7, R10, PC}
	ENDFUNC
;------------------------
; check win (R1 = 0xFFFF win - R1 = 0xAAAA lose
;------------------------
check_win FUNCTION
	PUSH{R0, R2-R12, LR}
	
    ; Compute row and column from cell number in R3 (0 to 47)
    LSR R6, R3, #3         ; R6 = k = R3 / 8 (row index from bottom, 0 to 5)
    AND R7, R3, #7         ; R7 = m = R3 % 8 (bit position in byte)
    MOV R8, #5             ; R8 will hold row index from top (0 to 5)
    SUB R8, R8, R6         ; r = 5 - k (row index: 5 for bottom, 0 for top)
    MOV R9, #7             ; R9 will hold column index (0 to 7, left to right)
    SUB R9, R9, R7         ; c = 7 - m (column: 7 for right, 0 for left)
	
    ; Check up neighbor (r-1, c) if r > 0
    CMP R8, #0             ; Is row > 0?
    BLE skip_up            ; Skip if r <= 0 (no up neighbor)
    ADD R11, R6, #1        ; R11 = r + 1 (row above)
	LDR R4, =SnakeMap          ; Load base address of the 6-byte grid into R4
    LDRB R5, [R4, R11]     ; Load byte for row r-1
    MOV R0, #1
    LSL R0, R0, R7         ; R0 = 1 << bit (mask for neighbor's bit)
    TST R5, R0             ; Test if bit is 1
    BNE skip_up            ; If bit is 1, skip to next check
    B continue_game           ; Bit is 0, still can move: CONTINUE
skip_up

    ; Check down neighbor (r+1, c) if r < 5
    CMP R8, #5             ; Is row < 5?
    BGE skip_down          ; Skip if r >= 5 (no down neighbor)
    SUB R11, R6, #1        ; R11 = r - 1 (row below)
	LDR R4, =SnakeMap          ; Load base address of the 6-byte grid into R4
    LDRB R5, [R4, R11]     ; Load byte for row r+1
	MOV R0, #1
    LSL R0, R0, R7         ; R0 = 1 << bit (mask for neighbor's bit)
    TST R5, R0             ; Test same bit position 
    BNE skip_down          ; If bit is 1, skip
    B continue_game           ; Bit is 0, still can move: CONTINUE
skip_down

    ; Load current row's byte for left and right checks
    LDRB R5, [R4, R8]      ; R5 = byte for current row r

    ; Check left neighbor (r, c-1) if c > 0
    CMP R9, #0             ; Is column > 0?
    BLE skip_left          ; Skip if c <= 0 (no left neighbor)
	LDR R4, =SnakeMap          ; Load base address of the 6-byte grid into R4
    LDRB R5, [R4, R6]
    ADD R12, R7, #1      
    MOV R0, #1
    LSL R0, R0, R12        ; R0 = 1 << bit
    TST R5, R0            ; Test if bit is 1
    BNE skip_left          ; If bit is 1, skip
    B continue_game           ; Bit is 0, still can move: CONTINUE
skip_left

    ; Check right neighbor (r, c+1) if c < 7
    CMP R9, #7            ; Is column < 7?
    BGE skip_right         ; Skip if c >= 7 (no right neighbor)
	LDR R4, =SnakeMap          ; Load base address of the 6-byte grid into R4
    LDRB R5, [R4, R6]
    SUB R12, R7, #1      
    MOV R0, #1
    LSL R0, R0, R12        ; R0 = 1 << bit
    TST R5, R0               ; Test if bit is 1
    BNE skip_right         ; If bit is 1, skip
    B continue_game           ; Bit is 0, still can move: CONTINUE
skip_right

    ;PUT THE LOGIC OF WINNING HERE          All neighbors are 1 and not all grid is 1, lose
	
Check_griD
	LDR R4, =SnakeMap          ; Load base address of the 6-byte grid into R4
    ; Check if all 6 bytes are 0xFF (win condition)
    LDRB R5, [R4, #0]      ; Load byte for row 1 (top)
    CMP R5, #0xFF
    BNE LOOSEER    ; If not 0xFF, proceed to check neighbors
    LDRB R5, [R4, #1]      ; Load byte for row 2
    CMP R5, #0xFF
    BNE LOOSEER
    LDRB R5, [R4, #2]      ; Load byte for row 3
    CMP R5, #0xFF
    BNE LOOSEER
    LDRB R5, [R4, #3]      ; Load byte for row 4
    CMP R5, #0xFF
    BNE LOOSEER
    LDRB R5, [R4, #4]      ; Load byte for row 5
    CMP R5, #0xFF
    BNE LOOSEER
    LDRB R5, [R4, #5]      ; Load byte for row 6 (bottom)
    CMP R5, #0xFF
    BNE LOOSEER
    ; All bytes are 0xFF, player wins
	
WINNER
	;PUT HERE THE LOGIC OF WINNING
	MOV R1, #0x00FF             ; Return 00FF for win
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    MOV R11, #Green
	BL TFT_Filldraw4INP
	B EndTheGame
	
LOOSEER
	MOV R1, #0x0AAA
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    MOV R11, #Red
	BL TFT_Filldraw4INP
	B EndTheGame

continue_game
    MOV R1, #0             ; Game continues
EndTheGame
    POP{R0, R2-R12, PC}
	ENDFUNC
;------------------------
; MainGame_LongCat
; Takes R9 = level number: 1, 2, 3, ...
;------------------------
MainGame_LongCat FUNCTION
    PUSH {R0-R12, LR}
	MOV R9, #1
New_Game_Loop
	MOV R12, R9
	SUB R12, #1          ; cuz if level = 1 we will get address + 0, etc..
	LDR R3, =Leve1StartCell
	LDRB R3, [R3, R12]   ; Load level start cell
	MOV R4, R3
	MOV R2, #6           ; Temp for multiplication
	MUL R12, R2          ; R12 = 6 * level shift value
	MOV R2, #0           ; counter for bytes to copy
CopyLoop
	LDR R0, =Level1Map
	ADD R0, R12         ; for level
    LDR R1, =SnakeMap   ; destination base address
	LDRB R3, [R0, R2]
	STRB R3, [R1, R2]
	ADD R2, #1 	  ; increment counter
	CMP R2, #6
	BNE CopyLoop
	
	BL TFT_DrawMap
	MOV R3, R4
	;MOV R10,R3
	;MOV R6,#0X0050

MaiN__LooP
	BL Draw_Snake_Movement
	BL check_win
	CMP R1, #0
	BNE end_geme
	
INPUT1234                ;Wait for input from user
	BL GET_state
	AND R10,R10, #0x002F
	CMP R10, #32      ;eXIT
	BEQ EXIT_LC
	CMP R10, #00      ;Keep looping while input = 0 or ENTER
	BEQ INPUT1234
	BL Move_Snake

	B MaiN__LooP
	
end_geme
	MOV R0, #1
	BL delay
	
INPUT12345                ;Wait for input from user
	BL GET_state
	AND R10, #0x003F
	CMP R10, #32
	BEQ EXIT_LC	
	CMP R10, #00
	BEQ INPUT12345
	
	CMP R1, #0x00FF
	ADDEQ R9, #1     ;Next level if he won
	CMP R9, #3     ;If next level is valid, jump to it (5 is a placeholder here)
	BLE New_Game_Loop
EXIT_LC	
	POP {R0-R12, PC}
	ENDFUNC
	
	END