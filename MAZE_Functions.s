	AREA    MazeData, DATA, READWRITE  ; Define a data section
ROW    
		DCD    0x00000000,0x13EBFF3A,0x1629002A,0x14A97F2E,0x15AF4120,0x1BED61E0,0x15EF210E,0x14092ECA,0x14F92A4A,0x17812AFA,0x1C1F3C80,0x08150480,0x0BD50584,0x0A57FD84,0x0B500174,0x0950FC1C,0x09708410,0x0F00BF10,0x01FF80FE,0x00000002
			
ROW2		DCD    0x10000000
		DCD    0x13EBFF3A
		DCD    0x1629002A
		DCD    0x14A97F2E
		DCD    0x15AF4120
		DCD    0x1BED61E0
		DCD    0x15EF210E
		DCD    0x14092ECA
		DCD    0x14F92A4A
		DCD    0x17812AFA
		DCD    0x1C1F3C80
		DCD    0x08150480
		DCD    0x0BD50584
		DCD    0x0A57FD84
		DCD    0x0B500174
		DCD    0x0950FC1C
		DCD    0x09708410
		DCD    0x0F00BF10
		DCD    0x01FF80FE
		DCD    0x00000002

;--- Colors ---
Red     EQU 0xF800 
Green   EQU 0x07E0
Blue    EQU 0x001F 
Yellow  EQU 0xFFE0
White   EQU 0xFFFF
Black   EQU 0x0000
Orange	EQU 0xFC00	

	AREA    |.text|, CODE, READONLY
		IMPORT  TFT_WriteCommand
		IMPORT  TFT_WriteData
		IMPORT  TFT_DrawImage
		IMPORT  TFT_Filldraw4INP
		IMPORT  delay
		IMPORT  GET_state
		EXPORT  TFT_DrawMazeGrid
		EXPORT  TFT_DrawMazeGrid2
		EXPORT  TFT_DrawMazeGrid3
		EXPORT  TFT_DrawMapM
;------------------------
; TFT_DRAWSQUARE COLOR IN R11,R1 FOR COL R2 FOR PAGE
;------------------------
;------------------------
; TFT_DrawMap 
;------------------------
TFT_DrawMapM    FUNCTION
	PUSH {R0-R12, LR}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color BLUE
    MOV R11, #Red
	BL TFT_Filldraw4INP
	

	;Now all screen in blue, which is the background

    MOV R11,#Black	 	 ; square color
	
	MOV R1,#0		;START X
	MOV R3,#0		;START row
	
ROW_LOOPMM
    CMP R3, #80			; Check if all 6 rows processed
    BEQ FINISH_MAPMM
	
	LDR R0, =ROW2   ; Load address of Level Map into R0
    LDR R9, [R0, R3]		; R9 HAS THE CELLS OF THIS ROW 

    MOV R4, #0          ;START COL
    MOV R2, #0			;START Y

COL_LOOPMM
    CMP R4, #30; Check all 8 columns
    BEQ Next_Row_MAPMM

    MOV R10, #1
    LSL R10, R4      ; R10 = (1 << Column)

    TST R9, R10         ; Test if bit is 1
    BEQ SkipDrawMM        ; If 0, skip
	MOV R11,#Black
    ; If bit is 1, draw a wall block which is square
    BL TFT_DRAWBlock	
SkipDrawMM
    ADD R2, #16		; Move to next column (50 pixels left)
    ADD R4, #1
    B COL_LOOPMM

Next_Row_MAPMM
    ADD R1, #16   ; Move ROW position 50 pixels UP
    ADD R3, #4
    B ROW_LOOPMM

FINISH_MAPMM
	POP {R0-R12, PC}
	ENDFUNC


TFT_DRAWBlock FUNCTION
	PUSH{R6-R9,LR}
	MOV R6,R1
	ADD R7,R6,#50
	MOV R8,R2
	ADD R9,R8,#50
	BL TFT_Filldraw4INP
	POP{R6-R9, PC}
	ENDFUNC
	
TFT_DrawMazeGrid3    FUNCTION
	PUSH {R0-R12, LR}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color BLUE
    MOV R11, #Red
	BL TFT_Filldraw4INP
	
	;Now all screen in blue, which is the background

    MOV R11,#Black 	 	 ; square color
	
	MOV R1,#0		;START X
	MOV R3,#0		;START row
	
ROW_LOOPin
    CMP R3, #20			; Check if all 6 rows processed
    BEQ FINISH_MAZE
	
	LDR R0, =ROW2   ; Load address of Level Map into R0
    LDRB R9, [R0, R3]		; R9 HAS THE CELLS OF THIS ROW 

    MOV R4, #0          ;START COL
    MOV R2, #0			; START Y

COL_LOOPin
    CMP R4, #32          ; Check all 8 columns
    BEQ Next_Row_MAZE

    MOV R10, #1
    LSL R10, R4      ; R10 = (1 << Column)

    TST R9, R10         ; Test if bit is 1
    BEQ SkipDrawin        ; If 0, skip
    ; If bit is 1, draw a wall block which is square
    BL TFT_DRAWBlock 	
SkipDrawin
    ADD R2, #16		; Move to next column (50 pixels left)
    ADD R4, #1
    B COL_LOOPin

Next_Row_MAZE
    ADD R1, #16   ; Move ROW position 50 pixels UP
    ADD R3, #1
    B ROW_LOOPin

FINISH_MAZE
	POP {R0-R12, PC}
	ENDFUNC

TFT_DrawMazeGrid2 PROC
    PUSH {R0-R12, LR}
    
    ; 1. Fill full screen Black (background)
    MOV R6, #0x0000      ; X start
    MOV R7, #0x0140      ; X end (320 pixels)
    MOV R8, #0x0000      ; Y start
    MOV R9, #0x01E0      ; Y end (480 pixels)
    MOV R11, #Orange
    BL TFT_Filldraw4INP

    ; 2. Draw Outer Borders
    ; Bottom border (Green)
    MOV R1, #0x0000      ; X start
    MOV R2, #0x01C0      ; Y start (480-16)
    MOV R11, #Green
    BL TFT_DRAWBlock

    ; Top border (Blue)
    MOV R1, #0x0130      ; X start
    MOV R2, #0x0010      ; Y start
    MOV R11, #Blue
    BL TFT_DRAWBlock

    ; 3. Draw maze walls from array
	MOV R11,#Black
    MOV R1,#0      ; START X
    MOV R3, #0       ; START ROW

OuterRowLoop
    CMP R3, #20         ; Check if all 20 rows processed
    BEQ ExitMaze
    MOV R4, #0          ; Column index (bit position)
    MOV R2, #0x00       ; Initial X position (column-wise), skipping left border

InnerColumnLoop
    CMP R4, #32         ; Check all 32 columns
    BEQ NextRow

    MOV R10, #1
    LSL R10, R4      ; R4 = (1 << Column)
	LDR R0, =ROW2
	bl m
	LTORG
m
    LDRB R9, [R0, R3];, LSL #2]   ; Load ROW[R2], scale R2 by 4 for byte addressing
    TST R9, R10          ; Test if bit is 1
    BEQ SkipDraw        ; If 0, skip
    BL TFT_DRAWBlock

SkipDraw
    ADD R2, R2, #0x10   ; Move to next column (16 pixels right)
    ADD R4, R4, #1
    B InnerColumnLoop

NextRow
    ADD R1, R1, #0x10   ; Move Y position 16 pixels down
    ADD R3, R3, #1
    B OuterRowLoop

ExitMaze
    POP {R0-R12, LR}
    BX LR
    ENDP


Drawsquare FUNCTION;take parameters at r1 and r2
	PUSH{R0-R12,LR}
	MOV R6, R1   ; X start
	ADD R7,	R1 ,#0X0010
	MOV R8,	R2
	ADD R9, R2 ,#0X0010
	BL TFT_Filldraw4INP
	POP {R0-R12, LR}
    BX LR
	ENDFUNC



Redraw_player	FUNCTION; Take X-R1; Y-R2 : Input in R10
	PUSH{R11-R12,LR}
	MOV R11, #Black
	BL Drawsquare
	 
	MOV R12 , R10
	AND R12, #0x000F
	CMP R12 , #1
	BEQ MOVE_UPBM
	  
	CMP R12 , #2
	BEQ MOVE_DOWNBM
	 
	CMP R12 , #4
	BEQ MOVE_LEFTBM
	 
	CMP R12 , #8
	BEQ MOVE_RIGHTBM
	 
	B DEFAULTBM
MOVE_UPBM
	CMP R2 , #0X01D0 ; checking the start
	BEQ DEFAULTBM
	ADD R2 , R2 , #0x0010
	B DEFAULTBM
	 
MOVE_DOWNBM
	CMP R2 , #0X0000
	BEQ DEFAULTBM
	SUB R2 , R2 , #0x0010
	B DEFAULTBM
	 
MOVE_RIGHTBM
	CMP R1 , #0X0140
	BEQ DEFAULTBM
	SUB R1 , R1 , #0x0010
	B DEFAULTBM
	 
MOVE_LEFTBM
	CMP R1 , #0X010
	BEQ DEFAULTBM
	ADD R1 , R1 , #0x0010
	B DEFAULTBM
	 
DEFAULTBM
	MOV R11,#Green
	BL Drawsquare
	 
	POP {R11-R12,PC}
	ENDFUNC