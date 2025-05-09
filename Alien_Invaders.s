	AREA USEABLE, DATA, READWRITE


Player_Bullets
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
	
	
Enemy_Bullets
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
enemy DCB 0x00
tempenemy DCB 0x00
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
	LDR   R0, =Player_Bullets      ; R0 = base address of Bullets
    MOV   R1, R3             ; R1 = index
    LSL   R1, R1, #1          ; R1 = R1 * 2 (convert to byte offset)
    ADD   R0, R0, R1          ; R0 = address of Alien_Map[R3]
    LDRH  R2,[R0]            ; R2 = contents of Alien_Map[R3]
	ORR   R2, R2, #1
	STRH  R2,[R0]
	POP {R0-R12,PC}
	ENDFUNC

; R3 = Position of Enemy
ADD_BULLET_ALIEN FUNCTION
	PUSH {R0-R12,LR}
	LDR   R0, =Enemy_Bullets      ; R0 = base address of Bullets
    MOV   R1, R3             ; R1 = index
    LSL   R1, R1, #1          ; R1 = R1 * 2 (convert to byte offset)
    ADD   R0, R0, R1          ; R0 = address of Alien_Map[R3]
    LDRH  R2,[R0]            ; R2 = contents of Alien_Map[R3]
	ORR   R2, R2, #0x8000
	STRH  R2,[R0]
	POP {R0-R12,PC}
ENDFUNC
	
;------------------------------
; DrawBullet Function for Player
;------------------------------
DrawBullet_Player FUNCTION
    PUSH {R0-R12,LR}

    MOV R5 , #0            ; R5 = INDEX OF THE ARRAYS
DrawBullet_Outer_Loop_P
    LDR R0 , =Player_Bullets
    MOV R1 , R5            ; R1 = index of the column
    LSL R1 , R1, #1        ; R1 = R1 * 2 (convert to byte offset)
    ADD R0 , R0, R1        ; R0 = address of Player_Bullet[R5]
    LDRH R2 , [R0]         ; R2 = contents of Player_Bullet[R5]

    MOV R6 , #32              ; Init the R6 = X_Start (CELL) of any column
    MOV R7 , #48              ; Init the R7 = X_END (CELL) of any column

    LSL R8 , R5 , #4         ; Y_START = R5 * 16
    LSL R9 , R5 , #4                
    ADD R9 , R9 , #16        ; Y_END = R5 * 16 + 16  

    MOV R4 , #0              ; Bit 0
DrawBullet_Inner_Loop_P
    MOV R1 , #1              ; Bit mask
    LSL R1 , R1 , R4         ; SHIFT THE 1 BIT IN R1 TO THE INDEX OF THE ARRAY[R5]   
    AND R3 , R2 , R1         ; NOW R3 = ..0000i000.. -> 1 IN i = ARRAY[R5][R4]

    ; If i = 0
    CMP R3 , #0
    BNE SKIP_DRAW_Bullet_P

;-----------------------
;   Draw the Bullet

    MOV R10 , R8             ; SAVE THE OLD R8 IN R10
    MOV R12 , R9             ; SAVE THE OLD R9 IN R12

    ADD R8 , R8 , #4         ; R8 OF THE BULLET (CELL START + 4)
    SUB R9 , R9 , #4         ; R9 OF THE BULLET (CELL END - 4)

    MOV R11 , #Black         ; Bullet Color

    BL TFT_Filldraw4INP

    MOV R8 , R10             ; RETURN THE OLD R8 SO WE WILL USE IT IN THE LOOP
    MOV R9 , R12             ; RETURN THE OLD R9 SO WE WILL USE IT IN THE LOOP

    B Continue_Ok_P
;-----------------------

SKIP_DRAW_Bullet_P
    MOV R11 , #Red           ; Background_colour
    BL TFT_Filldraw4INP     

Continue_Ok_P
    ADD  R6 , R6 , #16       ; ADD X_START = X_START + 16
    ADD  R7 , R7 , #16       ; ADD X_END = X_END + 16

    ADD R4 , R4 ,#1          ; ADD R4 = R4 + 1 --> ARRAY[R5][R4] 
    CMP R4 , #16
    BLT DrawBullet_Inner_Loop_P    ;If less than == BLT

    ADD R5 , R5 , #1
    CMP R5 , #30 
    BLT DrawBullet_Outer_Loop_P

    POP {R0-R12,PC}
    ENDFUNC


;------------------------------
; DrawBullet Function for Enemy
;------------------------------
DrawBullet_Enemy FUNCTION
    PUSH {R0-R12,LR}

    MOV R5 , #0            ; R5 = INDEX OF THE ARRAYS
DrawBullet_Outer_Loop_E
    LDR R0 , =Enemy_Bullets
    MOV R1 , R5            ; R1 = index of the column
    LSL R1 , R1, #1        ; R1 = R1 * 2 (convert to byte offset)
    ADD R0 , R0, R1        ; R0 = address of Player_Bullet[R5]
    LDRH R2 , [R0]         ; R2 = contents of Player_Bullet[R5]

    MOV R6 , #32              ; Init the R6 = X_Start (CELL) of any column
    MOV R7 , #48              ; Init the R7 = X_END (CELL) of any column

    LSL R8 , R5 , #4         ; Y_START = R5 * 16
    LSL R9 , R5 , #4                
    ADD R9 , R9 , #16        ; Y_END = R5 * 16 + 16  

    MOV R4 , #0              ; Bit 0
DrawBullet_Inner_Loop_E
    MOV R1 , #1              ; Bit mask
    LSL R1 , R1 , R4         ; SHIFT THE 1 BIT IN R1 TO THE INDEX OF THE ARRAY[R5]   
    AND R3 , R2 , R1         ; NOW R3 = ..0000i000.. -> 1 IN i = ARRAY[R5][R4]

    ; If i = 0
    CMP R3 , #0
    BNE SKIP_DRAW_Bullet_E


;   Draw the Bullet

    MOV R10 , R8             ; SAVE THE OLD R8 IN R10
    MOV R12 , R9             ; SAVE THE OLD R9 IN R12

    ADD R8 , R8 , #4         ; R8 OF THE BULLET (CELL START + 4)
    SUB R9 , R9 , #4         ; R9 OF THE BULLET (CELL END - 4)

    MOV R11 , #Black         ; Bullet Color

    BL TFT_Filldraw4INP

    MOV R8 , R10             ; RETURN THE OLD R8 SO WE WILL USE IT IN THE LOOP
    MOV R9 , R12             ; RETURN THE OLD R9 SO WE WILL USE IT IN THE LOOP

    B Continue_Ok_E


SKIP_DRAW_Bullet_E
    MOV R11 , #Red           ; Background_colour
    BL TFT_Filldraw4INP     

Continue_Ok_E
    ADD  R6 , R6 , #16       ; ADD X_START = X_START + 16
    ADD  R7 , R7 , #16       ; ADD X_END = X_END + 16

    ADD R4 , R4 ,#1        ; ADD R4 = R4 + 1 --> ARRAY[R5][R4] 
    CMP R4 , #16
    BLT DrawBullet_Inner_Loop_E    ;If less than == BLT

    ADD R5 , R5 , #1
    CMP R5 , #30 
    BLT DrawBullet_Outer_Loop_E

    POP {R0-R12,PC}
    ENDFUNC


MOVE_BULLET FUNCTION
	PUSH {R0-R12,LR}
	;MOV R3, #0 ; index
	MOV R2, #30

MovePlayerLoop
    CMP R3, R2
    BEQ CheckCollision1
	
	;LoopEachColumn
	LDR R0, =Player_Bullets      	
	LDR R1, =Enemy_Bullets
	MOV R3, #0                  ; index = 0
	
    LDRH R4, [R0, R3, LSL #1]   ; Player column
    LSL R4, R4, #1              ; Shift up
    STRH R4, [R0, R3, LSL #1]

    ADD R3, R3, #1
    B MovePlayerLoop

CheckCollision1
    MOV R3, #0

CollisionLoop1
    CMP R3, R2
    BEQ MoveOpponent

    LDRH R4, [R0, R3, LSL #1]   ; Player
    LDRH R5, [R1, R3, LSL #1]   ; Opponent
    AND R6, R4, R5              ; Collision mask, if collision occurs then R6 has 1 in the index where collision happened
    BIC R4, R4, R6              ; Clear bits in player, 
    BIC R5, R5, R6              ; Clear bits in opponent
    STRH R4, [R0, R3, LSL #1]
    STRH R5, [R1, R3, LSL #1]

    ADD R3, R3, #1
    B CollisionLoop1

MoveOpponent
    MOV R3, #0

MoveOpponentLoop
    CMP R3, R2
    BEQ CheckCollision2

    LDRH R4, [R1, R3, LSL #1]   ; Opponent column
    LSR R4, R4, #1              ; Shift down
    STRH R4, [R1, R3, LSL #1]

    ADD R3, R3, #1
    B MoveOpponentLoop

CheckCollision2
    MOV R3, #0

CollisionLoop2
    CMP R3, R2
    BEQ DoNe

    LDRH R4, [R0, R3, LSL #1]   ; Player
    LDRH R5, [R1, R3, LSL #1]   ; Opponent
    AND R6, R4, R5              ; Collision mask
    BIC R4, R4, R6              ; Clear bits in player
    BIC R5, R5, R6              ; Clear bits in opponent
    STRH R4, [R0, R3, LSL #1]
    STRH R5, [R1, R3, LSL #1]

    ADD R3, R3, #1
    B CollisionLoop2
DoNe
	POP {R0-R12,LR}
	ENDFUNC
	
Draw_Enemy FUNCTION
	PUSH {R0-R12, LR}
	POP {R0-R12, PC}
	ENDFUNC

move_player FUNCTION
    PUSH {R4-R7, LR}         ; // Save registers and return address

   ; // R3 holds the current position (1 to 28)
    ;// R7 holds the direction (1 = right, 2 = left)

    CMP R7, #1                ;// Check if moving right
    BEQ move_right
    CMP R7, #2                ;// Check if moving left
    BEQ move_left
    B end_                     ;// If R7 is neither 1 nor 2, do nothing

move_right
    CMP R3, #28               ;// Check if at the rightmost position
    BEQ end_                   ;// If yes, do nothing
    ADD R3, R3, #1            ;// Move right: position += 1
    B redraw

move_left
    CMP R3, #1                ;// Check if at the leftmost position
    BEQ end_                   ;// If yes, do nothing
    SUB R3, R3, #1            ;// Move left: position -= 1
    B redraw

redraw
   ; // Prepare arguments for draw_player function
    ;// R0: player center position
    ;/;/ R1: color
    MOV R0, R3
	MOV R12,#0x16
    MUL R0, R0,R12
    MOV R8, #0x10
    MOV R9, #0x40
    ADD R6,R0,#0x30 
    SUB R7,R0,#0x30   
    ;LDR R11, =player_color     ;// Load the player's color (assume defined elsewhere)
    ; BL TFT_Filldraw4INP            ;// Call the existing draw function

end_
    POP {R4-R7, PC}    
	
    ENDFUNC
	
	END
		