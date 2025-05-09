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
	IMPORT CONFIGURE_PORTS
	IMPORT TFT_WriteCommand
	IMPORT TFT_WriteData
	IMPORT TFT_Init
	IMPORT TFT_DrawImage
	IMPORT TFT_Filldraw4INP
	IMPORT GET_state
	IMPORT delay			
	IMPORT Main_Game_XO
	IMPORT MainGame_LongCat
	IMPORT  TFT_DrawMapM
	IMPORT Num_to_LCD
	IMPORT DrawDigit
	IMPORT Init_RandomSeed
	IMPORT Get_Random
	
__main FUNCTION

	BL Init_RandomSeed
	BL CONFIGURE_PORTS
    ; Initialize TFT
    BL TFT_Init
	BL Get_Random
    MOV R1, #50
	MOV R2, #50
	MOV R3, #2
	MOV R4, #16
	MOV R5, #4
	MOV R11, #Blue
	BL Num_to_LCD
	;BL TFT_DrawMapM
	;BL MainGame_LongCat
	;BL Main_Game_XO
    ENDFUNC
	
	END
	