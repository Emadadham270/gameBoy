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

		
	AREA ColorBreakMAP, DATA, READWRITE
		
		
PlayerColor DCB 0x00 


colorBreakMap
		DCD    0x11144001
		DCD    0x11144002
		DCD    0x00000001
		DCD    0x08880000
		DCD    0x08880000
		DCD    0x00000001
		DCD    0x11144003
		DCD    0x11144001
			
	AREA    ColorBreakeCode, CODE, READONLY
    IMPORT  TFT_WriteCommand
    IMPORT  TFT_WriteData
    IMPORT  TFT_DrawImage
	IMPORT  TFT_Filldraw4INP
    IMPORT  delay
	IMPORT  GET_state2			
	IMPORT TFT_DRAWSQUARE






Draw_Map_Break FUNCTION
    PUSH {R0-R12, LR}

    MOV R6, #0x0000       ; Start X position
    MOV R7, #0x0140       ; End X position, (320 pixels)
    MOV R8, #0x0028       ; Start Y position (40 pixels)
    MOV R9, #0x01E0       ; End Y position, (480 pixels)

    ; Fill screen with background color
    MOV R11, #LightPink
    BL TFT_Filldraw4INP

    MOV R1, #0          ; Initial X position
    MOV R2, #80         ; Initial Y position
    MOV R3, #0          ; Track coulmn

col_LOOP
    CMP R3, #8          ; Check if all coulmns processed
    BEQ FINISH_MAP

    LDR R0, =colorBreakMap   ; Load base address of the map data
    LDR R9, [R0, R3]    ; Load double word data for current row

    MOV R4, #0          ; Track current rows

row_LOOP
    CMP R4, #32          ; Check if all columns processed
    BEQ Next_col_MAP

    ; Check the block type in the current column
    LSR R5, R9, R4      ; Extract the relevant bits
    AND R5, R5, #0xF    ; Mask block type (assume 4 bits per block)

    ; Determine the color based on block type
    CMP R5, #0x1        ; Wall
    MOVEQ R11, #Gray
    
    CMP R5, #0x2        ; Change color
    MOVEQ R11, #Purple
    
    CMP R5, #0x3        ; Kill
    MOVEQ R11, #Red
    
    CMP R5, #0x4        ; Color 0
    MOVEQ R11, #Blue
    
    CMP R5, #0x8        ; Color 1
    MOVEQ R11, #Yellow

    ; Draw the block if it is not Void
    CMP R5, #0x0
    BNE TFT_DRAWSQUARE  ; If not Void, draw the block

SkipDraw
    ADD R1, #40         ; Move to next block along the col
    ADD R4, #8          ; Increment rows count
    B row_LOOP

Next_col_MAP
    ADD R2, #40         ; Move Y position down for next col
    MOV R1, #0          ; Reset X position for new col
    ADD R3, #1          ; Increment column count
    B col_LOOP

FINISH_MAP
    POP {R0-R12, PC}
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
			
			
			
			
			
			
			
			
			
			