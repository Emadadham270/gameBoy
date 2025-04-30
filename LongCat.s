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
; Move_Snake
;------------------------
Move_Snake FUNCTION
	PUSH {R0-R12, LR}
	;TODO
	
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