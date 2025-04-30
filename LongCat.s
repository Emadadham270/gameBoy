    AREA    LEVELSDATA, DATA, READONLY

Level1Map      DCB #0b11000001
			   DCB #0b11001001
			   DCB #0b11001011
			   DCB #0b10000001
			   DCB #0b10100101
			   DCB #0b10000001

Leve1StartCell DCB #36
		;--- Colors ---
Red     	   EQU 0XF800 
Green   	   EQU 0x07E0
Blue    	   EQU 0x001F 
Yellow  	   EQU 0xFFE0
White   	   EQU 0xFFFF
Black		   EQU 0x0000	
		
	AREA    MYDATA, DATA, READWRITE



	
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
	PUSH {R0-R10, LR}
	;TODO
	
	POP {R0-R12, PC}
	ENDFUNC

;------------------------
; Draw_Snake_Movement
;------------------------
Draw_Snake_Movement FUNCTION
	PUSH {R0-R10, LR}
	;TODO
	
	POP {R0-R12, PC}
	ENDFUNC

;------------------------
; Move_Snake
;------------------------
Move_Snake FUNCTION
	PUSH {R0-R10, LR}
	;TODO
	
	POP {R0-R12, PC}
	ENDFUNC

;------------------------
; Check_End
;------------------------
Check_End FUNCTION
	PUSH {R0-R10, LR}
	;TODO
	
	POP {R0-R12, PC}
	ENDFUNC