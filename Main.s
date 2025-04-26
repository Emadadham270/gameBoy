	AREA MYDATAS, DATA, READONLY
	;--- Colors ---
Red     EQU 0Xf800 
Green   EQU 0xF0FF
Blue    EQU 0x02ff 
Yellow  EQU 0xFfe0
White   EQU 0xffff
Black	EQU 0x0000
RCC_BASE        EQU     0x40023800
GPIOA_BASE      EQU     0x40020000
GPIOB_BASE        EQU        0x40020400
GPIOB_IDR 	  	  EQU		 GPIOB_BASE+0x10
; Define register offsets
RCC_AHB1ENR     EQU     0x30
GPIO_MODER      EQU     0x00
GPIO_OTYPER     EQU     0x04
GPIO_OSPEEDR    EQU     0x08
GPIO_PUPDR      EQU     0x0C
GPIO_IDR        EQU     0x10
GPIO_ODR        EQU     0x14	
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
	IMPORT Update_Left_Sidebar
	IMPORT TFT_MoveCursor 
	IMPORT X1
	IMPORT O1
	IMPORT Main_Game_XO
	IMPORT DrawBorder
X_start			DCB		0X70
X_end			DCB		0XD2
Y_start			DCB		0X70
Y_END			DCB		0XD2

__main FUNCTION


	;FINAL TODO: CALL FUNCTION SETUP
	;BL SETUP ; all THE INTIALIZATION
	LDR R0, =RCC_BASE + RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, R1, #0x0f
    STR R1, [R0]

    ; Configure GPIOE as General Purpose Output Mode
    LDR R0, =GPIOA_BASE + GPIO_MODER
    LDR R1, =0x55555555  
    STR R1, [R0]

    ; Configure output speed for GPIOE (High Speed)
    LDR R0, =GPIOA_BASE + GPIO_OSPEEDR
    LDR R1, =0xFFFFFFFF  
    STR R1, [R0]
	
	
	; Configure PORT B AS INPUT 
 	LDR R0, =GPIOB_BASE + GPIO_MODER               
 	MOV R2, #0x00000000    
 	STR R2, [R0]
 	;SPEED PORT B
 	LDR R0, =GPIOB_BASE + GPIO_OSPEEDR
 	MOV R2, #0xFFFFFFFF
 	STR R2, [R0]
	;PUSH/PULL
 	LDR R0, =GPIOB_BASE + GPIO_OTYPER
 	MOV R2, #0x00000000
 	STR R2, [R0]
	 	;PULL UP 
 	LDR R0, =GPIOB_BASE + GPIO_PUPDR
 	MOV R2, #0x55555555
 	STR R2, [R0]
    ; Initialize TFT
    BL TFT_Init
    ; Fill screen with color
	;MOV R1, #0X02        ; Start X
    ;MOV R2, #0X70         ; Start Y
	;LDR R3, =X1		    ; Load image address
    ;BL TFT_DrawImage
	BL Main_Game_XO
	;MOV R0,;THENUM OF THE PHOTO 
	;MOV R5,#NUMX
	;MOV R6, #NUMY
	;BL ;DRAW PHOTO
	;MOV R10,#0
    ; Fill screen with color (line)
    ;MOV R0, #Black
	;MOV R11,#Yellow
;INNERLOOP
	;MOV R1,#0X70
	;MOV R2,#0X70
;IN2
	;BL GET_state
	;AND R10,R10,#0X001F 
	;CMP R10,#0
	;BEQ IN2
	;CMP R10,#16
	;BEQ ENTER5
	;BL TFT_MoveCursor 
	;BL IN2
	
	
;ENTER5
	;LDR R3,=X1
	;BL TFT_DrawImage
	;BL INNERLOOP
    ENDFUNC
	
	END