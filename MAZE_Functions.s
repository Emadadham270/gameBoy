	AREA    MazeData, DATA, READONLY  ; Define a data section
	IMPORT	MAZELOGO
	IMPORT XO
	IMPORT LONGCAT
	IMPORT AEROSPACE	
ROW1		
	DCD    0X10000000
	DCD    0X1C101FF0
	DCD    0X14103010
	DCD    0X17A07030
	DCD    0X109FD000
	DCD    0X10901010
	DCD    0X11901010
	DCD    0X11101010
	DCD    0X11F01010
	DCD    0X10101010
	DCD    0X10101010
	DCD    0X1F901010
	DCD    0X10909FFC
	DCD    0X10909104
	DCD    0X10F09104
	DCD    0X101FC11C
	DCD    0X1FF01F30
	DCD    0X0000103E
	DCD    0X00000012
	DCD    0X00000002
ROW2
    DCD 0x10000000
    DCD 0x13FFFFFF    
    DCD 0x12000010    
    DCD 0x17F7FF10    
    DCD 0x1402101C    
    DCD 0x15A10174    
    DCD 0x156B2184    
    DCD 0x14A92E84    
    DCD 0x17F92A80    
    DCD 0x1C012A80    
    DCD 0x181F3CFA    
    DCD 0x0A15044A    
    DCD 0x0BD505CA    
    DCD 0x0A57FF0E    
    DCD 0x0B5001E0    
    DCD 0x0950FC20    
    DCD 0x0970842E    
    DCD 0x0F00BFAA    
    DCD 0x01FF803A    
    DCD 0x00000002    	
ROW3		
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
		DCD    0x0A57FF0E
		DCD    0x0B5001E0
		DCD    0x0950FC20
		DCD    0x0970842E
		DCD    0x0F00BFAA
		DCD    0x01FF803A
		DCD    0x00000002



CellStart	DCB 28
CellWin		EQU 609
;--- Colors ---
Red     EQU 0xF800 
Green   EQU 0x07E0
Blue    EQU 0x001F 
Yellow  EQU 0xFFE0
White   EQU 0xFFFF
Black   EQU 0x0000
Orange	EQU 0xFC00	
	AREA USEABLE, DATA, READWRITE

MAZEMAP		
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000	


			  
	AREA    |.text|, CODE, READONLY
		IMPORT  TFT_WriteCommand
		IMPORT  TFT_WriteData
		IMPORT  TFT_DrawImage
		IMPORT  TFT_Filldraw4INP
		IMPORT  delay
		IMPORT  GET_state
		EXPORT MAIN_MAZE	
		EXPORT  TFT_DrawMapM
		IMPORT Num_to_LCD
		
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
	
	
	LDR R0, =MAZEMAP   ; Load address of Level Map into R0
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
DrawMan FUNCTION;take parameters at r1 and r2
	PUSH{R0-R12,LR}
	MOV R11,#Green
	
	ADD R6, R1 ,#0
	ADD R7,	R1 ,#5
	ADD R8,	R2 ,#5
	ADD R9, R2 ,#7
	BL TFT_Filldraw4INP
	ADD R6, R1 ,#0
	ADD R7,	R1 ,#5
	ADD R8,	R2 ,#9
	ADD R9, R2 ,#11
	BL TFT_Filldraw4INP
	ADD R6, R1 ,#5
	ADD R7,	R1 ,#11
	ADD R8,	R2 ,#5
	ADD R9, R2 ,#11
	BL TFT_Filldraw4INP
	ADD R6, R1 ,#11
	ADD R7,	R1 ,#12
	ADD R8,	R2 ,#3
	ADD R9, R2 ,#13
	BL TFT_Filldraw4INP
	ADD R6, R1 ,#7
	ADD R7,	R1 ,#11
	ADD R8,	R2 ,#3
	ADD R9, R2 ,#4
	BL TFT_Filldraw4INP
	ADD R6, R1 ,#7
	ADD R7,	R1 ,#11
	ADD R8,	R2 ,#12
	ADD R9, R2 ,#13
	BL TFT_Filldraw4INP
	ADD R6, R1 ,#12
	ADD R7,	R1 ,#16
	ADD R8,	R2 ,#6
	ADD R9, R2 ,#10
	BL TFT_Filldraw4INP
	MOV R11,#Red
	ADD R6, R1 ,#14
	ADD R7,	R1 ,#15
	ADD R8,	R2 ,#7
	ADD R9, R2 ,#9
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

check_win_lose FUNCTION
    PUSH {R4-R8,LR}              ; Save registers to comply with calling conventions
	LDR R0,=MAZEMAP
    MOV R4, R3, LSR #5       ;R4 = row = cell number / 32 (shift right by 5)
	LSL R4,#2
    AND R5, R3, #0x1F         ; R5 = column = cell number % 32 (mask with 31)
    LDR R6, [R0, R4]  ; Load the row�s word from [R0 + row * 4]
    LSR R6, R6, R5            ; Shift right by column to get the cell�s bit
    TST R6, #1                ; Test if the bit is 1 (lava)
    BEQ lose                  ; If lava, go to lose
	MOV R8,#CellWin
    CMP R3,	R8	;// Check if cell is 639 (exit at row 19, column 31) THSI IS THE WINNING CELL
    
    BEQ win                   ;// If at exit and on a road, go to win
    MOV R0, #0                ;// Otherwise, R0 = 0 (continue)
    B endCHECK                    ; // Go to end
lose
    MOV R0, #2                ;// R0 = 2 (lose)
    B endCHECK                     ;// Go to end
win
    MOV R0, #1                ;;// R0 = 1 (win)
endCHECK
    POP {R4-R8,PC}               ;// Restore registers
    ENDFUNC                     ;// Return


Redraw_player	FUNCTION; Take X-R1; Y-R2 : Input in R10
	 PUSH{R0-R2,R4-R12,LR}
	 LSR R6, R3, #5         ; R6 = k = R3 / 32 (row index from bottom, 0 to 5)
	 AND R7, R3, #31         ; R7 = m = R3 % 32 (bit position in byte)
	 LSL R1, R6, #4             ; R8 will hold row index from top (0 to 5)
     LSL R2, R7, #4         ; r = 5 - k (row index: 5 for bottom, 0 for top)
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
	 ADD R3 , R3,#1
	 B DEFAULTBM
	 
MOVE_DOWNBM
	 CMP R2 , #0X0000
	 BEQ DEFAULTBM
	 SUB R2 , R2 , #0x0010
	 SUB R3 , R3,#1
	 B DEFAULTBM
	 
MOVE_RIGHTBM
	 CMP R1 , #0X0000
	 BEQ DEFAULTBM
	 SUB R1 , R1 , #0x0010
	 SUB R3 , R3,#32
	 B DEFAULTBM
	 
MOVE_LEFTBM
	 CMP R1 , #0X0140
	 BEQ DEFAULTBM
	 ADD R1 , R1 , #0x0010
	 ADD R3 , R3,#32
	 B DEFAULTBM
	 
DEFAULTBM
	 BL DrawMan
	 pop{R0-R2,R4-R12,PC}
	 ENDFUNC
	 
	 
MAIN_MAZE	FUNCTION
	PUSH {R0-R12, LR} 
	MOV R9,#1
New_Level_MAZE	PUSH{R0-R8,R10-R12}
	MOV R12, R9 ; R12 = level
	SUB R12, #1 ; zero-based (level-1)
	MOV R2, #80 ; 32 bytes per level (8 words � 4)
	MUL R12, R2 ; R12 = (level-1)*32 = byte offset


    LDR R0,  =ROW1    ; base of all layouts
    ADD R0,  R12               ; R0 -> current level layout

    LDR R1,  =MAZEMAP    ; destination RAM buffer
    MOV R2,  #20                ; copy 8 words
copy_level_MAZE
	LDR R3, [R0], #4 ; read one word, post-inc source
	STR R3, [R1], #4 ; write it, post-inc dest
	SUBS R2, R2, #1
	BNE copy_level_MAZE

    BL TFT_DrawMapM
	PUSH{R0-R5,R11}
	MOV     R0,  R9                ; R0 = level (1,2,3�)
	MOV R1,280
	MOV R2,450
	MOV R3,#2
	MOV R4,#16
	MOV R5,#1
	MOV R11,#Yellow         
	BL Num_to_LCD
	POP{R0-R5,R11}
	POP{R0-R8,R10-R12}
	LDR R3,=CellStart
	LDR R3,[R3]
	MOV R0,#0
LOOPINPUT
	BL GET_state
	AND R10,R10, #0x002F
	CMP R10, #32      ;eXIT
	BEQ EXIT_MAZE
	CMP R10, #00      ;Keep looping while input = 0 or ENTER
	BEQ LOOPINPUT
	BL Redraw_player
	BL check_win_lose
	CMP R0,#1
	BEQ WINNERWIN
	CMP R0,#2
	BEQ LOSSERLOS	
	B LOOPINPUT
WINNERWIN
	PUSH{R6-R9}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color BLUE
    MOV R11, #Green
	BL TFT_Filldraw4INP
	POP{R6-R9}
	ADD     R9,  #1                ; R9 = R9 + 1
    CMP     R9,  #3       ; finished all levels?
    BGT     EXIT_MAZE                ; yes ? quit the game
    B       New_Level_MAZE         ; no  ? load next level

LOSSERLOS
	PUSH{R6-R9}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color BLUE
    MOV R11, #Red
	BL TFT_Filldraw4INP
	POP{R6-R9}
	B       New_Level_MAZE         ; restart same level

EXIT_MAZE	
	POP     {R0-R12, PC}  
	ENDFUNC
	END