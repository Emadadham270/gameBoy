	AREA MYDATAS, DATA, READONLY
		;--- Colors ---
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
	

	AREA MYCODE, CODE, READONLY
	
	EXPORT __main
	IMPORT CONFIGURE_PORTS
	IMPORT TFT_WriteCommand
	IMPORT TFT_WriteData
	IMPORT TFT_Init
		
	IMPORT TFT_DrawImage
	IMPORT TFT_Filldraw4INP
	IMPORT GET_state
	IMPORT delay			
	IMPORT  TFT_DrawMapM
	IMPORT Num_to_LCD
	IMPORT DrawDigit
	IMPORT Init_RandomSeed
	IMPORT Get_Random
	IMPORT UI	
	IMPORT Draw_Map_Break
	IMPORT Draw_Filled_Circle30	
	IMPORT main_Color_Break	
	IMPORT UP_D0WN_MOVEMENT	
	IMPORT DRAW_BALL_MOVEMENT 
	IMPORT Destroy_Block
__main FUNCTION
	BL Init_RandomSeed
	BL CONFIGURE_PORTS
    ; Initialize TFT
    BL TFT_Init

	BL UI
    ENDFUNC
	
	END
	