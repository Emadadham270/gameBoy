    AREA    MYDATA, DATA, READWRITE


XO_array       DCD     0x00000000

XO_Turn     DCB     0x00
XO_counter  DCD     0x00
;--- Colors ---
Red     	   EQU 0Xf800 
Green   	   EQU 0xF0FF
Blue    	   EQU 0x02ff 
Yellow  	   EQU 0xFfe0
White   	   EQU 0xffff
Black		   EQU 0x0000	
	
	AREA    CODEY, CODE, READONLY
	IMPORT X1
	IMPORT O1
    IMPORT  TFT_WriteCommand
    IMPORT  TFT_WriteData
    IMPORT  TFT_DrawImage
	IMPORT  TFT_Filldraw4INP
    IMPORT  delay
	IMPORT  GET_state

	EXPORT  Main_Game_XO
	

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
	
TFT_MoveCursor FUNCTION; Take X-R1; Y-R2 : Input in R10
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
	LDR R3, =X1
	BL TFT_DrawImage
	LDR R0, =XO_Turn
	STR R10, [R0]
	
	LDR R0, =XO_counter    ; Increment counter
	LDR R10, [R0]
	ADD R10, #1
	STR R10, [R0]
	
	B FiNish	 
	
	
Draw_oO  ;10
	ADD R10, #2		   	   ;Toggle turn
	; --- OR in the pattern 0b10 at [base..base+1] ---
    MOV   R5, #2           ; R5 = 0b10
    LSL   R5, R5, R4       ; R5 = 0b10 << base
    ORR   R11, R11, R5     ; R11 |= (0b10 << base)
	LDR R0, =XO_array
	STR R11, [R0]
	LDR R3, =O1
	BL TFT_DrawImage
	LDR R0, =XO_Turn
	STR R10, [R0]
	
	LDR R0, =XO_counter    ; Increment counter
	LDR R10, [R0]
	ADD R10, #1
	STR R10, [R0]
	
	B FiNish
	

	
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
	MOV R1, #0xFFFFFFFF
	STR R1, [R0]
	B wala7aga
win_o	
	BL DrawOWINS
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
	LDR R3, =X1
	BL TFT_DrawImage
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
	LDR R3, =O1
	BL TFT_DrawImage
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
;------------------------
; Update_Left_Sidebar  (todo)
;------------------------
Update_Left_Sidebar    FUNCTION
    PUSH    {LR}
    ;TODO
    POP     {PC}
	ENDFUNC


Main_Game_XO FUNCTION
	PUSH{R0-R12,LR}
	
	LDR R12, =XO_Turn  ;Store 0 in XO_Turn
	MOV R11, #0x0010
	STR R11, [R12]
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
	AND R10,R10, #0x001F
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


	ENDFUNC

    END



