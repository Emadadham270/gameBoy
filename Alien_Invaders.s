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
	
enemy DCB 0x7F
Score DCW 0X0000
Hearts DCW 0X0003       ;Initialize Heart with 3

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
	IMPORT  Num_to_LCD
	IMPORT  Get_Random
	IMPORT  Init_RandomSeed
; R3 = Position of player		
ADD_BULLET_PLAYER FUNCTION 
	PUSH {R0-R3,LR}
	LDR   R0, =Player_Bullets      ; R0 = base address of Bullets
    MOV   R1, R3             ; R1 = index
    LSL   R1, R1, #1          ; R1 = R1 * 2 (convert to byte offset)
    ADD   R0, R0, R1          ; R0 = address of Alien_Map[R3]
    LDRH  R2,[R0]            ; R2 = contents of Alien_Map[R3]
	ORR   R2, R2, #1
	STRH  R2,[R0]
	POP {R0-R3,PC}
	ENDFUNC

; R4 = Position of Enemy
ADD_BULLET_ALIEN FUNCTION
	PUSH {R0-R4,LR}
	LDR   R0, =Enemy_Bullets      ; R0 = base address of Bullets
    MOV   R1, R4             ; R1 = index
    LSL   R1, R1, #1          ; R1 = R1 * 2 (convert to byte offset)
    ADD   R0, R0, R1          ; R0 = address of Alien_Map[R3]
    LDRH  R2,[R0]            ; R2 = contents of Alien_Map[R3]
	ORR   R2, R2, #0x8000
	STRH  R2,[R0]
	POP {R0-R4,PC}
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
	LTORG

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




Remove_Enemy FUNCTION ;Takes enemy to be deleted in R10
	PUSH {LR}
	
	CLZ R10, R10          ; Count leading zeros
	RSB R10, R10, #31     ; r0 = 31 - r0 (position in 32-bit word)
	
	;1 + 4R10 --> R4
	MOV R5, #1
	ADD R5, R10, LSL #2
	
	LSL R8, R5, #4 ;Start x = cellnum * 16 
	ADD R9, R8, #0x10
	MOV R6, #272
	MOV R7, #320
    MOV R11, #Black
    BL TFT_Filldraw4INP
	POP {PC}
	ENDFUNC



 
Move_Player FUNCTION
    PUSH {R4-R7, LR}         ; // Save registers and return address

    ;// R3 holds the current position (1 to 28)
    ;// R7 holds the direction (1 = right, 2 = left)

	MOV R0, R3
	MOV R12,#16
    MUL R0, R0, R12
    MOV R8, #0x0
    MOV R9, #0x30
    SUB R6,R0,#0x10
    ADD R7,R0,#0x20
    MOV R11, #Black               ;Clear position
    B TFT_Filldraw4INP
	
	
    CMP R7, #1                ;// Check if moving right
    BEQ move_right
    CMP R7, #2                ;// Check if moving left
    BEQ move_left
    B end_                     ;// If R7 is neither 1 nor 2, do nothing

move_right
    CMP R3, #1              ;// Check if at the rightmost position
    SUBNE R3, R3, #1            ;// Move right: position += 1
    B redraw

move_left
    CMP R3, #28                ;// Check if at the leftmost position
    ADDNE R3, R3, #1            ;// Move left: position -= 1
    B redraw

redraw
    ;Prepare arguments for draw_player function
    MOV R0, R3
	MOV R12,#16
    MUL R0, R0, R12
    MOV R8, #0x0
    MOV R9, #0x30
    SUB R6,R0,#0x10
    ADD R7,R0,#0x20
    MOV R11, #Blue
    B TFT_Filldraw4INP            ;// Call the existing draw function

end_
    POP {R4-R7, PC}
    ENDFUNC
	
	

;-----------------------------------------
; It only Draws the Score
;-----------------------------------------
Score_Draw
    PUSH {R0-R12, LR}

    LDR   R0, =Score    ; Address of Score
    LDRH  R0, [R0]      ; R0 = value of Score
    MOV   R1, #312      ; X
    MOV   R2, #464      ; Y
    MOV   R3, #1        ; segment thickness
    MOV   R4, #7        ; segment length
    MOV   R5, #3        ; digits to draw
    MOV   R11, #Black   ; desired color

    BL    Num_to_LCD

    POP {R0-R12,PC}
    ENDFUNC
	
;-----------------------------------------
; Will be used anywhere , No Need to Update the Score Screen
; It Incements by [R12] <- Input
;-----------------------------------------
Increment_Score_And_Draw
    PUSH {R0-R11, LR}

    LDR   R0, =Score
    LDRH  R1, [R0]
    ADD   R1, R1, R12
    STRH  R1, [R0]

    BL Score_Draw
    POP {R0-R11, PC}
    ENDFUNC



Heart_Draw
     PUSH {R0-R12, LR}

    LDR   R0, =Hearts
    LDRH  R0, [R0]

    MOV   R1, #297      ; X
    MOV   R2, #464      ; Y
    MOV   R3, #1        ; segment thickness
    MOV   R4, #7        ; segment length
    MOV   R5, #1        ; digits to draw
    MOV   R11, #Black   ; desired color

    BL    Num_to_LCD

    POP {R0-R12, PC}
    ENDFUNC

Decrement_Heart_And_Draw
    PUSH {R0-R12, LR}

    LDR   R0, =Hearts
    LDRH  R1, [R0]
    SUB   R1, R1, R12
    STRH  R1, [R0]

    CMP R0 , #0
    BLT OutOfHearts 

    BL Heart_Draw
    POP {R0-R12, PC}
    ENDFUNC

;----------------------------
; It must calls the lose Screen or Lose Function
;----------------------------
OutOfHearts FUNCTION
    PUSH {R0-R12, LR}

    POP {R0-R12, PC}
    ENDFUNC
	
ENEMY_BULLET_RATE FUNCTION
	PUSH{R0-R1,R4,LR}
	BL Get_Random
	MOV R1, R0;Random Counter
	AND R1, R1,#3; RANDOM%3
	ADD R1, R1,#1;Minimum=1
LOOP	
	CMP R1,#0
	BEQ SkIp
	
	BL Get_Random
	MOV R4, R0
	AND R4, R4,#7;RANDOM%8
	LSL R4, R4,#2
	ADD R4, R4,#2; Position of alien is 4*R0+2 R4=[0,7]
	
	BL ADD_BULLET_ALIEN
	SUB R1, R1,#1
	B LOOP
SkIp
	POP{R0-R12,PC}
	ENDFUNC
	
	
	
check_all_bit15 FUNCTION
    PUSH {R0-R12, LR}          
	MOV R11,R3
    ;// R0: Base address of the 29-word array
    ;// Returns R0: 29-bit value, bit i = 1 if word i's bit 15 is 1, else 
    LDR R1, =Player_Bullets
    MOV R3, #1                ;// R3: Loop counter (0 to 28)

    
loop
    CMP R3, #29                ; // Check if counter >= 29
    BEQ endO                ;  // If yes, exit loop
  
   ; // Load word at R0 + (counter * 4)
    LDR R1, [R1, R3]  ;// R1 = word at index R4

    ;// Check bit 15
    LSR R1, R1, #15           ;// Shift right by 15 to move bit 15 to LSB
    AND R1, R1, #1            ;// Mask to keep only LSB (0 or 1)
    CMP R1, #1                 ;// Check if bit 15 was 1
        
    BEQ GOT                         ; // If bit 15 is 1, set bit 0 in R5
  

    ADD R3, R3, #1          ;  // Increment counter
    B loop                       ; // Continue loop
               
GOT
    ANDS R4,R3, #3    ; check if the colomn number divisable 4 (empty colomn)
    CMP R4,#0            
    BEQ     endO            ; Branch to 'end' if r3 == 0 (mod 4)
    ADD   R3,#3
    LSR R3,R3,#2
    LDR R1, =enemy              ;THE ARRAY OF WO7OSH
    LDR R1,[R1]
   
    SUB R3, R3,#1
    MOV R2, #1
    LSL R2,R2,R3             ;000000100000
    MVN R2, R2               ;111111011111
    AND R1, R2
    LDR R2, =enemy                  ;THE ARRAY OF WO7OSH     
    STR R1, [R2]
    CMP R1,#0
    BEQ WIN


	LDR R1, =Enemy_Bullets     ;CHECK IF THE PLAYER GOT HARMED
	LDR R1, [R1,R11]
	LSR R1, R1, #15          ; // Shift right by 15 to move bit 15 to LSB
	AND R1, R1, #1          ;  // Mask to keep only LSB (0 or 1)
	CMP R1, #1   
	BEQ LOSE  
	ADD R11,#1
	LDR R1, [R1,R11]
	LSR R1, R1, #15          ; // Shift right by 15 to move bit 15 to LSB
	AND R1, R1, #1          ;  // Mask to keep only LSB (0 or 1)
	CMP R1, #1   
	BEQ LOSE   	;// Check if bit 15 was 1
	SUB R11, #2
	LDR R1, [R1,R11]
	LSR R1, R1, #15          ; // Shift right by 15 to move bit 15 to LSB
	AND R1, R1, #1          ;  // Mask to keep only LSB (0 or 1)
	CMP R1, #1   
	BEQ LOSE   
LOSE 
    MOV R0,#2  
    b endO
WIN 
     MOV R0,#3
endO
	POP {R0-R12, PC}
	ENDFUNC
	
	
DrawWa74 FUNCTION;take parameters at r1 and r2
	PUSH{R6-R11,LR}
	MOV R11,#Yellow
	MOV R6, R1   ; X start
	ADD R7,	R1 ,#0X0030
	MOV R8,	R2
	ADD R9, R2 ,#0X0030
	BL TFT_Filldraw4INP
	POP {R6-R11, PC}
	ENDFUNC
	
	
Intialize_Grid FUNCTION
	PUSH {R0-R12,LR}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color (area)
    MOV R11, #Black
	BL TFT_Filldraw4INP
	MOV R6,#0
	MOV R3,#0
MAKE_ZERO
    CMP R3, #30			; Check if all 6 rows processed
    BEQ FINISH_MAKE_ZERO
	
	LDR R0, =Player_Bullets  ; Load address of Level Map into R0
	STRH R6, [R0, R3, LSL #1]
	LDR R0, =Enemy_Bullets
	STRH R6, [R0, R3, LSL #1]
	ADD R3,R3,#1
	B MAKE_ZERO
FINISH_MAKE_ZERO
	MOV R3,#0
	MOV R1,0X0110
	MOV R2,0X0010
START_BM
    CMP R3, #7		; Check if all 6 rows processed
    BEQ FINISH_Build_Monster
	BL DrawWa74
	ADD R3,R3,#1
	ADD R2,0X0040
	B START_BM
	
FINISH_Build_Monster	
	
	
	POP {R0-R12,PC}
	ENDFUNC
	
	
Main_Game_Alien FUNCTION
	PUSH {R0-R12, LR}
	BL Init_RandomSeed
	POP {R0-R12, PC}
	ENDFUNC
	END
		
;ADD_BULLET_PLAYER
;ADD_BULLET_ALIEN
;DrawBullet_Player
;DrawBullet_Enemy
;MOVE_BULLET
;Remove_Enemy
;Move_Player
;OutOfHearts
;ENEMY_BULLET_RATE
;check_all_bit15
;DrawWa74
;Intialize_Grid