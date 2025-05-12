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
Gray    	   EQU 0x8410

colorBreaklvl
		DCD    0x11144001
		DCD    0x11144002
		DCD    0x00000001
		DCD    0x08880000
		DCD    0x08880000
		DCD    0x00000001
		DCD    0x11144003
		DCD    0x11144001
colorBreaklvl2
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x01111110
		DCD    0x04444440
		DCD    0x01151110
		DCD    0x00000000
		DCD    0x00000000

	AREA ColorBreakMAP, DATA, READWRITE
colorBreakMap
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000
		DCD    0x00000000	
	
		
PlayerColor DCB 0x00 



			
	AREA    ColorBreakeCode, CODE, READONLY
    IMPORT  TFT_WriteCommand
    IMPORT  TFT_WriteData
    IMPORT  TFT_DrawImage
	IMPORT  TFT_Filldraw4INP
    IMPORT  delay
	IMPORT  GET_state2			
	IMPORT TFT_DRAWSQUARE
	IMPORT DrawOutline
	EXPORT Draw_Map_Break
	EXPORT Draw_Filled_Circle30
	EXPORT UP_D0WN_MOVEMENT	
	EXPORT main_Color_Break
	EXPORT DRAW_BALL_MOVEMENT 
	EXPORT Destroy_Block
	IMPORT  Draw_X
	IMPORT  Draw_O

TFT_DRAWSQUARE2 FUNCTION
	PUSH{R1-R4,R6-R9,LR}
	MOV R6,R1
	ADD R7,R6,#40
	MOV R8,R2
	ADD R9,R8,#40
	BL TFT_Filldraw4INP
	MOV R11,#Black
	ADD R1,#2
	ADD R2,#2
	MOV R4 , #36
	MOV R3 , #2
	BL DrawOutline
	POP{R1-R4,R6-R9, PC}
	ENDFUNC

Draw_Map_Break FUNCTION
    PUSH {R0-R12, LR}

    ; Define screen boundaries for drawing
    MOV R6, #0x0000       ; Start X position (0)
    MOV R7, #0x0140       ; End X position (320 pixels)
    MOV R8, #0       ; Start Y position (40 pixels) 
    MOV R9, #80       ; End Y position (480 pixels)

    ; Fill screen with background color
    MOV R11, #Black   ; Set background color
    BL TFT_Filldraw4INP   ; Fill screen with background color
	; Define screen boundaries for drawing
    MOV R6, #0x0000       ; Start X position (0)
    MOV R7, #0x0140       ; End X position (320 pixels)
    MOV R8, #400      ; Start Y position (40 pixels) 
    MOV R9, #480       ; End Y position (480 pixels)

    ; Fill screen with background color
    MOV R11, #Black   ; Set background color
    BL TFT_Filldraw4INP   ; Fill screen with background color
    ; Define screen boundaries for drawing
    MOV R6, #0x0000       ; Start X position (0)
    MOV R7, #0x0140       ; End X position (320 pixels)
    MOV R8, #80       ; Start Y position (40 pixels) 
    MOV R9, #400       ; End Y position (480 pixels)

    ; Fill screen with background color
    MOV R11, #LightPink   ; Set background color
    BL TFT_Filldraw4INP   ; Fill screen with background color

    ; Initialize drawing position and counter
    MOV R1, #0            ; Initial X position for drawing
    MOV R2, #80           ; Initial Y position for drawing
    MOV R12, #0            ; Initialize column counter

col_LOOP
    CMP R12, #8            ; Check if all 8 columns processed
    BEQ FINISH_MAP        ; If done, exit function

    LDR R0, =colorBreakMap     ; Load address of map data
    LDR R9, [R0, R12,LSL #2]           ; Load the 32-bit word for current column

    MOV R4, #0            ; Initialize bit position counter

row_LOOP
    CMP R4, #32           ; Check if we processed all 32 bits
    BEQ Next_col_MAP      ; If done with this column, move to next

    ; Extract the block type (4 bits) at current position
    MOV R5, R9            ; Copy column data to R5
    LSR R5, R5, R4        ; Shift right to align relevant bits
    AND R5, R5, #0xF      ; Mask to get only the 4-bit block type

    ; Determine color based on block type
    CMP R5, #0x0          ; Check if Void (0)
    BEQ SkipDraw          ; If Void, skip drawing

    CMP R5, #0x1          ; Check if Wall (1)
    MOVEQ R11, #Gray      ; Set color to Gray for Wall
    
    CMP R5, #0x2          ; Check if Change color 0 (2)
    BEQ ChangeColorBlue      ; Set color to Blue for Change color 0
    
    CMP R5, #0x3          ; Check if Change color 1 (3)
    BEQ ChangeColorYellow    ; Set color to Yellow for Change color 1
    
    CMP R5, #0x4          ; Check if Color 0 (4)
    MOVEQ R11, #Blue      ; Set color to Blue for Color 0
	
	CMP R5, #0x5          ; Check if Kill (3)
    BEQ KILLlmao       ; Set color to Red for kill
    
    CMP R5, #0x8          ; Check if Color 1 (8)
    MOVEQ R11, #Yellow    ; Set color to Yellow for Color 1

    ; Draw square at current position
    BL TFT_DRAWSQUARE2     ; Draw a square with selected color
	B SkipDraw
	
ChangeColorBlue
	MOV R11, #Blue
    BL TFT_DRAWSQUARE2     ; Draw a square with selected color
	MOV R3, #40
	MOV R11, #Lavender
	BL Draw_O
	B SkipDraw
ChangeColorYellow
	MOV R11, #Yellow
    BL TFT_DRAWSQUARE2     ; Draw a square with selected color
	MOV R3, #40
	MOV R11, #Lavender
	BL Draw_O
	B SkipDraw
KILLlmao
	MOV R11, #Black
    BL TFT_DRAWSQUARE2     ; Draw a square with selected color
	MOV R3, #40
	MOV R11, #Red
	BL Draw_X
	
	
SkipDraw
    ADD R2, #40           ; Move X position right for next block
    ADD R4, #4            ; Increment bit position by 4 (next block)
    B row_LOOP            ; Continue processing this column

Next_col_MAP
    ADD R1, #40           ; Move Y position down for next column
    MOV R2, #80            ; Reset X position to start of row
    ADD R12, #1            ; Increment column counter
    B col_LOOP            ; Process next column

FINISH_MAP
    POP {R0-R12, PC}      ; Restore registers and return
	ENDFUNC
	
	

UP_D0WN_MOVEMENT FUNCTION
    PUSH{R0-R2, R4-R12, LR}

    LDR  R2 , =PlayerColor
    LDRB R0 , [R2]
    TST  R0 , #2
    BNE.W UP_MOVEMENT

DOWN_MOVEMENT
    SUB R3 , R3 , #8
    LDR R4, =colorBreakMap
    LSR R5, R3, #3  ;R5 = ROW
    LDR R4, [R4, R5, LSL #2] ;LOAD ROW IN R4
    AND R6, R3, #7 ;R6 = COLUMN
    MOV R7, #0xF  ;BIT MASK FOR COLUMN NUMBER 0000000F
    LSL R6,#2
    LSL R7, R6 ;BIT MASK TILL COLUMN
    AND R7 , R7 , R4
    LSR R7, R6

    CMP R7 , #0x0
    BEQ NORMALD

    CMP R7 , #0x1
    BEQ UP_MOVE
    
    CMP R7 , #0x2         ;Change color zero
    BEQ Change_Up_ZERO
    
    CMP R7 , #0x3         ;Change color one
    BEQ Change_Up_ONE

    CMP R7, #0x4          ; Check if Color 0 (4)
    BEQ Check_Block_BLUE_UP
    
	CMP R7,#0x5			  ; Check if kill block
	BEQ KILL
	
    CMP R7, #0x8          ; Check if Color 1 (8)
    BEQ Check_Block_YELLOW_UP
	
       
    MOV R1 , R3 
    LSR R1 , #3
    CMP R1 , #0
    ORREQ R0, #2

NORMALD
    ADD R3,R3,#8
    MOV R11, #LightPink
    BL Draw_Filled_Circle30
    SUB R3,R3,#8
    LDR R0,=PlayerColor
    LDRB R0,[R0]
    TST R0,#1
    BEQ color0
    MOV R11 , #Yellow
    BL Draw_Filled_Circle30
    MOV R1 , R3 
    LSR R1 , #3
    CMP R1 , #0
    ORREQ R0, #2
    B ENDDD

color0
    MOV R11, #Blue  
    BL Draw_Filled_Circle30
    MOV R1 , R3 
    LSR R1 , #3
    CMP R1 , #0
    ORREQ R0, #2
    B ENDDD

UP_MOVE
    ADD R3, R3, #8
    LDR  R2 , =PlayerColor
    LDRB R0 , [R2]
    ORR  R0 , #2
    MOV R1 , R3 
    LSR R1 , #3
    CMP R1 , #0
    ORREQ R0, #2
    B ENDDD

Change_Up_ZERO
    ADD R3, R3, #8
    LDR R0,=PlayerColor
    LDRB R0,[R0]
    TST R0,#1
    BEQ CHANGE1 ; same COLOR, DON'T CHANGE
    BL Change_color ; change color in array
	MOV R11, #Blue ; player color 1
	BL Draw_Filled_Circle30
CHANGE1 
    B UP_MOVE

Change_Up_ONE
	ADD R3, R3, #8
    LDR R0,=PlayerColor
    LDRB R0,[R0]
    TST R0,#1
    BNE CHANGE2 ; same COLOR, DON'T CHANGE
    BL Change_color ; change player color in array
	MOV R11, #Yellow ; player color 2
	BL Draw_Filled_Circle30
CHANGE2    
    B UP_MOVE

Check_Block_BLUE_UP
    LDR R0,=PlayerColor
    LDRB R0,[R0]

    TST R0,#1
    BNE ADD17 ; OPPOSITE COLOR, DON'T DESTROY
    
    
    BL Destroy_Block
ADD17
    B UP_MOVE

Check_Block_YELLOW_UP
    LDR R0,=PlayerColor
    LDRB R0,[R0]

    TST R0,#1
    BEQ ADD27; IF OPPOSITE COLOR, DON'T DESTROY

    BL Destroy_Block
ADD27
    B UP_MOVE
	
	
	
KILL
	LDR R0,=PlayerColor
    LDRB R1,[R0]
	ORR R1,#4
	STRB R1,[R0]
	B END2
	
	
	
UP_MOVEMENT
    ADD R3 , R3 , #8
    LDR R4, =colorBreakMap
    LSR R5, R3, #3  ;R5 = ROW
    LDR R4, [R4, R5, LSL #2] ;LOAD ROW IN R4
    AND R6, R3, #7 ;R6 = COLUMN
    MOV R7, #0xF  ;BIT MASK FOR COLUMN NUMBER 0000000F
	LSL R6 , R6 ,#2
    LSL R7, R6 ;BIT MASK TILL COLUMN
    AND R7 , R7 , R4
    LSR R7, R6 ;BIT MASK TILL COLUMN
    
    CMP R7 , #0x0
    BEQ NORMALU

    CMP R7 , #0x1
    BEQ DOWN_MOVE
    
    CMP R7 , #0x2
    BEQ Change_Down_ZERO
    
    CMP R7 , #0x3
    BEQ Change_Down_ONE

    CMP R7, #0x4          ; Check if Color 0 (4)
    BEQ Check_Block_BLUE_DOWN  ; Set color to Blue for Color 0
    
	
	CMP R7,#0x5			  ; Check if kill block
	BEQ KILL1
	
    CMP R7, #0x8           ; Check if Color 1 (8)
    BEQ Check_Block_YELLOW_DOWN ; Set color to Yellow for Color 1

    MOV R1 , R3 
    LSR R1 , #3
    CMP R1 , #7
    BICEQ R0, #2
    B ENDDD

NORMALU
    SUB R3, R3, #8
	MOV R11, #LightPink ; background
	BL Draw_Filled_Circle30 ; draw background over the old position
	ADD R3, R3, #8
	
	LDR R0,=PlayerColor
	BL FFF
	LTORG
FFF
    LDRB R0,[R0]
	TST R0, #1
	BEQ COLOR02
	MOV R11, #Yellow
	BL Draw_Filled_Circle30 ;draw player with new color
	MOV R1 , R3 
    LSR R1 , #3
    CMP R1 , #7
    BICEQ R0, #2
    B ENDDD
COLOR02
	MOV R11, #Blue
	BL Draw_Filled_Circle30 ;draw player with new color
    MOV R1 , R3 
    LSR R1 , #3
    CMP R1 , #7
    BICEQ R0, #2
    B ENDDD


DOWN_MOVE
    SUB R3, R3, #8
    LDR  R2 , =PlayerColor 
    LDRB R0 , [R2]
    BIC  R0 , #2
    MOV R1 , R3 
    LSR R1 , #3
    CMP R1 , #7
    BICEQ R0, #2
    B ENDDD


Change_Down_ZERO
	SUB R3, R3, #8
    LDR R0,=PlayerColor
    LDRB R0,[R0]
    
    TST R0,#1
    BEQ SUB111 ; same COLOR, DON'T CHANGE
    BL Change_color ; change color in array
	MOV R11, #Blue ; player color 1
	BL Draw_Filled_Circle30
SUB111
 
    B DOWN_MOVE


Change_Down_ONE
    SUB R3, R3, #8
    LDR R0,=PlayerColor
    LDRB R0,[R0]
    
    TST R0,#1
    BNE SUB121 ; same COLOR, DON'T CHANGE
    BL Change_color ; change color in array
	MOV R11, #Yellow ; player color 2
	BL Draw_Filled_Circle30 
SUB121
    B DOWN_MOVE

Check_Block_BLUE_DOWN
    LDR R0,=PlayerColor
    LDRB R0,[R0]

    TST R0,#1
    BNE SUB17 ; IF OPPOSITE COLOR, DON'T DESTROY
    BL Destroy_Block
SUB17
    B DOWN_MOVE



KILL1
	LDR R0,=PlayerColor
    LDRB R1,[R0]
	ORR R1,#4
	STRB R1,[R0]
	B END2
	
	
Check_Block_YELLOW_DOWN  
    LDR R0,=PlayerColor
    LDRB R0,[R0]

    TST R0,#1
    BEQ SUB27 ; IF OPPOSITE COLOR, DON'T DESTROY
    BL Destroy_Block
SUB27
    B DOWN_MOVE

ENDDD
    STR R0 , [R2] 
END2	
    POP{R0-R2, R4-R12, PC}
    ENDFUNC

	
	
Change_color FUNCTION
  PUSH{R0-R1,LR}
;check for block with code 0010
    LDR R0,=PlayerColor 
    LDRB R1,[R0]
    TST R1, #1;COLOR 1
    BNE change_to_0

change_to_1
    ORR R1,#1
    STRB R1,[R0]
    B end

change_to_0
    BIC R1,#1
    STRB R1,[R0]
    B end

end    
   POP{R0-R1,PC}	
	ENDFUNC
	
	

; Cell Number of block in R3
Destroy_Block FUNCTION; Take position of block
    PUSH{R0-R1,R4-R9,LR}
   
    MOV R0,#40
    MOV R4, R3;Store position

    AND R1, R4,#7
    MUL R8, R1, R0
    ADD R8, R8,#80;Y-VALUE = 80+40*(cell no.%8)
    ADD R9, R8,#40

    MOV R1, R4, LSR #3
    MUL R6, R1, R0;X-VALUE = 40*(cell no./8)
    ADD R7, R6,#40

    MOV R11, #LightPink
	BL TFT_Filldraw4INP
	
	
    LDR R5, =colorBreakMap
    LSR R11, R3, #3  ;R11 = ROW
    LDR R5, [R5, R11, LSL #2] ;LOAD ROW IN R5
    AND R10, R3, #7 ;R10= COLUMN
    MOV R12, #0xF  ;BIT MASK FOR COLUMN NUMBER 0000000F
    LSL R10, R10, #2     ; First shift R10 left by 2 bits
	LSL R12, R12, R10         ; Then shift R12 left by the value in R10
    BIC R5 , R5 , R12
    LDR R12,=colorBreakMap
    STR R5, [R12,R11, LSL #2]

    
    POP{R0-R1,R4-R9,PC}
	ENDFUNC
	
	
	
Check_Win FUNCTION
        PUSH    {R0,R2-R12, LR}
		
		LDR     R4, =PlayerColor
		LDRB    R4, [R4]
		TST     R4, #0x4
		BNE     no_win
        LDR     R4, =colorBreakMap
        MOV     R5, #8

Row_Loop
        LDR     R0, [R4], #4
        MOV     R6, #8

Nibble_Loop
        AND     R1, R0, #0xF
        CMP     R1, #4
        BEQ     End_lol
        CMP     R1, #8
        BEQ     End_lol

        LSR     R0, R0, #4             ; Shift to next nibble
        SUBS    R6, R6, #1
        BNE     Nibble_Loop

        SUBS    R5, R5, #1             ; Decrement row counter
        BNE     Row_Loop

		MOV		R1, #0x00FF             ; Return 00FF for win
        B       End_lol
no_win
		MOV R1,#0X00AA
End_lol
	
        POP     {R0,R2-R12, PC}
		ENDFUNC
		LTORG
		
DRAW_BALL_MOVEMENT  FUNCTION
    PUSH {R0-R2, R4-R12,LR}
    ;// R3 holds the current position 
    ;// R10 holds the direction (1 = left, 2 = right)
    ; we get from out the R3,R10
   ;MOV R0, R3
   AND R6, R3, #7 ;R6 = COLUMN
   AND R10,#0x3
   CMP R10,#1
   BEQ move_left
   CMP R10,#2
   BEQ move_right
   B end_

move_right
    CMP R6, #0              ;// Check if at the rightmost position
    BEQ.W end_
    SUB R3, R3, #1
    LDR R4, =colorBreakMap
    LSR R5, R3, #3  ;R5 = ROW
    LDR R4, [R4, R5, LSL #2] ;LOAD ROW IN R4
    AND R6, R3, #7 ;R6 = COLUMN
    MOV R7, #0xF  ;BIT MASK FOR COLUMN NUMBER 0000000F
	LSL R6, R6,#2
    LSL R7,R7, R6  ;BIT MASK TILL COLUMN	
    AND R7 , R7 , R4 
    LSR R7,R7, R6 

    CMP R7, #0
    BEQ VOID

    CMP R7, #1
    BEQ WALL

    CMP R7, #2
    BEQ CHANGECOLOR1

    CMP R7, #3
    BEQ CHANGECOLOR2

    CMP R7, #4
    BEQ COLOR0
	
	CMP R7,#0x5			  ; Check if kill block
	BEQ KILL2

    CMP R7, #8
    BEQ COLOR1

VOID 
	ADD R3, R3, #1
	MOV R11, #LightPink ; background
	BL Draw_Filled_Circle30 ; draw background over the old position
	SUB R3, R3, #1
	
	LDR R0,=PlayerColor
    LDRB R0,[R0]
	TST R0, #1
	BEQ colOR0
	MOV R11, #Yellow
	BL Draw_Filled_Circle30 ;draw player with new color
	B end_
colOR0
	MOV R11, #Blue
	BL Draw_Filled_Circle30 ;draw player with new color
    B end_
WALL
    ADD R3, R3, #1
    B end_

CHANGECOLOR1

	ADD R3, R3, #1
    LDR R0,=PlayerColor
    LDRB R0,[R0]
    
    TST R0,#1
    BEQ ADD11 ; same COLOR, DON'T CHANGE
    BL Change_color ; change color in array
	MOV R11, #Blue ; player color 1
	BL Draw_Filled_Circle30
	
	


ADD11
    B end_

CHANGECOLOR2

	ADD R3, R3, #1
    LDR R0,=PlayerColor
    LDRB R0,[R0]


    TST R0,#1
    BNE ADD12 ; same COLOR, DON'T CHANGE
    BL Change_color ; change player color in array
	MOV R11, #Yellow ; player color 2
	BL Draw_Filled_Circle30

ADD12  
    B end_


COLOR0
    
    LDR R0,=PlayerColor
    LDRB R0,[R0]

    TST R0,#1
    BNE ADD1 ; OPPOSITE COLOR, DON'T DESTROY
    
    
    BL Destroy_Block

ADD1
    ADD R3, R3, #1 ; RESTORE CELL NUM TO ITS ORIGINAL VALUE
    B end_

  

COLOR1
    
    LDR R0,=PlayerColor
    LDRB R0,[R0]

    TST R0,#1
    BEQ ADD2; IF OPPOSITE COLOR, DON'T DESTROY

    BL Destroy_Block

ADD2
    ADD R3, R3, #1
    B end_

KILL2
	LDR R0,=PlayerColor
    LDRB R1,[R0]
	ORR R1,#4
	STRB R1,[R0]
	B end_
    
move_left
    CMP R6, #7                ;// Check if at the leftmost position
    BEQ end_
    ADD R3, R3, #1
    LDR R4, =colorBreakMap
    LSR R5, R3, #3  ;R5 = ROW
    LDR R4, [R4, R5, LSL #2] ;LOAD ROW IN R4
    AND R6, R3, #7 ;R6 = COLUMN
    MOV R7, #0xF  ;BIT MASK FOR COLUMN NUMBER 0000000F
    LSL R6, R6,#2
    LSL R7,R7, R6  ;BIT MASK TILL COLUMN	
    AND R7 , R7 , R4 
    LSR R7,R7, R6 

    CMP R7, #0
    BEQ VOIDL

    CMP R7, #1
    BEQ WALLL

    CMP R7, #2
    BEQ CHANGECOLOR1L

    CMP R7, #3
    BEQ CHANGECOLOR2L

    CMP R7, #4
    BEQ COLOR0L

	CMP R7,#0x5			  ; Check if kill block
	BEQ KILL3


    CMP R7, #8
    BEQ COLOR1L

VOIDL
	
	SUB R3, R3, #1
	MOV R11, #LightPink ; background
	BL Draw_Filled_Circle30 ; draw background over the old position
	ADD R3, R3, #1
	
	LDR R0,=PlayerColor
    LDRB R0,[R0]
	TST R0, #1
	BEQ cOlOR0
	MOV R11, #Yellow
	BL Draw_Filled_Circle30 ;draw player with new color
	B end_
cOlOR0
	MOV R11, #Blue
	BL Draw_Filled_Circle30 ;draw player with new color
    B end_
	
WALLL
    SUB R3, R3, #1
    B end_

CHANGECOLOR1L

	SUB R3, R3, #1
    LDR R0,=PlayerColor
    LDRB R0,[R0]
    
    TST R0,#1
    BEQ SUB11 ; same COLOR, DON'T CHANGE
    BL Change_color ; change color in array
	MOV R11, #Blue ; player color 1
	BL Draw_Filled_Circle30




SUB11
 
    B end_

CHANGECOLOR2L

	SUB R3, R3, #1
    LDR R0,=PlayerColor
    LDRB R0,[R0]
    
    TST R0,#1
    BNE SUB12 ; same COLOR, DON'T CHANGE
    BL Change_color ; change color in array
	MOV R11, #Yellow ; player color 2
	BL Draw_Filled_Circle30 
SUB12
    B end_

KILL3
	LDR R0,=PlayerColor
    LDRB R1,[R0]
	ORR R1,#4
	STRB R1,[R0]
	B end_
	
COLOR0L
    
    LDR R0,=PlayerColor
    LDRB R0,[R0]

    TST R0,#1
    BNE SUB1 ; IF OPPOSITE COLOR, DON'T DESTROY
    
    
    BL Destroy_Block

SUB1
    SUB R3, R3, #1
    B end_

  

COLOR1L  
    LDR R0,=PlayerColor
    LDRB R0,[R0]

    TST R0,#1
    BEQ SUB2 ; IF OPPOSITE COLOR, DON'T DESTROY
    BL Destroy_Block
SUB2
    SUB R3, R3, #1
    B end_
end_
    
    POP{R0-R2, R4-R12,PC}
    ENDFUNC
	
	
	

		
		
		
Draw_Filled_Circle30 FUNCTION
	PUSH {R0-R12, LR}

	MOV R0,#40

    AND R2, R3,#7
    MUL R2, R2, R0
    ADD R2, R2, #90;Y-VALUE = 80+40*(cell no.%8)
 
    MOV R1, R3, LSR #3
    MUL R1, R1, R0;X-VALUE = 40*(cell no./8)
	ADD R1, #10

;----- constants --------------------------------------------------------------
	MOV R0, #10 ; R (always 15 ? diameter 30)

;----- centre point -----------------------------------------------------------
	ADD R3, R1, R0 ; R3 = Cx = X0 + 15
	ADD R4, R2, R0 ; R4 = Cy = Y0 + 15

	;----- Bresenham initial values -----------------------------------------------
	MOVS R1, #0 ; x = 0
	MOV R2, R0 ; y = R
	MOVS R7, #1
	SUB R7, R7, R0 ; d = 1 – R


	BL      PlotSpans         ; first set of spans
BresLoop
	CMP R1, R2 ; while (x = y)
	BGT BresDone


	CMP     R7, #0
	BLE     addX_ONLY         ; if d = 0 : keep y
; else d > 0 : y--
	SUBS R2, R2, #1 ; y = y – 1
	SUB R7, R7, R2, LSL #1; d = d – 2*y

addX_ONLY
	ADD R7, R7, R1, LSL #1; d = d + 2*x
	ADDS R7, #1 ; d = d + 1
	BL PlotSpans ; draw 4 horizontal spans
	ADDS R1, #1 ; x = x + 1
	B BresLoop

BresDone
	POP {R0-R12, PC}
	ENDFUNC

PlotSpans
	PUSH {R0-R12, LR}

;----- Span #1 ( y = +y ) ----------------------------------------------------
	SUB R6, R3, R1 ; startX = Cx – x
	ADD R7, R3, R1 ; endX = Cx + x
	ADD R8, R4, R2 ; Y = Cy + y
	MOV R9, R8 ; endY = startY (height = 1)
	BL TFT_Filldraw4INP

;----- Span #2 ( y = –y ) ----------------------------------------------------
	SUB R6, R3, R1
	ADD R7, R3, R1
	SUB R8, R4, R2
	MOV R9, R8
	BL TFT_Filldraw4INP

;----- If x == y we are on the 45° line – the other two spans collapse -----
	CMP R1, R2
	BEQ PlotDone

;----- Span #3 ( y = +x ) ----------------------------------------------------
	SUB R6, R3, R2 ; startX = Cx – y
	ADD R7, R3, R2 ; endX = Cx + y
	ADD R8, R4, R1 ; Y = Cy + x
	MOV R9, R8
	BL TFT_Filldraw4INP

;----- Span #4 ( y = –x ) ----------------------------------------------------
	SUB R6, R3, R2
	ADD R7, R3, R2
	SUB R8, R4, R1
	MOV R9, R8
	BL TFT_Filldraw4INP

PlotDone
	POP {R0-R12, PC}
	
main_Color_Break FUNCTION
	PUSH {R0-R12, LR}


    MOV R9, #1

New_Level_Loop
	PUSH{R0-R8,R10-R12}
	LDR R0, =PlayerColor
	LDRB R1, [R0]
	MOV R1, #0
	STRB R1, [R0]
	MOV R12, R9 ; R12 = level
	SUB R12, #1 ; zero-based (level-1)
	MOV R2, #32 ; 32 bytes per level (8 words × 4)
	MUL R12, R2 ; R12 = (level-1)*32 = byte offset


    LDR R0,  =colorBreaklvl    ; base of all layouts
    ADD R0,  R12               ; R0 -> current level layout

    LDR R1,  =colorBreakMap    ; destination RAM buffer
    MOV R2,  #8                ; copy 8 words
	
copy_level_loop
	LDR R3, [R0], #4 ; read one word, post-inc source
	STR R3, [R1], #4 ; write it, post-inc dest
	SUBS R2, R2, #1
	BNE copy_level_loop

    BL      Draw_Map_Break         ; your existing routine
    ;MOV     R0,  R9                ; R0 = level (1,2,3…)
	
	POP{R0-R8,R10-R12}
	MOV R3,#9
INNERLOOPIN
	BL UP_D0WN_MOVEMENT	
	BL GET_state2
	AND R10,R10,#0X003F
	CMP R10,#32
	BEQ EXIT_CB
	BL DRAW_BALL_MOVEMENT
	BL Check_Win
	CMP R1 ,#0X00AA
	BEQ LOOSER
	CMP R1 ,#0X00FF
	BEQ WINNER
	B INNERLOOPIN

WINNER
	PUSH {R9}
	MOV R6, #0x0000
	MOV R7, #0x0140
	MOV R8, #0
	MOV R9, #480
	MOV R11, #Pink
	BL TFT_Filldraw4INP
	POP {R9}
    ADD     R9,  #1                ; R9 = R9 + 1
    CMP     R9,  #2        ; finished all levels?
    BGT     EXIT_CB                ; yes ? quit the game
    B       New_Level_Loop         ; no  ? load next level
LOOSER
	PUSH {R9}
	MOV R6, #0x0000
	MOV R7, #0x0140
	MOV R8, #0
	MOV R9, #480
	MOV R11, #Red
	BL TFT_Filldraw4INP
	POP {R9}

    B       New_Level_Loop         ; restart same level
EXIT_CB
	POP {R0-R12, PC}
	ENDFUNC

	
	END