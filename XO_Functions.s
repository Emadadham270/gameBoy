    AREA    MYDATA, DATA, READWRITE


XO_array       DCD     0x00000000

XO_Turn     DCD     0x00
XO_counter  DCD     0x00
X_score     DCD     0x00	
O_score     DCD     0x00	
;--- Colors ---
Red     	   EQU 0Xf800 
Green   	   EQU 0x07e0
Blue    	   EQU 0x02ff 
Yellow  	   EQU 0xFfe0
White   	   EQU 0xffff
Black		   EQU 0x0000	
	
	AREA    CODEY, CODE, READONLY
    IMPORT  TFT_WriteCommand
    IMPORT  TFT_WriteData
    IMPORT  TFT_DrawImage
	IMPORT  TFT_Filldraw4INP
    IMPORT  delay
	IMPORT  GET_state
	IMPORT  Num_to_LCD
	EXPORT  Main_Game_XO
	EXPORT  Draw_X
	EXPORT  Draw_O
	

;------------------------
; TFT_DrawGrid
;------------------------
TFT_DrawGrid    FUNCTION
	PUSH {R0-R10, LR}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color (area)
    MOV R11, #Black
	BL TFT_Filldraw4INP
	MOV R6,#0X0008
	MOV R7,#0X0138
	MOV R8,#0X0008
	MOV R9,#0X0138
    ; Fill screen with color (area)
    MOV R11, #White
    BL TFT_Filldraw4INP
	MOV R6,#0X0068
	MOV R7,#0X0070
	MOV R8,#0X0008
	MOV R9,#0X0138
    ; Fill screen with color (line)
    MOV R11, #Black
    BL TFT_Filldraw4INP
	MOV R6,#0X00D0
	MOV R7,#0X00D8
	MOV R8,#0X0008
	MOV R9,#0X0138
    ; Fill screen with color (line)
    MOV R11, #Black
    BL TFT_Filldraw4INP
	MOV R6,#0X0008
	MOV R7,#0X0138
	MOV R8,#0X0068
	MOV R9,#0X0070

    ; Fill screen with color (line)
    MOV R11, #Black
    BL TFT_Filldraw4INP
	MOV R6,#0X0008
	MOV R7,#0X0138
	MOV R8,#0X00D0
	MOV R9,#0X00D8
    ; Fill screen with color (line)
    MOV R11, #Black
    BL TFT_Filldraw4INP


    ; Fill screen with color (line)
    MOV R11, #Black
    BL TFT_Filldraw4INP
	MOV R6,#0X0098
	MOV R7,#0X00a8
	MOV R8,#0X0148
	MOV R9,#0X01d0
    ; Fill screen with color (line)
    MOV R11, #Green
    BL TFT_Filldraw4INP
;-----------------------------------------------------
; Inputs on entry: 
;   R1 = X0,   R2 = Y0,   R3 = LEN, 
;   R10 = THICK,  R11 = colour
; Clobbers: R0,R4–R9,R12
;-----------------------------------------------------	
	;Draw X Score
	;-----------------------------------------------------
	; Inputs on entry: 
	;   R1 = X0,   R2 = Y0,   R3 = LEN, 
	;   R10 = THICK,  R11 = colour
	; Clobbers: R0,R4–R9,R12
	;-----------------------------------------------------
	MOV R2 , #0x17C
	MOV R1 , #80
	MOV R3 , #50
	MOV R11 , #Green 	
	BL Draw_X
	;THE value of score
	LDR R0 , =X_score
	LDR R0 , [R0]
	MOV R2 , #0x17c
	MOV R1 , #30
	MOV R3 , #2
	MOV R4 , #16
	MOV R5, #2
	BL Num_to_LCD
	
	;Draw O Score
	;-----------------------------------------------------
	; Inputs on entry: 
	;   R1 = X0,   R2 = Y0,   R3 = LEN, 
	;   R10 = THICK,  R11 = colour
	; Clobbers: R0,R4–R9,R12
	;-----------------------------------------------------
	MOV R2 , #0x17C
	MOV R1 , #0xFA
	MOV R3 , #50
	MOV R11 , #Green 
	BL Draw_O
	;THE value of score
	LDR R0 , =O_score
	LDR R0 , [R0]
	MOV R2 , #0x17c
	MOV R1 , #200
	MOV R3 , #2
	MOV R4 , #16
	MOV R5, #2
	BL Num_to_LCD
	
	
	POP {R0-R10, LR}
    BX LR
	ENDFUNC



; *************************************************************
; ReDraw Square R6,R7-column start/end   R8,R9-page start/end ,ColorBackground=R0, ColorSquare=R11, Direction=R10 
;(0->Nochange,1->Up 2->Down 4->Left 8->right)
; *************************************************************
DrawBorder FUNCTION;take r1,x r2,y 
	PUSH{R0-R12,LR}
	SUB R6,R1,#8
	MOV R7,R1
	SUB R8,R2,#8
	ADD R9,R2,#0X68
	BL TFT_Filldraw4INP ; Remove Square -> By change the color to BG Color
	SUB R6,R1,#8
	ADD R7,R1,#0X68
	SUB R8,R2,#8
	MOV R9,R2
	BL TFT_Filldraw4INP ; Remove Square -> By change the color to BG Color
	SUB R6,R1,#8
	ADD R7,R1,#0X68
	ADD R8,R2,#0X60
	ADD R9,R2,#0X68
	BL TFT_Filldraw4INP ; Remove Square -> By change the color to BG Color
	ADD R6,R1,#0X60
	ADD R7,R1,#0X68
	SUB R8,R2,#8
	ADD R9,R2,#0X68
	BL TFT_Filldraw4INP ; Remove Square -> By change the color to BG Color
	pop{R0-R12,PC}
	ENDFUNC
	
TFT_MoveCursor FUNCTION ; Take X-R1; Y-R2 : Input in R10
	 PUSH{R11-R12,LR}
	 
	 MOV R11, #Black
	 BL DrawBorder
	 
	 MOV R12 , R10
	 AND R12, #0x000F
	 CMP R12 , #1
	 BEQ MOVE_UPB
	  
	 CMP R12 , #2
	 BEQ MOVE_DOWNB
	 
	 CMP R12 , #4
	 BEQ MOVE_LEFTB
	 
	 CMP R12 , #8
	 BEQ MOVE_RIGHTB
	 
	 B DEFAULTB
MOVE_UPB
	 CMP R2 , #0xD8 ; checking the start
	 BEQ DEFAULTB
	 ADD R2 , R2 , #0x68
	 B DEFAULTB
	 
MOVE_DOWNB
	 CMP R2 , #0x08
	 BEQ DEFAULTB
	 SUB R2 , R2 , #0x68
	 B DEFAULTB
	 
MOVE_RIGHTB
	 CMP R1 , #0x08
	 BEQ DEFAULTB
	 SUB R1 , R1 , #0x68
	 B DEFAULTB
	 
MOVE_LEFTB
	 CMP R1 , #0xD8
	 BEQ DEFAULTB
	 ADD R1 , R1 , #0x68
	 B DEFAULTB
	 
DEFAULTB
	 MOV R11,#Yellow
	 BL DrawBorder
	 pop{R11-R12,PC}
	 ENDFUNC

;------------------------
; Draw_XO  R1-column start   R2-page start
;------------------------
Draw_XO    FUNCTION
    PUSH    {R0-R12, LR} ;R12 STORES THE CELL NUMBER
											   ; 32   16    8    4     2     1
	MOV R12, #0x0000       ;Lowest 6 bits in R12: up-middle-down-left-middle-right
	
	CMP R1, #0x8       ;Right
	BEQ Right
	CMP R1, #0x70      ;Middle X
	BEQ MiddleX
	CMP R1, #0xD8	   ;Left
	BEQ Left

PageTest
	CMP R2, #0x8       ;Down
	BEQ Down
	CMP R2, #0x70      ;Middle Y
	BEQ MiddleY
	CMP R2, #0xD8	   ;Up
	BEQ Up

Right
	ADD R12, #1
	B PageTest
MiddleX
	ADD R12, #2
	B PageTest
Left
	ADD R12, #4
	B PageTest
	
Down
	ADD R12, #8
	B Continue1
MiddleY
	ADD R12, #16
	B Continue1
Up
	ADD R12, #32
	B Continue1
	

Continue1
	CMP R12, #36
	BEQ onee
	CMP R12, #34
	BEQ twoo
	CMP R12, #33
	BEQ threee
	CMP R12, #20
	BEQ fourr
	CMP R12, #18
	BEQ fivee
	CMP R12, #17
	BEQ sixx
	CMP R12, #12
	BEQ sevenn
	CMP R12, #10
	BEQ eightt
	CMP R12, #9
	BEQ ninee
	
onee
	MOV R12, #1
	B Continue2
twoo
	MOV R12, #2
	B Continue2
threee
	MOV R12, #3
	B Continue2
fourr
	MOV R12, #4
	B Continue2
fivee
	MOV R12, #5
	B Continue2
sixx
	MOV R12, #6
	B Continue2
sevenn
	MOV R12, #7
	B Continue2
eightt
	MOV R12, #8
	B Continue2
ninee
	MOV R12, #9
	B Continue2

Continue2
	LDR   R11, =XO_array
	LDR   R11, [R11]	; R11 = bitmap word
	;MOV	  R11,#0
	LSL   R4, R12, #1         ; R4 = 2 * X
	SUB   R4, R4, #2
	; R4 = 2*X ? 2
	MOV R5, #3 ; R5 = 0b11
	LSL R5, R5, R4 ; R5 = 3 << R4
	AND R5,R11,R5
	LSR R5, R5, R4 ; R5 = 3 >> R4

	CMP R5,#2
	BEQ   AlreadyDrawn
	CMP R5,#1
	BEQ   AlreadyDrawn
	; --- clear the two bits at [base..base+1] ---
    MOV   R5, #3           ; R5 = 0b11
    LSL   R5, R5, R4       ; R5 = 0b11 << base
    BIC    R11, R11, R5     ; R11 &= ~(0b11 << base)

    LDR R10,=XO_Turn   ;Check turn (0 = O, 1 = X)
	LDR R10, [R10]	   ;
	AND R10,R10,#2
	CMP R10, #2		   ;Draw X
	BEQ Draw_xX
	CMP R10, #0		   ;Draw O
	BEQ Draw_oO


Draw_xX  ;01
	SUB R10, #2	    	   ;Toggle turn
	; --- OR in the pattern 0b01 at [base..base+1] ---
	MOV   R5, #1           ; R5 = 0b01
    LSL   R5, R5, R4       ; R5 = 0b01 << base
    ORR   R11, R11, R5     ; R11 |= (0b01 << base)
	LDR R0, =XO_array
	STR R11, [R0]
	MOV R3, #0x60
	LDR R11, =Black
	BL Draw_X
	LDR R0, =XO_Turn
	STR R10, [R0]
	
	LDR R0, =XO_counter    ; Increment counter
	LDR R10, [R0]
	ADD R10, #1
	STR R10, [R0]
	
	B FiNish	 
	LTORG
	
Draw_oO  ;10
	ADD R10, #2		   	   ;Toggle turn
	; --- OR in the pattern 0b10 at [base..base+1] ---
    MOV   R5, #2           ; R5 = 0b10
    LSL   R5, R5, R4       ; R5 = 0b10 << base
    ORR   R11, R11, R5     ; R11 |= (0b10 << base)
	LDR R0, =XO_array
	STR R11, [R0]
	MOV R3, #0x60
	LDR R11, =Black
	BL Draw_O
	LDR R0, =XO_Turn
	STR R10, [R0]
	
	LDR R0, =XO_counter    ; Increment counter
	LDR R10, [R0]
	ADD R10, #1
	STR R10, [R0]
	
	B FiNish
	LTORG

	
AlreadyDrawn    ;Draw red border momentarily then draw yellow
	MOV R11, #Red
	BL DrawBorder
	MOV R0, #5
	BL delay
	MOV R11, #Yellow
	BL DrawBorder
	
FiNish
	
    POP     {R0-R12, PC}
	ENDFUNC

;------------------------
; Check_Win  (todo)
;------------------------
Check_Win FUNCTION
	PUSH{R0-R12, LR}
	MOV	R1,#0
	LDR R0,=XO_array
	B SKK
	LTORG
SKK	
	; Pre-load all needed constants into registers
    LDR R2, =0x4104		 ; 0000 0100 0001 0000 0100
    LDR R3, =0x1041		 ; 0000 0001 0000 0100 0001
    LDR R4, =0x1110		 ; 0000 0001 0001 0001 0000
	LDR R5,  =0x10101    ; 0001 0000 0001 0000 0001  
	LDR R6,  =0x10410    ; 0001 0000 0100 0001 0000  
	LDR R7,  =0x2082     ; 0000 0010 0000 1000 0010     + 
	LDR R8,  =0x2220     ; 0000 0010 0010 0010 0000      
	LDR R9,  =0x8208     ; 0000 1000 0010 0000 1000      
	LDR R10, =0x20820    ; 0010 0000 1000 0010 0000  
	LDR R11, =0x20202    ; 0010 0000 0010 0000 0010
	
    LDR R1, [R0]
    AND R1, R1, R2      ; was #0x4104
    CMP R1, R2
    BEQ win_x
	
    LDR R1, [R0]
    AND R1, R1, #0x15
    CMP R1, #0x15
    BEQ win_x
	
	LDR R1, [R0]
	AND R1, R1, R3      ; was #0x30C3
	CMP R1, R3
	BEQ win_x
	
    LDR R1, [R0]
    AND R1, R1, R4      ; was #0x3330
    CMP R1, R4
    BEQ win_x
    
    LDR R1, [R0]
    AND R1, R1, R5      ; was #0x30303
    CMP R1, R5
    BEQ win_x
	
    LDR R1, [R0]
    AND R1, R1, R6      ; was #0x30C30
    CMP R1, R6
    BEQ win_x
    
    LDR R1, [R0]
    AND R1, R1, #0x540
    CMP R1, #0x540
    BEQ win_x

    LDR R1, [R0]
    AND R1, R1, #0x15000
    CMP R1, #0x15000
    BEQ win_x

	;;;;;;;;;;;;;;;;;;;;;;;
    ; Check O wins
    LDR R1, [R0]
    AND R1, R1, R7      ; was #0x2082
    CMP R1, R7
    BEQ win_o

    LDR R1, [R0]
    AND R1, R1, R8      ; was #0x2220
    CMP R1, R8
    BEQ win_o
    
    LDR R1, [R0]
    AND R1, R1, #0x2A
    CMP R1, #0x2A
    BEQ win_o
    
    LDR R1, [R0]
    AND R1, R1, R9      ; was #0x8208
    CMP R1, R9
    BEQ win_o
	
    LDR R1, [R0]
    AND R1, R1, R10     ; was #0x20820
    CMP R1, R10
    BEQ win_o
    
    LDR R1, [R0]
    AND R1, R1, #0xA80
    CMP R1, #0xA80
    BEQ win_o
    
    LDR R1, [R0]
    AND R1, R1, #0x2A000
    CMP R1, #0x2A000
    BEQ win_o
	
    LDR R1, [R0]
    AND R1, R1, R11      ; was #0x20202
    CMP R1, R11
    BEQ win_o
    
	; Check Draw
	LDR R6, =XO_counter
	LDR R6, [R6]
	CMP R6, #0x9
	BEQ ta3adol_check
	
	;else
	B wala7aga
win_x
	BL DrawXWINS
	LDR R1, =X_score  ; from this to 456 for score
	LDR R12,[R1]
	ADD R12,R12,#1
	STR R12,[R1]
	MOV R1, #0xFFFFFFFF
	STR R1, [R0]
	B wala7aga
win_o	
	BL DrawOWINS
	LDR R1, =O_score ; from this to 465 for score
	LDR R12,[R1]
	ADD R12,R12,#1
	STR R12,[R1]
	MOV R1, #0xFFFFFFFF
	STR R1, [R0]
	B wala7aga
ta3adol_check
	BL DrawTA3ADOL
	MOV R1, #0xFFFFFFFF
	STR R1, [R0]
	B wala7aga
wala7aga
	POP{R0-R12,PC}
	ENDFUNC
	

DrawXWINS	FUNCTION
	PUSH {R0-R12, LR}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color (area)
    MOV R11, #White
	BL TFT_Filldraw4INP
	MOV R1,#113
	MOV R2,#193
	MOV R3, #0x60
	LDR R11, =Green
	BL Draw_X
	LDR R0, =XO_Turn
	POP {R0-R12, PC}
	ENDFUNC
	
DrawOWINS	FUNCTION
	PUSH {R0-R12, LR}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color (area)
    MOV R11, #White
	BL TFT_Filldraw4INP
	MOV R1,#113
	MOV R2,#193
	MOV R3, #0x60
	LDR R11, =Green
	BL Draw_O
	POP {R0-R12, PC}
	ENDFUNC
	
DrawTA3ADOL	FUNCTION
	PUSH {R0-R12, LR}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color (area)
    MOV R11, #Red
	BL TFT_Filldraw4INP
	POP {R0-R12, PC}
	ENDFUNC





Main_Game_XO FUNCTION
	PUSH{R0-R12,LR}
	
	LDR R12, =XO_Turn  ;Store 0 in XO_Turn
	MOV R11, #0x0010
	STR R11, [R12]
	
	;initialize X and O scores with value 0
	;for X
	LDR R0 , =X_score
	MOV R1 , #0
	STR R1 , [R0]
	
	;for O
	LDR R0 , =O_score
	MOV R1 , #0
	STR R1 , [R0]
	
Restart	
	BL TFT_DrawGrid
	LDR R12, =XO_array  ;Store 0 in XO_array
	MOV R11, #0
	STR R11, [R12]
	LDR R12, =XO_counter  ;Reset counter
	MOV R11, #0
	STR R11, [R12]
MAINLOOP	
	MOV R1, #0x70
	MOV R2, #0x70
	MOV R11,#Yellow
	BL DrawBorder

INPUT1233                ;Wait for input from user
	BL GET_state
	AND R10,R10, #0x003F
	CMP R10, #32      ;eXIT
	BEQ EXIT_XO
	CMP R10, #00      ;Keep looping while input = 0
	BEQ INPUT1233
	
	;If input == ENTER, draw X/O and check win
	CMP R10, #0x0010 
	BEQ ENTERrr
	
	BL TFT_MoveCursor
	B INPUT1233
	
ENTERrr
	BL Draw_XO
	MOV R11,#Black
	BL DrawBorder

	BL Check_Win
	LDR R0, =XO_array
	LDR R0, [R0]
	CMP R0,#0xFFFFFFFF
	BEQ EndGame
	B MAINLOOP

EndGame
INPUT123                ;Wait for input from user
	BL GET_state
	AND R10,R10, #0x001F
	CMP R10, #00      ;Keep looping while input = 0
	BEQ INPUT123
	B Restart

EXIT_XO
	POP{R0-R12,PC}
	ENDFUNC

;-----------------------------------------------------
; Inputs on entry: 
;   R1 = X0,   R2 = Y0,   R3 = LEN, 
;   R10 = THICK,  R11 = colour
; Clobbers: R0,R4–R9,R12
;-----------------------------------------------------
Draw_X FUNCTION
    PUSH   {R0-R12, LR}
	
	ADD R1, #10
	ADD R2, #10
	SUB R3, #20
	MOV R10, #8
    ; compute HALF = THICK/2 in R5
    MOV    R5, R10
    LSR    R5, R5, #1

    ; compute REM = THICK – HALF – 1 in R12
    SUB    R12, R10, R5
    SUB    R12, R12, #1

    MOV    R4, #0         ; i = 0

TFT_XLoop
    ; ---- forward diagonal point (xi, yi) ----
    ADD    R0, R1, R4     ; R0 = xi = X0 + i
    SUB    R6, R0, R5     ; startX = xi - HALF
    ADD    R7, R0, R12    ; endX   = xi + REM

    ADD    R0, R2, R4     ; R0 = yi = Y0 + i
    SUB    R8, R0, R5     ; startY = yi - HALF
    ADD    R9, R0, R12    ; endY   = yi + REM

    BL     TFT_Filldraw4INP

    ; ---- reverse diagonal point (xj, yi) ----
    ; compute xj = X0 + (LEN-1 - i)
    SUB    R0, R3, R4     ; R0 = LEN - i
    SUB    R0, R0, #1     ; R0 = LEN - 1 - i
    ADD    R0, R1, R0     ; R0 = X0 + (LEN-1 - i)
    SUB    R6, R0, R5     ; startX = xj - HALF
    ADD    R7, R0, R12    ; endX   = xj + REM

    ADD    R0, R2, R4     ; R0 = yi = Y0 + i
    SUB    R8, R0, R5     ; startY = yi - HALF
    ADD    R9, R0, R12    ; endY   = yi + REM

    BL     TFT_Filldraw4INP

    ; next i
    ADD    R4, R4, #1
    CMP    R4, R3
    BLT    TFT_XLoop

    POP    {R0-R12, PC}
	ENDFUNC
	
;------------------------------------------------------------------------------
; Draw_O FUNCTION
;
; Inputs on entry:
;    R1 = X0       ? top-left corner X
;    R2 = Y0       ? top-left corner Y
;    R3 = LEN      ? outer diameter in pixels
;    //R10= THICK    ? border thickness
;    R11= colour   ? pen colour
;
;------------------------------------------------------------------------------
Draw_O  FUNCTION
	PUSH {R0-R12, LR}
	
	ADD R1, #10
	ADD R2, #10
	SUB R3, #20
	MOV R10, #8
	;-- compute HALF = THICK/2, REM = THICK–HALF–1  (exactly as in Draw_X)
	MOV R5, R10
	LSR R5, R5, #1           ; R5 = floor(THICK/2)
	SUB R12, R10, R5         ; R12 = THICK – HALF
	SUB R12, R12, #1         ; R12 = THICK – HALF – 1

	;-- radius = floor(LEN/2)
	MOV R0, R3
	LSR R0, R0, #1           ; R0 = radius
	
	;-- centre = (X0 + radius, Y0 + radius)
	ADD R3, R1, R0           ; R3 = Cx
	ADD R4, R2, R0           ; R4 = Cy
	
	
	MOV R1, #0               ; use R1 for x
	MOV R2, R0               ; use R2 for y
	ADD R2, #1
	
	;-- decision variable d = 1 – radius
	MOV R7, #1
	SUB R7, R7, R0           ; R7 = 1 – R
	
	BL Plot8

BresLoop
	CMP R1, R2          ; while x <= y
	BGT BresDone

	CMP R7, #0
	BLE addX_ONLY        ; if d <= 0, only addX

;else decrement y too
	SUB R2, #1      ; y = y - 1
	SUB R7, R7, R2, LSL #1   ; d = d - 2*y

addX_ONLY
	ADD R7, R7, R1, LSL #1   ; d = d + 2*x
	ADD R7, #1
	BL  Plot8           ; plot the 8 symmetric points
	ADD R1, #1          ; x = x + 1
	B   BresLoop
	
BresDone
	POP {R0-R12, PC}
	ENDFUNC

;------------------------------------------------------------------------------
; Plot8: draw one THICK×THICK square at each of the eight
;        (±x,±y),(±y,±x) locations around the centre
;
; Entry:
;    R3 = Cx, R4 = Cy,
;    R1 = x,  R2 = y,
;    R5 = HALF, R12 = REM,
;    R11 = colour
; Clobbers: R0 = px, R10 = py
; Preserves: all caller regs via full push/pop
; Returns via PC
;------------------------------------------------------------------------------
Plot8
    PUSH    {R0-R12, LR}    ; save absolutely everything

; Octant #1  (+x, +y)
    ADD     R0, R3, R1      ; px = Cx +  x
    ADD     R10, R4, R2     ; py = Cy +  y
    SUB     R6, R0, R5      ; startX = px – HALF
    ADD     R7, R0, R12     ; endX   = px + REM
    SUB     R8, R10, R5      ; startY = py – HALF
    ADD     R9, R10, R12     ; endY   = py + REM
    BL      TFT_Filldraw4INP

; Octant #2  (+y, +x)
    ADD     R0, R3, R2     ; px = Cx +  y
    ADD     R10, R4, R1     ; py = Cy +  x
    SUB     R6, R0, R5
    ADD     R7, R0, R12
    SUB     R8, R10, R5
    ADD     R9, R10, R12
    BL      TFT_Filldraw4INP

; Octant #3  (–y, +x)
    SUB     R0, R3, R2     ; px = Cx –  y
    ADD     R10, R4, R1     ; py = Cy +  x
    SUB     R6, R0, R5
    ADD     R7, R0, R12
    SUB     R8, R10, R5
    ADD     R9, R10, R12
    BL      TFT_Filldraw4INP

; Octant #4  (–x, +y)
    SUB     R0, R3, R1     ; px = Cx –  x
    ADD     R10, R4, R2     ; py = Cy +  y
    SUB     R6, R0, R5
    ADD     R7, R0, R12
    SUB     R8, R10, R5
    ADD     R9, R10, R12
    BL      TFT_Filldraw4INP

; Octant #5  (–x, –y)
    SUB     R0, R3, R1     ; px = Cx –  x
    SUB     R10, R4, R2     ; py = Cy –  y
    SUB     R6, R0, R5
    ADD     R7, R0, R12
    SUB     R8, R10, R5
    ADD     R9, R10, R12
    BL      TFT_Filldraw4INP

; Octant #6  (–y, –x)
    SUB     R0, R3, R2     ; px = Cx –  y
    SUB     R10, R4, R1     ; py = Cy –  x
    SUB     R6, R0, R5
    ADD     R7, R0, R12
    SUB     R8, R10, R5
    ADD     R9, R10, R12
    BL      TFT_Filldraw4INP

; Octant #7  (+y, –x)
    ADD     R0, R3, R2     ; px = Cx +  y
    SUB     R10, R4, R1     ; py = Cy –  x
    SUB     R6, R0, R5
    ADD     R7, R0, R12
    SUB     R8, R10, R5
    ADD     R9, R10, R12
    BL      TFT_Filldraw4INP

; Octant #8  (+x, –y)
    ADD     R0, R3, R1     ; px = Cx +  x
    SUB     R10, R4, R2     ; py = Cy –  y
    SUB     R6, R0, R5
    ADD     R7, R0, R12
    SUB     R8, R10, R5
    ADD     R9, R10, R12
    BL      TFT_Filldraw4INP

    POP     {R0-R12, PC}    ; restore all caller state & return
	
	END