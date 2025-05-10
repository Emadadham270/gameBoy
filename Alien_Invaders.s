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
PlayerBulletCounter DCB 0x00; For Youssef Maged
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
	IMPORT GET_state2	
	EXPORT	Intialize_Grid
	EXPORT  Score_Draw
	EXPORT	Heart_Draw
	EXPORT Increment_Score_And_Draw
	EXPORT Decrement_Heart_And_Draw
	EXPORT Main_Game_Alien
	EXPORT DrawBullet_Player
	EXPORT DrawBullet_Enemy
; R3 = Position of player  
ADD_BULLET_PLAYER FUNCTION 
	PUSH {R0-R5,LR}
	LDR   R0, =Player_Bullets      ; R0 = base address of Bullets
	LDR   R4, =PlayerBulletCounter
	LDRH  R5, [R4]
	CMP   R5, #0
	BNE   NoAttack
	MOV   R5, #2
	STRH  R5, [R4]
    MOV   R1, R3             ; R1 = index
    LSL   R1, R1, #1          ; R1 = R1 * 2 (convert to byte offset)
    ADD   R0, R0, R1          ; R0 = address of Alien_Map[R3]
    LDRH  R2,[R0]            ; R2 = contents of Alien_Map[R3]
	ORR   R2, R2, #1
	STRH  R2,[R0]
	B     FFFFFinish
NoAttack
    SUB R5, #1
	STRH R5, [R4]
FFFFFinish
	POP {R0-R5,PC}
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

    MOV R4 , #1             ; Bit 0
DrawBullet_Inner_Loop_P
    MOV R1 , #1              ; Bit mask
    LSL R1 , R1 , R4         ; SHIFT THE 1 BIT IN R1 TO THE INDEX OF THE ARRAY[R5]   
    AND R3 , R2 , R1         ; NOW R3 = ..0000i000.. -> 1 IN i = ARRAY[R5][R4]

    ; If i = 0
    CMP R3 , #0
    BEQ Continue_Ok_P
	
	MOV R10 , R8             ; SAVE THE OLD R8 IN R10
    MOV R12 , R9             ; SAVE THE OLD R9 IN R12
	ADD R8 , R8 , #5         ; R8 OF THE BULLET (CELL START + 4)
    SUB R9 , R9 , #5         ; R9 OF THE BULLET (CELL END - 4)
	
	SUB R6, #0x10
	SUB R7, #0x10
	MOV R11 , #Black         ; Background Color
    BL TFT_Filldraw4INP
	
	ADD R6, #0x10
	ADD R7, #0x10	
    MOV R11 , #Pink          ; Bullet Color
    BL TFT_Filldraw4INP

    MOV R8 , R10             ; RETURN THE OLD R8 SO WE WILL USE IT IN THE LOOP
    MOV R9 , R12             ; RETURN THE OLD R9 SO WE WILL USE IT IN THE LOOP
	
Continue_Ok_P
    ADD  R6 , R6 , #16       ; ADD X_START = X_START + 16
    ADD  R7 , R7 , #16       ; ADD X_END = X_END + 16

    ADD R4 , R4 ,#1          ; ADD R4 = R4 + 1 --> ARRAY[R5][R4] 
    CMP R4 , #16
    BLT DrawBullet_Inner_Loop_P    ;If less than == BLT
	SUB R6, #0x10
	SUB R7, #0x10
	MOV R11 , #Black         ; Background Color
    BL TFT_Filldraw4INP
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
 CMP R5, #29              ; Check if this is the player's row
    BEQ Skip_Row_E            ; Skip drawing bullets in player's row
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

    MOV R4 , #2             ; Bit 0
DrawBullet_Inner_Loop_E
    MOV R1 , #1              ; Bit mask
    LSL R1 , R1 , R4         ; SHIFT THE 1 BIT IN R1 TO THE INDEX OF THE ARRAY[R5]   
    AND R3 , R2 , R1         ; NOW R3 = ..0000i000.. -> 1 IN i = ARRAY[R5][R4]

    ; If i = 0
    CMP R3 , #0
    BEQ Continue_Ok_E
 
 MOV R10 , R8             ; SAVE THE OLD R8 IN R10
    MOV R12 , R9             ; SAVE THE OLD R9 IN R12
 ADD R8 , R8 , #5         ; R8 OF THE BULLET (CELL START + 4)
    SUB R9 , R9 , #5         ; R9 OF THE BULLET (CELL END - 4)
 
 ADD R6, #0x10
 ADD R7, #0x10
 MOV R11 , #Black         ; Background Color
    BL TFT_Filldraw4INP
 
 SUB R6, #0x10
 SUB R7, #0x10 
    MOV R11 , #Orange          ; Bullet Color
    BL TFT_Filldraw4INP

    MOV R8 , R10             ; RETURN THE OLD R8 SO WE WILL USE IT IN THE LOOP
    MOV R9 , R12             ; RETURN THE OLD R9 SO WE WILL USE IT IN THE LOOP
 
Continue_Ok_E
    ADD  R6 , R6 , #16       ; ADD X_START = X_START + 16
    ADD  R7 , R7 , #16       ; ADD X_END = X_END + 16

    ADD R4 , R4 ,#1          ; ADD R4 = R4 + 1 --> ARRAY[R5][R4] 
    CMP R4 , #14
    BLT DrawBullet_Inner_Loop_E    ;If less than == BLT

Skip_Row_E
    ADD R5 , R5 , #1
    CMP R5 , #30 
    BLT DrawBullet_Outer_Loop_E

    POP {R0-R12,PC}
    ENDFUNC


MOVE_BULLET FUNCTION
	PUSH {R0-R12,LR}
	MOV R3, #0 ; index
	MOV R2, #30
	LDR R0, =Player_Bullets       
	LDR R1, =Enemy_Bullets
MovePlayerLoop
    CMP R3, R2
    BEQ CheckCollision1
 
    LDRH R4, [R0, R3, LSL #1]   ; Player column
    LSL R4, R4, #1              ; Shift up
    STRH R4, [R0, R3, LSL #1]

    ADD R3, R3, #1
    B MovePlayerLoop

CheckCollision1
    MOV R3, #0
	LDR R0, =Player_Bullets       
	LDR R1, =Enemy_Bullets
	MOV R8, #0
	MOV R9, #16
CollisionLoop1
    CMP R3, R2
    BEQ MoveOpponent
    LDRH R4, [R0, R3, LSL #1]   ; Player
    LDRH R5, [R1, R3, LSL #1]   ; Opponent
    AND R10, R4, R5              ; Collision mask, if collision occurs then R10 has 1 in the index where collision happened
    BIC R4, R4, R10              ; Clear bits in player, 
    BIC R5, R5, R10              ; Clear bits in opponent
    STRH R4, [R0, R3, LSL #1]
    STRH R5, [R1, R3, LSL #1]
	MOV R4, #16                  ;TEMPP
	MOV R5, #0                  ;Bit index to remove collisions
lO0op
	TST R10, #1
	BEQ Skyp_Drow
	ADD R6, R4, R5, LSL #4
	ADD R7, R6, #32
	MOV R11, #Black
	BL TFT_Filldraw4INP
	SUB R6,#16
	SUB R7,#16
	BL TFT_Filldraw4INP
	ADD R6,#16
	ADD R7,#16
	MOV R12, #5
	BL Increment_Score_And_Draw
Skyp_Drow
	ADD R5, #1
	LSR R10, #1
	CMP R10, #0
	BNE lO0op
	ADD R8,#16
	ADD R9,#16	
    ADD R3, R3, #1
    B CollisionLoop1

MoveOpponent
    MOV R3, #0
	LDR R0, =Player_Bullets       
	LDR R1, =Enemy_Bullets
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
	LDR R0, =Player_Bullets       
	LDR R1, =Enemy_Bullets
	MOV R8, #0
	MOV R9, #16
CollisionLoop2
    CMP R3, R2
    BEQ DoNe
    LDRH R4, [R0, R3, LSL #1]   ; Player
    LDRH R5, [R1, R3, LSL #1]   ; Opponent
    AND R10, R4, R5              ; Collision mask, if collision occurs then R10 has 1 in the index where collision happened
    BIC R4, R4, R10              ; Clear bits in player, 
    BIC R5, R5, R10              ; Clear bits in opponent
    STRH R4, [R0, R3, LSL #1]
    STRH R5, [R1, R3, LSL #1]
	MOV R4, #48                  ;TEMPP
	MOV R5, #0                  ;Bit index to remove collisions
lO0opy
	TST R10, #1
	BEQ Skyp_Drow1
	ADD R6, R4, R5, LSL #4
	ADD R7, R6, #32
	MOV R11, #Black
	BL TFT_Filldraw4INP
	ADD R6,#16
	ADD R7,#16
	BL TFT_Filldraw4INP
	SUB R6,#16
	SUB R7,#16
	MOV R12, #5
	BL Increment_Score_And_Draw
Skyp_Drow1
	ADD R5, #1
	LSR R10, #1
	CMP R10, #0
	BNE lO0opy
	ADD R8,#16
	ADD R9,#16	
    ADD R3, R3, #1
    B CollisionLoop2
DoNe
	POP {R0-R12,PC}
	ENDFUNC
	LTORG


Remove_Enemy FUNCTION ;Takes enemy to be deleted in R10
	PUSH {R5-R11, LR}
	
	CLZ R10, R10          ; Count leading zeros
	RSB R10, R10, #31     ; r0 = 31 - r0 (position in 32-bit word)
	
	;1 + 4R10 --> R4
	MOV R5, #1
	ADD R5, R10, LSL #2
	
	LSL R8, R5, #4 ;Start x = cellnum * 16 
	ADD R9, R8, #0x30
	MOV R6, #272
	MOV R7, #320
    MOV R11, #Black
    BL TFT_Filldraw4INP
	POP {R5-R11, PC}
	ENDFUNC



 
Move_Player FUNCTION
    PUSH {R0, R6-R12, LR}         ; // Save registers and return address

    ;// R3 holds the current position (1 to 28)
    ;// R10 holds the direction (1 = right, 2 = left)

	MOV R0, R3
	
	AND R10,#0x3
	
    CMP R10, #1                ;// Check if moving right
    BEQ move_right
    CMP R10, #2                ;// Check if moving left
    BEQ move_left
    B end_                     ;// If R7 is neither 1 nor 2, do nothing

move_right
    CMP R3, #2              ;// Check if at the rightmost position
    SUBNE R3, R3, #1            ;// Move right: position += 1
    B redraw

move_left
    CMP R3, #26               ;// Check if at the leftmost position
    ADDNE R3, R3, #1            ;// Move left: position -= 1
    B redraw

redraw

	LSL R0, #4             ; R0 *= 16
    MOV R6, #0x0
    MOV R7, #0x30
    SUB R8,R0,#0x10
    ADD R9,R0,#0x20
    MOV R11, #Black               ;Clear position
    BL TFT_Filldraw4INP
    ;Prepare arguments for draw_player function
    MOV R0, R3
	LSL R0, #4             ; R0 *= 16
    MOV R6, #0x0
    MOV R7, #0x30
    SUB R8,R0,#0x10
    ADD R9,R0,#0x20
    MOV R11, #Blue
    BL TFT_Filldraw4INP            ;// Call the existing draw function

end_
    POP {R0, R6-R12, PC}
    ENDFUNC
	
	

;-----------------------------------------
; It only Draws the Score
;-----------------------------------------
Score_Draw FUNCTION
    PUSH {R0-R5, R11, LR}

    LDR   R0, =Score    ; Address of Score
    LDRH  R0, [R0]      ; R0 = value of Score
    MOV   R1, #300      ; X
    MOV   R2, #450      ; Y
    MOV   R3, #1        ; segment thickness
    MOV   R4, #6        ; segment length
    MOV   R5, #3        ; digits to draw
    MOV   R11, #Pink    ; desired color ;;pink 34an barbieeeeee

    BL    Num_to_LCD

    POP {R0-R5, R11,PC}
    ENDFUNC
	
;-----------------------------------------
; Will be used anywhere , No Need to Update the Score Screen
; It Incements by [R12] <- Input
;-----------------------------------------
Increment_Score_And_Draw FUNCTION
    PUSH {R0, R1, R6-R11, LR}
	MOV   R6, #300      ; X
    MOV   R7, #320      ; Y
	MOV   R8, #450      ; X
    MOV   R9, #480      ; Y
	MOV	  R11,#Black
	BL TFT_Filldraw4INP 
    LDR   R0, =Score
    LDRH  R1, [R0]
    ADD   R1, R1,R12
    STRH  R1, [R0]

    BL Score_Draw
    POP {R0, R1, R6-R11, PC}
    ENDFUNC



Heart_Draw FUNCTION
    PUSH {R0-R5, R11, LR}

    LDR   R0, =Hearts
    LDRH  R0, [R0]
    MOV   R1, #280      ; X
    MOV   R2, #450      ; Y
    MOV   R3, #1        ; segment thickness
    MOV   R4, #7        ; segment length
    MOV   R5, #1        ; digits to draw
    MOV   R11, #Orange  ; desired color

    BL    Num_to_LCD
    POP {R0-R5, R11, PC}
    ENDFUNC

Decrement_Heart_And_Draw FUNCTION
    PUSH {R0, R1, R6-R11, LR}
	MOV   R6, #280      ; X
    MOV   R7, #299      ; Y
	MOV   R8, #450      ; X
    MOV   R9, #480      ; Y
	MOV	  R11,#Black
	BL TFT_Filldraw4INP 
    LDR   R0, =Hearts
    LDRH  R1, [R0]
    SUB   R1, R1, #1
    STRH  R1, [R0]

    CMP R0 , #0
    BGT cOntinUe
	MOV R12, #0xAA
cOntinUe
    BL Heart_Draw
    POP {R0, R1, R6-R11, PC}
    ENDFUNC
	
ENEMY_BULLET_RATE FUNCTION
	PUSH{R0-R4,LR}
	LDR R5, =PlayerBulletCounter
	LDRB R5, [R5]
	CMP R5, #1
	BNE SkIp
	
	BL Get_Random
	MOV R4, R0
	AND R4, R4,#7;RANDOM%8
	MOV R3, #1          ; Create bit mask with 1 #00001
	LSL R3, R3, R4      ; Shift to position R4  #01000
	LDR R2,=enemy
	LDRB R2, [R2]
	TST R2, R3          ; Test if bit is set
	BEQ SkIp
	LSL R4, R4,#2
	ADD R4, R4,#2; Position of alien is 4*R0+2 R4=[0,7]
	BL ADD_BULLET_ALIEN
SkIp
	POP{R0-R4,PC}
	ENDFUNC
	
	
	
check_all_bit15 FUNCTION
    PUSH {R0-R11, LR}          
	MOV R11,R3
    ;// Returns R0: 29-bit value, bit i = 1 if word i's bit 15 is 1, else 
    LDR R0, =Player_Bullets
    MOV R3, #1                ;// R3: Loop counter (0 to 28)

    
loop
    CMP R3, #30             ; // Check if counter >= 29
    BEQ endO                ;  // If yes, exit loop
  
   ; // Load word at R0 + (counter * 4)
    LDRH R1, [R0, R3, LSL #1]  ;// R1 = word at index R4

    ;// Check bit 15
    LSR R1, R1, #15           ;// Shift right by 15 to move bit 15 to LSB
    AND R1, R1, #1            ;// Mask to keep only LSB (0 or 1)
    CMP R1, #1                 ;// Check if bit 15 was 1
        
    BEQ GOT                         ; // If bit 15 is 1, set bit 0 in R5
  

    ADD R3, R3, #1          ;  // Increment counter
    B loop                       ; // Continue loop
               
GOT
    ANDS R4, R3, #3    ; check if the colomn number divisable 4 (empty colomn)
    CMP R4,#0            
    BEQ endO            ; Branch to 'end' if r3 == 0 (mod 4)
    ADD R3,#3
    LSR R3,R3,#2
    LDR R1, =enemy              ;THE ARRAY OF WO7OSH
    LDRB R1,[R1]
   
    SUB R3, R3,#1
    MOV R2, #1
    LSL R2,R2,R3             ;000000100000
	MOV R10, R2              ;FOR Remove_Enemy
    ;MVN R2, R2               ;111111011111
    EOR R1, R2
    LDR R2, =enemy                  ;THE ARRAY OF WO7OSH     
    STRB R1, [R2]
	BL Remove_Enemy
    CMP R1,#0
    BEQ WIN


	LDR R0, =Enemy_Bullets     ;CHECK IF THE PLAYER GOT HARMED
	LDRH R1, [R0,R11,LSL #1]
	LSR R1, R1, #15          ; // Shift right by 15 to move bit 15 to LSB
	AND R1, R1, #1           ;  // Mask to keep only LSB (0 or 1)
	CMP R1, #1   
	BEQ LOSE  
	ADD R11,#1
	LDR R1, [R0,R11,LSL #1]
	LSR R1, R1, #15          ; // Shift right by 15 to move bit 15 to LSB
	AND R1, R1, #1           ;  // Mask to keep only LSB (0 or 1)
	CMP R1, #1   
	BEQ LOSE   	             ;// Check if bit 15 was 1
	SUB R11, #2
	LDR R1, [R0,R11,LSL #1]
	LSR R1, R1, #15          ; // Shift right by 15 to move bit 15 to LSB
	AND R1, R1, #1           ;  // Mask to keep only LSB (0 or 1)
	CMP R1, #1   
	BEQ LOSE
	B endO
LOSE 
    BL Decrement_Heart_And_Draw 
    B endO
WIN
    MOV R12,#0xFF            ; FOR WIN                  
endO
	POP {R0-R11, PC}
	ENDFUNC
	
	
DrawWa74 FUNCTION;take parameters at r1 and r2
	PUSH{R6-R11,LR}
	MOV R11,#Yellow
	MOV R6, R1   ; X start
	ADD R7,	R1 ,#0X0030
	MOV R8,	R2
	ADD R9, R2 ,#0X0030
	BL TFT_Filldraw4INP
	MOV R11,#Black
	ADD R6, R1 ,#0X0020  ; X start
	ADD R7,	R1 ,#0X0028
	ADD R8,	R2 ,#0X000C
	ADD R9, R2 ,#0X0014
	BL TFT_Filldraw4INP
	ADD R6, R1 ,#0X0020  ; X start
	ADD R7,	R1 ,#0X0028
	ADD R8,	R2 ,#0X001C
	ADD R9, R2 ,#0X0024
	BL TFT_Filldraw4INP
	ADD R6, R1 ,#0X0010  ; X start
	ADD R7,	R1 ,#0X0018
	ADD R8,	R2 ,#0X000C
	ADD R9, R2 ,#0X0024
	BL TFT_Filldraw4INP
	POP {R6-R11, PC}
	ENDFUNC
DRAW3ARABYA
	PUSH{R6-R11,LR}
	MOV R11,#Blue
	MOV R6, R1   ; X start
	ADD R7,	R1 ,#0X0030
	MOV R8,	R2
	ADD R9, R2 ,#0X0030
	BL TFT_Filldraw4INP
	MOV R11,#Black
	ADD R6, R1 ,#0X0020  ; X start
	ADD R7,	R1 ,#0X0028
	ADD R8,	R2 ,#0X000C
	ADD R9, R2 ,#0X0014
	BL TFT_Filldraw4INP
	ADD R6, R1 ,#0X0020  ; X start
	ADD R7,	R1 ,#0X0028
	ADD R8,	R2 ,#0X001C
	ADD R9, R2 ,#0X0024
	BL TFT_Filldraw4INP
	ADD R6, R1 ,#0X0010  ; X start
	ADD R7,	R1 ,#0X0018
	ADD R8,	R2 ,#0X000C
	ADD R9, R2 ,#0X0024
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
	MOV R6,#3
	LDR R0, =Hearts  ; Load address of Level Map into R0
	STRH R6, [R0]
	MOV R6,#0
	LDR R0, =Score  ; Load address of Level Map into R0
	STRH R6, [R0]
	LDR R0, =PlayerBulletCounter  ; Load address of Level Map into R0
	STRH R6, [R0]
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
	MOV R1,#0x0110
	MOV R2,#0x0010
START_BM
    CMP R3, #7		; Check if all 6 rows processed
    BEQ FINISH_Build_Monster
	BL DrawWa74
	ADD R3,R3,#1
	ADD R2,#0X0040
	B START_BM
FINISH_Build_Monster
	MOV R1,#0X0000
	MOV R2,#0X00D0
	BL DRAW3ARABYA
	MOV R3,#14
	POP {R0-R12,PC}
	ENDFUNC
	
	
Main_Game_Alien FUNCTION
	PUSH {R0-R12, LR}
	BL Intialize_Grid
	MOV R3,#14
GAMEL00P
	BL ENEMY_BULLET_RATE
	BL DrawBullet_Enemy
	BL DrawBullet_Player
	BL ADD_BULLET_PLAYER
	BL GET_state2
	AND R10,#0X003F
	CMP R10,#32
	
	BEQ EXIT_ALIEN
	BL Move_Player
	BL MOVE_BULLET
	BL check_all_bit15
	;MOV R10,#1
	;BL Remove_Enemy
	B GAMEL00P

	BL MOVE_BULLET	
	;BL ADD_BULLET_PLAYER
	BL MOVE_BULLET
	BL DrawBullet_Player
	
	;BL ADD_BULLET_PLAYER
	BL ADD_BULLET_PLAYER
	BL MOVE_BULLET
	BL DrawBullet_Player


	BL DrawBullet_Enemy


	MOV R0, #4
	BL delay


	CMP R12, #0xFF
	BEQ WiNNer
	CMP R12, #0xAA
	BEQ L0OsEr
	B GAMEL00P
WiNNer
L0OsEr
EXIT_ALIEN
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
;OutOfHearts    ///STILL EMPTY
;ENEMY_BULLET_RATE
;check_all_bit15
;DrawWa74
;Intialize_Grid