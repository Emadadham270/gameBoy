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
	AREA ColorBreakMAP, DATA, READWRITE
		
colorBreakMap
		DCD    0x11144001
		DCD    0x11144002
		DCD    0x00000001
		DCD    0x08880000
		DCD    0x08880000
		DCD    0x00000001
		DCD    0x11144003
		DCD    0x11144001		
PlayerColor DCB 0x00 



			
	AREA    ColorBreakeCode, CODE, READONLY
    IMPORT  TFT_WriteCommand
    IMPORT  TFT_WriteData
    IMPORT  TFT_DrawImage
	IMPORT  TFT_Filldraw4INP
    IMPORT  delay
	IMPORT  GET_state2			
	IMPORT TFT_DRAWSQUARE
	EXPORT Draw_Map_Break



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
    MOV R3, #0            ; Initialize column counter

col_LOOP
    CMP R3, #8            ; Check if all 8 columns processed
    BEQ FINISH_MAP        ; If done, exit function

    LDR R0, =colorBreakMap     ; Load address of map data
    LDR R9, [R0, R3,LSL #2]           ; Load the 32-bit word for current column

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
    
    CMP R5, #0x2          ; Check if Change color (2)
    MOVEQ R11, #Purple    ; Set color to Purple for Change color
    
    CMP R5, #0x3          ; Check if Kill (3)
    MOVEQ R11, #Red       ; Set color to Red for Kill
    
    CMP R5, #0x4          ; Check if Color 0 (4)
    MOVEQ R11, #Blue      ; Set color to Blue for Color 0
    
    CMP R5, #0x8          ; Check if Color 1 (8)
    MOVEQ R11, #Yellow    ; Set color to Yellow for Color 1

    ; Draw square at current position
    BL TFT_DRAWSQUARE     ; Draw a square with selected color
	MOV R1 , R7
	MOV R2 , R9
	BL DrawOutlineW

SkipDraw
    ADD R1, #40           ; Move X position right for next block
    ADD R4, #4            ; Increment bit position by 4 (next block)
    B row_LOOP            ; Continue processing this column

Next_col_MAP
    ADD R2, #40           ; Move Y position down for next column
    MOV R1, #0            ; Reset X position to start of row
    ADD R3, #1            ; Increment column counter
    B col_LOOP            ; Process next column

FINISH_MAP
    POP {R0-R12, PC}      ; Restore registers and return
ENDFUNC

DrawOutlineW FUNCTION;take r1,x r2,y , dimension of square in R4, dimension of outline in R3
	PUSH{R0-R12,LR}
	MOV R4 , #40
	MOV R3 , #1
	SUB R10, R4, R3 ; R10 = dimension of square - dimension of outline
	SUB R6,R1,R3
	MOV R7,R1
	SUB R8,R2,R3
	ADD R9,R2,R4
	BL TFT_Filldraw4INP  ; draw left vertical outline
	SUB R6,R1,R3
	ADD R7,R1,R4
	SUB R8,R2,R3
	MOV R9,R2
	BL TFT_Filldraw4INP ; draw upper horizontal outline
	SUB R6,R1,R3
	ADD R7,R1,R4
	ADD R8,R2,R10
	ADD R9,R2,R4
	BL TFT_Filldraw4INP ; draw lower horizontal outline
	ADD R6,R1,R10
	ADD R7,R1,R4
	SUB R8,R2,R3
	ADD R9,R2,R4
	BL TFT_Filldraw4INP ; draw right vertical outline
	pop{R0-R12,PC}
	ENDFUNC	


CHECK_BLOCK FUNCTION
	PUSH {R0-R12, LR}
	POP{R0-R12,PC}
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
	
	
	
DRAW_BALL_MOVEMENT FUNCTION
	PUSH {R0-R12, LR}
	POP{R0-R12,PC}
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
	
	
	
Check_Win FUNCTION
        PUSH    {R0,R2-R12, LR}

        LDR     R4, =colorBreakMap     ; base address of the map
        MOV     R5, #8                 ; 8 rows

Row_Loop
        LDR     R0, [R4], #4           ; Load one row (32-bit)
        MOV     R6, #8                 ; 8 nibbles per row

Nibble_Loop
        AND     R1, R0, #0xF           ; Extract lowest nibble
        CMP     R1, #4
        BEQ     Not_Win
        CMP     R1, #8
        BEQ     Not_Win

        LSR     R0, R0, #4             ; Shift to next nibble
        SUBS    R6, R6, #1
        BNE     Nibble_Loop

        SUBS    R5, R5, #1             ; Decrement row counter
        BNE     Row_Loop

        MOV     R0, #1 
		MOV R1, #0x00FF             ; Return 00FF for win
		MOV R6,#0X0000
		MOV R7,#0X0140
		MOV R8,#0X0000
		MOV R9,#0X01E0
		MOV R11, #Green
		BL TFT_Filldraw4INP		; Win
        B       End_Check

Not_Win
        MOV     R0, #0                 ; Not win

End_Check
	
        POP     {R0,R2-R12, LR}
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