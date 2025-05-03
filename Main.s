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
 	IMPORT  TFT_DrawMazeGrid
	IMPORT  TFT_DrawMazeGrid2
	IMPORT  TFT_DrawMazeGrid3			
	IMPORT Main_Game_XO
	IMPORT MainGame_LongCat
	IMPORT  TFT_DrawMapM
__main FUNCTION


	;FINAL TODO: CALL FUNCTION CONFIGURE_PORTS
	BL CONFIGURE_PORTS
    ; Initialize TFT
    BL TFT_Init
	;BL TFT_DrawMapM
	BL MainGame_LongCat

    ENDFUNC
	
	END
	