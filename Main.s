	AREA MYDATAS, DATA, READONLY
	;--- Colors ---
Red     EQU 0Xf800 
Green   EQU 0xF0FF
Blue    EQU 0x02ff 
Yellow  EQU 0xFfe0
White   EQU 0xffff
Black	EQU 0x0000
	
	AREA MYCODE, CODE, READONLY
	
	EXPORT __main
	IMPORT SETUP
	IMPORT TFT_WriteCommand
	IMPORT TFT_WriteData
	IMPORT TFT_Init
	IMPORT TFT_DrawImage
	IMPORT TFT_DrawGrid
	IMPORT TFT_Filldraw4INP
	IMPORT GET_state
	IMPORT delay
	IMPORT Draw_XO
	IMPORT Check_Win
	IMPORT	DrawTA3ADOL
	IMPORT	DrawOWINS
	IMPORT	DrawXWINS	
	IMPORT Update_Left_Sidebar
	IMPORT  TFT_ReDrawSquare
	IMPORT X1
	IMPORT O1
	IMPORT XWINS
	IMPORT OWINS
	IMPORT ta3adol

__main FUNCTION
    

	;FINAL TODO: CALL FUNCTION SETUP
	BL SETUP ; all THE INTIALIZATION
    ; Initialize TFT
    BL TFT_Init
    ; Fill screen with color 
	;BL TFT_DrawGrid
	;MOV R0,;THENUM OF THE PHOTO 
	;MOV R5,#NUMX
	;MOV R6, #NUMY
	;BL ;DRAW PHOTO
	MOV R10,#0
	MOV R6,#0X0002
	MOV R7,#0X0062
	MOV R8,#0X0002
	MOV R9,#0X0062
    ; Fill screen with color (line)
    MOV R0, #Blue
	MOV R11,#Red
	BL TFT_ReDrawSquare
INNERLOOP

	BL GET_state
	AND R10,R10,#0X000F
	CMP R10,#0
	BEQ INNERLOOP
	CMP R10,#1
	BEQ ENTER1
	CMP R10,#2
	BEQ ENTER2
	CMP R10,#4
	BEQ ENTER3	
	CMP R10,#8
	BEQ ENTER4
	BL INNERLOOP
ENTER1
	BL TFT_DrawGrid
	BL INNERLOOP
ENTER2
	MOV R1, #0        ; Start X
    MOV R2, #0         ; Start Y
	LDR R3, =XWINS     ; Load image address
    BL TFT_DrawImage
	BL INNERLOOP
ENTER3
	MOV R1, #0X02        ; Start X
    MOV R2, #0X70         ; Start Y
	LDR R3, =OWINS     ; Load image address
    BL TFT_DrawImage
	BL INNERLOOP
ENTER4
	MOV R1, #0X70        ; Start X
    MOV R2, #0X70         ; Start Y
	LDR R3, =ta3adol     ; Load image address
    BL TFT_DrawImage
	BL INNERLOOP	

    ENDFUNC
	
	
	
	
	
	END