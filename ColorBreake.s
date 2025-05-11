	AREA    ColorBreakeData, DATA, READONLY
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
	
		
	AREA ColorBreakMAP, DATA, READWRITE
		
		
PlayerColor DCB 0x00 


colorBreakMap
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
			
	AREA    ColorBreakeCode, CODE, READONLY
    IMPORT  TFT_WriteCommand
    IMPORT  TFT_WriteData
    IMPORT  TFT_DrawImage
	IMPORT  TFT_Filldraw4INP
    IMPORT  delay
	IMPORT  GET_state2			
	






Draw_Breaker_Map FUNCTION
	PUSH {R0-R12, LR}
	POP{R0-R12,PC}
	ENDFUNC
	
	
	
CHECK_BLOCK FUNCTION
	PUSH {R0-R12, LR}
	POP{R0-R12,PC}
	ENDFUNC
	
	
	
	
	
	
DRAW_BALL_MOVEMENT FUNCTION
	PUSH {R0-R12, LR}
	POP{R0-R12,PC}
	ENDFUNC
	
	
	
	
CHECK_WIN_BREAKER FUNCTION
	PUSH {R0-R12, LR}
	POP{R0-R12,PC}
	ENDFUNC
		
	
main_Color_Break FUNCTION
;DRAW MAP 
;GET_STATE
;DRAW BALL MOVEMENT(may call CHECK_BLOCK )
;CHECK_BLOCK;(Color_Change,delete block,KILL)
;check win
	PUSH {R0-R12, LR}
	POP{R0-R12,PC}
	ENDFUNC


			
			
	END		
			
			
			
			
			
			
			
			
			
			