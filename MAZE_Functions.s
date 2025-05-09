	AREA    MazeData, DATA, READONLY  ; Define a data section
ROW    
		DCD    0x00000000,0x13EBFF3A,0x1629002A,0x14A97F2E,0x15AF4120,0x1BED61E0,0x15EF210E,0x14092ECA,0x14F92A4A,0x17812AFA,0x1C1F3C80,0x08150480,0x0BD50584,0x0A57FD84,0x0B500174,0x0950FC1C,0x09708410,0x0F00BF10,0x01FF80FE,0x00000002
			
ROW2		
		DCD    0x10000000
		DCD    0x13EDFFFE
		DCD    0x16290010
		DCD    0x14A97F10
		DCD    0x15AF411C
		DCD    0x1D216174
		DCD    0x15EF2184
		DCD    0x14092E84
		DCD    0x14F92A80
		DCD    0x17812A80
		DCD    0x1C1F3CFA
		DCD    0x0815044A
		DCD    0x0BD505CA
		DCD    0x0A57FD0E
		DCD    0x0B5001E0
		DCD    0x0950FC20
		DCD    0x0970842E
		DCD    0x0F00BFAA
		DCD    0x01FF803A
		DCD    0x00000002

;--- Colors ---
Red     EQU 0xF800 
Green   EQU 0x07E0
Blue    EQU 0x001F 
Yellow  EQU 0xFFE0
White   EQU 0xFFFF
Black   EQU 0x0000
Orange	EQU 0xFC00	
	AREA MazeData2, DATA, READWRITE
;CELLPLACE 29
			  
	AREA    |.text|, CODE, READONLY
		IMPORT  TFT_WriteCommand
		IMPORT  TFT_WriteData
		IMPORT  TFT_DrawImage
		IMPORT  TFT_Filldraw4INP
		IMPORT  delay
		IMPORT  GET_state
		;EXPORT  TFT_DrawMazeGrid
		;EXPORT  TFT_DrawMazeGrid2
		;EXPORT  TFT_DrawMazeGrid3
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
    CMP R4, #32; Check all 8 columns
    BEQ Next_Row_MAPMM

	
    MOV R10, #1
    LSL R10, R4      ; R10 = (1 << Column)

    TST R9, R10         ; Test if bit is 1
    BEQ SkipDrawMM        ; If 0, skip
    ; If bit is 1, draw a wall block which is square
    BL Drawsquare	
SkipDrawMM
    ADD R2, #16		; Move to next column (50 pixels left)
    ADD R4, #1
    B COL_LOOPMM

Next_Row_MAPMM
    ADD R1, #16   ; Move ROW position 50 pixels UP
    ADD R3, #4
    B ROW_LOOPMM

FINISH_MAPMM
	; 2. Draw Outer Borders Red
    ; Bottom border
    MOV R6, #0x0000
    MOV R7, #0x0010
    MOV R8, #0x01C0
    MOV R9, #0x01D0
    MOV R11, #Green
    BL TFT_Filldraw4INP

    ; Top border
    MOV R6, #0x0130
    MOV R7, #0x0140
    MOV R8, #0x0010
    MOV R9, #0x0020
    MOV R11, #Blue
    BL TFT_Filldraw4INP
	POP {R0-R12, PC}
	ENDFUNC




Drawsquare FUNCTION;take parameters at r1 and r2
	PUSH{R0-R12,LR}
	MOV R6, R1   ; X start
	ADD R7,	R1 ,#0X0010
	MOV R8,	R2
	ADD R9, R2 ,#0X0010
	BL TFT_Filldraw4INP
	POP {R0-R12, PC}
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
	 CMP R1 , #0X000
	 BEQ DEFAULTBM
	 ADD R1 , R1 , #0x0010
	 B DEFAULTBM
	 
DEFAULTBM
	 MOV R11,#Green
	 BL Drawsquare
	 pop{R11-R12,PC}
	 ENDFUNC
	 
	 