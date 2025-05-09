	AREA USEABLE, DATA, READWRITE

Alien_Map
	DCW 0x00 
	DCW 0x00
	DCW 0x00
    DCW 0x00
	DCW 0x00
	DCW 0x00
	DCW 0x00
	DCW 0x00
    DCW 0x00
	DCW 0x00
	DCW 0x00
	DCW 0x00
	DCW 0x00
    DCW 0x00
	DCW 0x00
	DCW 0x00
	DCW 0x00
	DCW 0x00
    DCW 0x00
	DCW 0x00
	DCW 0x00
	DCW 0x00
	DCW 0x00
    DCW 0x00
	DCW 0x00
	DCW 0x00
	DCW 0x00
	DCW 0x00
    DCW 0x00
	DCW 0x00 
	
	
	AREA    CODEY, CODE, READONLY
    IMPORT  TFT_WriteCommand
    IMPORT  TFT_WriteData
    IMPORT  TFT_DrawImage
	IMPORT  TFT_Filldraw4INP
    IMPORT  delay
	IMPORT  GET_state
		
; R3 = Position of player		
ADD_BULLET_PLAYER FUNCTION 
	PUSH {R0-R12,LR}
	LDR   R0, =Alien_Map      ; R0 = base address of Alien_Map
    MOV   R1, R3             ; R1 = index
    LSL   R1, R1, #1          ; R1 = R1 * 2 (convert to byte offset)
    ADD   R0, R0, R1          ; R0 = address of Alien_Map[R3]
    LDRH  R2,[R0]            ; R2 = contents of Alien_Map[R3]
	ORR   R2, R2,#1
	STRH  R2,[R0]
	POP {R0-R12,PC}
	ENDFUNC


ADD_BULLET_ALIEN FUNCTION
	
	
	
	
ENDFUNC
	
MOVE_BULLET FUNCTION
	
	ENDFUNC

DELETE_BULLET FUNCTION
	
	ENDFUNC
		
	END