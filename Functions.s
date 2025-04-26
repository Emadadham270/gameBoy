    AREA    MYDATA, DATA, READWRITE


XO_array       DCD     0x00000000

XO_counter     DCB     0x00


RCC_BASE       EQU     0x40023800
RCC_AHB1ENR    EQU     RCC_BASE + 0x30

GPIOA_BASE     EQU     0x40020000
GPIOA_SPEEDR   EQU     GPIOA_BASE + 0x08
GPIOA_OTYPER   EQU     GPIOA_BASE + 0x04
GPIOA_PUPDR    EQU     GPIOA_BASE + 0x0C
GPIOA_IDR      EQU     GPIOA_BASE + 0x10
GPIOA_ODR      EQU     GPIOA_BASE + 0x14

GPIOB_BASE     EQU     0x40020400
GPIOB_SPEEDR   EQU     GPIOB_BASE + 0x08
GPIOB_OTYPER   EQU     GPIOB_BASE + 0x04
GPIOB_PUPDR    EQU     GPIOB_BASE + 0x0C
GPIOB_IDR      EQU     GPIOB_BASE + 0x10
GPIOB_ODR      EQU     GPIOB_BASE + 0x14

GPIOC_BASE     EQU     0x40020800
GPIOC_SPEEDR   EQU     GPIOC_BASE + 0x08
GPIOC_OTYPER   EQU     GPIOC_BASE + 0x04
GPIOC_PUPDR    EQU     GPIOC_BASE + 0x0C
GPIOC_IDR      EQU     GPIOC_BASE + 0x10
GPIOC_ODR      EQU     GPIOC_BASE + 0x14

INTERVAL       EQU     0x566004
INTERVAL025       EQU     0x159801
;--- TFT control-line masks ---
TFT_RST        EQU     (1 << 8)
TFT_RD         EQU     (1 << 10)
TFT_WR         EQU     (1 << 11)
TFT_DC         EQU     (1 << 12)
TFT_CS         EQU     (1 << 15)

;--- Colors ---
Red     	   EQU 0Xf800 
Green   	   EQU 0xF0FF
Blue    	   EQU 0x02ff 
Yellow  	   EQU 0xFfe0
White   	   EQU 0xffff
Black		   EQU 0x0000
	




    AREA    CODEY, CODE, READONLY
	IMPORT X1
	IMPORT O1
    EXPORT  SETUP
    EXPORT  TFT_WriteCommand
    EXPORT  TFT_WriteData
    EXPORT  TFT_Init
    EXPORT  TFT_DrawImage
    EXPORT  TFT_DrawGrid
    EXPORT  TFT_Filldraw4INP
    EXPORT  GET_state
    EXPORT  delay
	
    EXPORT  Draw_XO
    EXPORT  Check_Win
	EXPORT  DrawBorder
	EXPORT	DrawTA3ADOL
	EXPORT	DrawOWINS
	EXPORT	DrawXWINS		
    EXPORT  Update_Left_Sidebar
	EXPORT  TFT_MoveCursor 
	EXPORT  Main_Game_XO



;------------------------
; SETUP
;------------------------
SETUP FUNCTION
	PUSH {R0-R2, LR}
	; Enable GPIOA clock
	LDR R0, =RCC_AHB1ENR ; Address of RCC_APB2ENR register
	LDR R1, [R0] ; Read the current value of RCC_APB2ENR
	MOV R2, #1
	ORR R1, R1, R2
	STR R1, [R0] ; Write the updated value back to RCC_APB2ENR


	LDR R0, =RCC_AHB1ENR         ;PORT B CLOCK
	LDR R1, [R0]                 
	MOV R2, #1
	ORR R1, R1, R2, LSL #1       		
	STR R1, [R0]                 

	LDR R0, =RCC_AHB1ENR         ;PORT c CLOCK
	LDR R1, [R0]                 
	MOV R2, #1
	ORR R1, R1, R2, LSL #2      		
	STR R1, [R0]    

	; Configure PORT A AS OUTPUT 
	LDR R0, =GPIOA_BASE                  
	MOV R2, #0x55555555    
	STR R2, [R0]


	; Configure PORT B AS INPUT 
	LDR R0, =GPIOB_BASE                  
	MOV R2, #0x00000000    
	STR R2, [R0]

	; Configure PORT C AS OUTPUT 
	LDR R0, =GPIOC_BASE          
	MOV R2, #0x55555555     
	STR R2, [R0]                 


	;SPEED PORT A
	LDR R0, =GPIOA_SPEEDR
	MOV R2, #0xFFFFFFFF
	STR R2, [R0]

	;SPEED PORT B
	LDR R0, =GPIOB_SPEEDR
	MOV R2, #0xFFFFFFFF
	STR R2, [R0]

	;SPEED PORT C
	LDR R0, =GPIOC_SPEEDR
	MOV R2, #0xFFFFFFFF
	STR R2, [R0]



	;PUSH/PULL
	LDR R0, =GPIOA_OTYPER
	MOV R2, #0x00000000
	STR R2, [R0]

	;PUSH/PULL
	LDR R0, =GPIOB_OTYPER
	MOV R2, #0x00000000
	STR R2, [R0]

	;PUSH/PULL
	LDR R0, =GPIOC_OTYPER
	MOV R2, #0x00000000
	STR R2, [R0]


	;PULL UP 
	LDR R0, =GPIOA_PUPDR
	MOV R2, #0x55555555
	STR R2, [R0]

	;PULL UP 
	LDR R0, =GPIOB_PUPDR
	MOV R2, #0x55555555
	STR R2, [R0]

	;PULL UP 
	LDR R0, =GPIOC_PUPDR
	MOV R2, #0x55555555
	STR R2, [R0]

	POP{R0-R2, PC}
	ENDFUNC

	; *************************************************************
	; TFT Write Command (R0 = command)
	; *************************************************************
TFT_WriteCommand FUNCTION
	PUSH {R1-R2, LR}

	; Set CS low
	LDR R1, =GPIOA_ODR
	LDR R2, [R1]
	BIC R2, R2, #TFT_CS
	STR R2, [R1]

	; Set DC (RS) low for command
	BIC R2, R2, #TFT_DC
	STR R2, [R1]

	; Set RD high (not used in write operation)
	ORR R2, R2, #TFT_RD
	STR R2, [R1]

	; Send command (R0 contains command)
	BIC R2, R2, #0xFF   ; Clear data bits PA0-PA7
	AND R0, R0, #0xFF   ; Ensure only 8 bits
	ORR R2, R2, R0      ; Combine with control bits
	STR R2, [R1]


	; Generate WR pulse (low > high)
	BIC R2, R2, #TFT_WR
	STR R2, [R1]
	ORR R2, R2, #TFT_WR
	STR R2, [R1]
	; Set CS high
	ORR R2, R2, #TFT_CS
	STR R2, [R1]

	POP {R1-R2, PC}
	BX LR
	ENDFUNC

	; *************************************************************
	; TFT Write Data (R0 = data)
	; *************************************************************
TFT_WriteData FUNCTION
	PUSH {R1-R2, LR}


	; Set CS low
	LDR R1, =GPIOA_ODR
	LDR R2, [R1]
	BIC R2, R2, #TFT_CS
	STR R2, [R1]

	; Set DC (RS) high for data
	ORR R2, R2, #TFT_DC
	STR R2, [R1]

	; Set RD high (not used in write operation)
	ORR R2, R2, #TFT_RD
	STR R2, [R1]
	; Send data (R0 contains data)
	BIC R2, R2, #0xFF   ; Clear data bits PE0-PE7
	AND R0, R0, #0xFF   ; Ensure only 8 bits
	ORR R2, R2, R0      ; Combine with control bits
	STR R2, [R1]

	; Generate WR pulse
	BIC R2, R2, #TFT_WR
	STR R2, [R1]
	ORR R2, R2, #TFT_WR
	STR R2, [R1]
	; Set CS high
	ORR R2, R2, #TFT_CS
	STR R2, [R1]

	POP {R1-R2, PC}
	BX LR
	ENDFUNC

	; *************************************************************
	; TFT Initialization
	; *************************************************************
TFT_Init FUNCTION
	PUSH {R0-R2, LR}

	; Reset sequence
	LDR R1, =GPIOA_ODR
	LDR R2, [R1]

	; Reset low
	BIC R2, R2, #TFT_RST
	STR R2, [R1]
	BL delay

	; Reset high
	ORR R2, R2, #TFT_RST
	STR R2, [R1]
	BL delay
	; Set Pixel Format (16-bit)
	MOV R0, #0x3A
	BL TFT_WriteCommand
	MOV R0, #0x55
	BL TFT_WriteData
	BL HIj
	LTORG
HIj	
	; Set Contrast VCOM
	MOV R0, #0xC5
	BL TFT_WriteCommand
	MOV R0, #0x54  ;SET VCOMH TO BIG VALUE
	BL TFT_WriteData
	MOV R0, #0x00  ;SET VCOML TO SMALL VALUE
	BL TFT_WriteData

	MOV R0,#0x36
	BL TFT_WriteCommand
	MOV R0,#0x08
	BL TFT_WriteData

	; Sleep Out
	MOV R0, #0x11
	BL TFT_WriteCommand
	BL delay

	; Enable Color Inversion
	;MOV R0, #0x21      ; Command for Color Inversion ON
	;BL TFT_WriteCommand

	; Display ON
	MOV R0, #0x29
	BL TFT_WriteCommand

	POP {R0-R2, PC}
	BX LR
	ENDFUNC

; *************************************************************
; TFT Draw Image (R1 = X, R2 = Y, R3 = Image Address)
; *************************************************************
TFT_DrawImage FUNCTION
	PUSH {R0-R12, LR}


	; Load image width and height
	LDR R4, [R3], #4  ; Load width  (R3 = Width)
	LDR R5, [R3], #4  ; Load height (R4 = Height)

	; =====================
	; Set Column Address (X Start, X End)
	; =====================
	MOV R0, #0x2A
	BL TFT_WriteCommand
	MOV R0,R1,LSR #8
	BL TFT_WriteData
	UXTB R0,R1
	;MOV R0, R1  ; X Start
	BL TFT_WriteData
	ADD R0, R1, R4
	SUB R0, R0, #1  ; X End = X + Width - 1	
	MOV R0,R0,LSR #8
	BL TFT_WriteData
	ADD R0, R1, R4
	SUB R0, R0, #1  ; X End = X + Width - 1
	BL TFT_WriteData

; =====================
; Set Page Address (Y Start, Y End)
; =====================
	MOV R0, #0x2B
	BL TFT_WriteCommand
	MOV R0,R2,LSR #8
	BL TFT_WriteData
	UXTB R0,R2
	;MOV R0, R1  ; X Start
	BL TFT_WriteData
	ADD R0, R2, R5
	SUB R0, R0, #1  ; X End = X + Width - 1	
	MOV R0,R0,LSR #8
	BL TFT_WriteData
	ADD R0, R2, R5
	SUB R0, R0, #1  ; X End = X + Width - 1
	BL TFT_WriteData

; =====================
; Start Writing Pixels
; =====================
	MOV R0, #0x2C
	BL TFT_WriteCommand	

; =====================
; Send Pixel Data (BGR565)
; =====================
	MUL R6, R4, R5  ; Total pixels = Width × Height
TFT_ImageLoop
	LDRH R0, [R3], #2 ; Load one pixel (16-bit BGR565)
	MOV R1, R0, LSR #8 ; Extract high byte
	AND R2, R0, #0xFF ; Extract low byte


	MOV R0, R1         ; Send High Byte first
	BL TFT_WriteData
	MOV R0, R2         ; Send Low Byte second
	BL TFT_WriteData

	SUBS R6, R6, #1
	BNE TFT_ImageLoop

	POP {R0-R12, PC}
	BX LR
	ENDFUNC

;------------------------
; TFT_DrawGrid
;------------------------
TFT_DrawGrid    FUNCTION
	PUSH {R0-R10, LR}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color (area)
    MOV R11, #Black
	BL TFT_Filldraw4INP
	MOV R6,#0X0008
	MOV R7,#0X0138
	MOV R8,#0X0008
	MOV R9,#0X0138
    ; Fill screen with color (area)
    MOV R11, #White
    BL TFT_Filldraw4INP
	MOV R6,#0X0068
	MOV R7,#0X0070
	MOV R8,#0X0008
	MOV R9,#0X0138
    ; Fill screen with color (line)
    MOV R11, #Black
    BL TFT_Filldraw4INP
	MOV R6,#0X00D0
	MOV R7,#0X00D8
	MOV R8,#0X0008
	MOV R9,#0X0138
    ; Fill screen with color (line)
    MOV R11, #Black
    BL TFT_Filldraw4INP
	MOV R6,#0X0008
	MOV R7,#0X0138
	MOV R8,#0X0068
	MOV R9,#0X0070

    ; Fill screen with color (line)
    MOV R11, #Black
    BL TFT_Filldraw4INP
	MOV R6,#0X0008
	MOV R7,#0X0138
	MOV R8,#0X00D0
	MOV R9,#0X00D8
    ; Fill screen with color (line)
    MOV R11, #Black
    BL TFT_Filldraw4INP
	POP {R0-R10, LR}
    BX LR
	ENDFUNC

; *************************************************************
; ReDraw Square R6,R7-column start/end   R8,R9-page start/end ,ColorBackground=R0, ColorSquare=R11, Direction=R10 
;(0->Nochange,1->Up 2->Down 4->Left 8->right)
; *************************************************************
DrawBorder FUNCTION;take r1,x r2,y 
	PUSH{R0-R12,LR}
	SUB R6,R1,#8
	MOV R7,R1
	SUB R8,R2,#8
	ADD R9,R2,#0X68
	BL TFT_Filldraw4INP ; Remove Square -> By change the color to BG Color
	SUB R6,R1,#8
	ADD R7,R1,#0X68
	SUB R8,R2,#8
	MOV R9,R2
	BL TFT_Filldraw4INP ; Remove Square -> By change the color to BG Color
	SUB R6,R1,#8
	ADD R7,R1,#0X68
	ADD R8,R2,#0X60
	ADD R9,R2,#0X68
	BL TFT_Filldraw4INP ; Remove Square -> By change the color to BG Color
	ADD R6,R1,#0X60
	ADD R7,R1,#0X68
	SUB R8,R2,#8
	ADD R9,R2,#0X68
	BL TFT_Filldraw4INP ; Remove Square -> By change the color to BG Color
	pop{R0-R12,PC}
	ENDFUNC
	
TFT_MoveCursor FUNCTION; Take X-R1; Y-R2 : Input in R10
	 PUSH{R11-R12,LR}
	 
	 MOV R11, #Black
	 BL DrawBorder
	 
	 MOV R12 , R10
	 AND R12, #0x000F
	 CMP R12 , #1
	 BEQ MOVE_UPB
	  
	 CMP R12 , #2
	 BEQ MOVE_DOWNB
	 
	 CMP R12 , #4
	 BEQ MOVE_LEFTB
	 
	 CMP R12 , #8
	 BEQ MOVE_RIGHTB
	 
	 B DEFAULTB
MOVE_UPB
	 CMP R2 , #0xD8 ; checking the start
	 BEQ DEFAULTB
	 ADD R2 , R2 , #0x68
	 B DEFAULTB
	 
MOVE_DOWNB
	 CMP R2 , #0x08
	 BEQ DEFAULTB
	 SUB R2 , R2 , #0x68
	 B DEFAULTB
	 
MOVE_RIGHTB
	 CMP R1 , #0x08
	 BEQ DEFAULTB
	 SUB R1 , R1 , #0x68
	 B DEFAULTB
	 
MOVE_LEFTB
	 CMP R1 , #0xD8
	 BEQ DEFAULTB
	 ADD R1 , R1 , #0x68
	 B DEFAULTB
	 
DEFAULTB
	 MOV R11,#Yellow
	 BL DrawBorder
	 pop{R11-R12,PC}
	 ENDFUNC






;------------------------
; TFT_Filldraw4INP  color-R0  R6,R7-column start/end   R8,R9-page start/end
;------------------------
TFT_Filldraw4INP    FUNCTION
    PUSH {R1-R5,R10,R11,R12, LR}
    
    ; Save color
    MOV R5, R11

    ; Set PAGE Address (0-239)
    MOV R0, #0x2A
    BL TFT_WriteCommand
  
  ;start row
	MOV R10,R6
	MOV R10,R10,LSR #8
	
	MOV R0,R10		
    BL TFT_WriteData
    MOV R0,R6		
    BL TFT_WriteData
	
  ;end row
  	MOV R10,R7
	MOV R10,R10,LSR #8
	MOV R0, R10 		; High byte of 0x013F (319)
    BL TFT_WriteData
    MOV R0, R7      ; low byte of 0x013F (319)
    BL TFT_WriteData
	
	



    ; Set COL Address (0-319)
    MOV R0, #0x2B
    BL TFT_WriteCommand	
	MOV R10,R8
	MOV R10,R10,LSR #8
    ;start col
	MOV R0, R10
    BL TFT_WriteData
    MOV R0, R8
    BL TFT_WriteData
    ;end col
	MOV R10,R9
	MOV R10,R10,LSR #8
	MOV R0, R10      ; High byte of 0x01DF (479)
    BL TFT_WriteData
    MOV R0, R9      ; Low byte of 0x01DF (479)
    BL TFT_WriteData

    ; Memory Write
    MOV R0, #0x2C
    BL TFT_WriteCommand

    ; Prepare color bytes
    MOV R1, R5, LSR #8     ; High byte
    AND R2, R5, #0xFF      ; Low byte
	SUB	R11,R7,R6
	ADD R11,#10
	SUB	R12,R9,R8
	ADD R12,#10
    ; Fill screen with color (320x480 = 153600 pixels)
    MUL R3,R11,R12
FillLoopdraw4INP
    ; Write high byte
    MOV R0, R1
    BL TFT_WriteData
    
    ; Write low byte
    MOV R0, R2
    BL TFT_WriteData
    
    SUBS R3, R3, #1
    BNE FillLoopdraw4INP

    POP {R1-R5,R10,R11,R12, LR}
    BX LR
	ENDFUNC


;------------------------
; GET_state  (debounced)
;------------------------
GET_state FUNCTION
	PUSH {R1,LR}
	MOV R10,#0
	LDR R0, =GPIOB_IDR   ; Load address of input data register
	LDR R10, [R0]         ; Read GPIOB input register   ; Shift right to get PC8 at bit 0 and PC9 at bit 1 and PC10 at bit 2 and PC11 at bit 3
	MOV	R0,#10
	BL delay
	POP {R1,PC}
	ENDFUNC	
	
	

;------------------------
; delay
;------------------------
delay    FUNCTION
    PUSH    {R0-R12, LR}
	LDR		R1,=INTERVAL
	
DelayInner_Loop
    SUBS    R1, R0
    CMP     R1, #0
    BGT     DelayInner_Loop
    POP     {R0-R12, PC}
	ENDFUNC

;------------------------
; Draw_XO  R1-column start   R2-page start
;------------------------
Draw_XO    FUNCTION
    PUSH    {R0-R12, LR} ;R12 STORES THE CELL NUMBER
											   ; 32   16    8    4     2     1
	MOV R12, #0x0000       ;Lowest 6 bits in R12: up-middle-down-left-middle-right
	
	CMP R1, #0x8       ;Right
	BEQ Right
	CMP R1, #0x70      ;Middle X
	BEQ MiddleX
	CMP R1, #0xD8	   ;Left
	BEQ Left

PageTest
	CMP R2, #0x8       ;Down
	BEQ Down
	CMP R2, #0x70      ;Middle Y
	BEQ MiddleY
	CMP R2, #0xD8	   ;Up
	BEQ Up

Right
	ADD R12, #1
	B PageTest
MiddleX
	ADD R12, #2
	B PageTest
Left
	ADD R12, #4
	B PageTest
	
Down
	ADD R12, #8
	B Continue1
MiddleY
	ADD R12, #16
	B Continue1
Up
	ADD R12, #32
	B Continue1
	

Continue1
	CMP R12, #36
	BEQ onee
	CMP R12, #34
	BEQ twoo
	CMP R12, #33
	BEQ threee
	CMP R12, #20
	BEQ fourr
	CMP R12, #18
	BEQ fivee
	CMP R12, #17
	BEQ sixx
	CMP R12, #12
	BEQ sevenn
	CMP R12, #10
	BEQ eightt
	CMP R12, #9
	BEQ ninee
	
onee
	MOV R12, #1
	B Continue2
twoo
	MOV R12, #2
	B Continue2
threee
	MOV R12, #3
	B Continue2
fourr
	MOV R12, #4
	B Continue2
fivee
	MOV R12, #5
	B Continue2
sixx
	MOV R12, #6
	B Continue2
sevenn
	MOV R12, #7
	B Continue2
eightt
	MOV R12, #8
	B Continue2
ninee
	MOV R12, #9
	B Continue2

Continue2
	LDR   R11, =XO_array
	LDR   R11, [R11]	; R11 = bitmap word
	;MOV	  R11,#0
	LSL   R4, R12, #1         ; R4 = 2 * X
	SUB   R4, R4, #2
	; R4 = 2*X – 2
	MOV R5, #3 ; R5 = 0b11
	LSL R5, R5, R4 ; R5 = 3 << R4
	AND R5,R11,R5
	LSR R5, R5, R4 ; R5 = 3 >> R4

	CMP R5,#2
	BEQ   AlreadyDrawn
	CMP R5,#1
	BEQ   AlreadyDrawn
	; --- clear the two bits at [base..base+1] ---
    MOV   R5, #3           ; R5 = 0b11
    LSL   R5, R5, R4       ; R5 = 0b11 << base
    BIC    R11, R11, R5     ; R11 &= ~(0b11 << base)

    LDR R10,=XO_counter;Check counter (0 = O, 1 = X)
	LDR R10, [R10]	   ;
	AND R10,R10,#2
	CMP R10, #2		   ;Draw X
	BEQ Draw_xX
	CMP R10, #0		   ;Draw O
	BEQ Draw_oO		

   ;
		   ;
Draw_xX  ;11
	SUB R10, #2	   ;Toggle counter
	; --- OR in the pattern 0b11 at [base..base+1] ---
	MOV   R5, #1           ; R5 = 0b01
	;SUB		R4 ,R4,#1
    LSL   R5, R5, R4       ; R5 = 0b11 << base
    ORR   R11, R11, R5     ; R11 |= (0b11 << base)
	LDR R0, =XO_array
	STR R11, [R0]
	LDR R3, =X1
	BL TFT_DrawImage
	LDR R0, =XO_counter
	STR R10, [R0]
	B FiNish	 
	
	
Draw_oO  ;10
	ADD R10, #2		   ;Toggle counter
	; --- OR in the pattern 0b10 at [base..base+1] ---
    MOV   R5, #2           ; R5 = 0b10
    LSL   R5, R5, R4       ; R5 = 0b10 << base
    ORR   R11, R11, R5     ; R11 |= (0b10 << base)
	LDR R0, =XO_array
	STR R11, [R0]
	LDR R3, =O1
	BL TFT_DrawImage
	LDR R0, =XO_counter
	STR R10, [R0]
	B FiNish
	

	
AlreadyDrawn    ;Draw red border momentarily then draw yellow
	MOV R11, #Red
	BL DrawBorder
	MOV R0, #5
	BL delay
	MOV R11, #Yellow
	BL DrawBorder
	
FiNish
	
    POP     {R0-R12, PC}
	ENDFUNC

;------------------------
; Check_Win  (todo)
;------------------------
Check_Win FUNCTION
	PUSH{R0-R12, LR}
	MOV	R1,#0
	LDR R0,=XO_array
	; Pre-load all needed constants into registers
    LDR R2, =0x4104		 ; 0000 0100 0001 0000 0100
    LDR R3, =0x1041		 ; 0000 0001 0000 0100 0001
    LDR R4, =0x1110		 ; 0000 0001 0001 0001 0000
	LDR R5,  =0x10101    ; 0001 0000 0001 0000 0001  
	LDR R6,  =0x10410    ; 0001 0000 0100 0001 0000  
	LDR R7,  =0x2082     ; 0000 0010 0000 1000 0010     + 
	LDR R8,  =0x2220     ; 0000 0010 0010 0010 0000      
	LDR R9,  =0x8208     ; 0000 1000 0010 0000 1000      
	LDR R10, =0x20820    ; 0010 0000 1000 0010 0000  
	LDR R11, =0x20202    ; 0010 0000 0010 0000 0010
	
    LDR R1, [R0]
    AND R1, R1, R2      ; was #0x4104
    CMP R1, R2
    BEQ win_x
	
    LDR R1, [R0]
    AND R1, R1, #0x15
    CMP R1, #0x15
    BEQ win_x
	
	LDR R1, [R0]
	AND R1, R1, R3      ; was #0x30C3
	CMP R1, R3
	BEQ win_x
	
    LDR R1, [R0]
    AND R1, R1, R4      ; was #0x3330
    CMP R1, R4
    BEQ win_x
    
    LDR R1, [R0]
    AND R1, R1, R5      ; was #0x30303
    CMP R1, R5
    BEQ win_x
	
    LDR R1, [R0]
    AND R1, R1, R6      ; was #0x30C30
    CMP R1, R6
    BEQ win_x
    
    LDR R1, [R0]
    AND R1, R1, #0x540
    CMP R1, #0x540
    BEQ win_x

    LDR R1, [R0]
    AND R1, R1, #0x15000
    CMP R1, #0x15000
    BEQ win_x

	;;;;;;;;;;;;;;;;;;;;;;;
    ; Check O wins
    LDR R1, [R0]
    AND R1, R1, R7      ; was #0x2082
    CMP R1, R7
    BEQ win_o

    LDR R1, [R0]
    AND R1, R1, R8      ; was #0x2220
    CMP R1, R8
    BEQ win_o
    
    LDR R1, [R0]
    AND R1, R1, #0x2A
    CMP R1, #0x2A
    BEQ win_o
    
    LDR R1, [R0]
    AND R1, R1, R9      ; was #0x8208
    CMP R1, R9
    BEQ win_o
	
    LDR R1, [R0]
    AND R1, R1, R10     ; was #0x20820
    CMP R1, R10
    BEQ win_o
    
    LDR R1, [R0]
    AND R1, R1, #0xA80
    CMP R1, #0xA80
    BEQ win_o
    
    LDR R1, [R0]
    AND R1, R1, #0x2A000
    CMP R1, #0x2A000
    BEQ win_o
	
    LDR R1, [R0]
    AND R1, R1, R11      ; was #0x20202
    CMP R1, R11
    BEQ win_o
    ; Check Draw wins
    ;LDR R1, [R0]
    ;AND R1, R1, R12      ; was #0x2AAAA
    ;CMP R1, R12
    ;BEQ ta3adol_check
	B wala7aga
win_x
	BL DrawXWINS
	LDR R0, [R0]
	MOV R1, #0xFFFFFFFF
	STR R1, [R0]
	B wala7aga
win_o	
	BL DrawOWINS
	LDR R0, [R0]
	MOV R1, #0xFFFFFFFF
	STR R1, [R0]
	B wala7aga
ta3adol_check
	BL DrawTA3ADOL
	LDR R0, [R0]
	MOV R1, #0xFFFFFFFF
	STR R1, [R0]
	B wala7aga
wala7aga
	POP{R0-R12,PC}
	ENDFUNC
	

DrawXWINS	FUNCTION
	PUSH {R0-R12, LR}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color (area)
    MOV R11, #Green
	BL TFT_Filldraw4INP
	MOV R1,#80
	MOV R2,#120
	LDR R3, =X1
	BL TFT_DrawImage
	BL FinIsh
	POP {R0-R12, PC}
	ENDFUNC
	
DrawOWINS	FUNCTION
	PUSH {R0-R12, LR}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color (area)
    MOV R11, #Green
	BL TFT_Filldraw4INP
	MOV R1,#80
	MOV R2,#120
	LDR R3, =O1
	BL TFT_DrawImage
	BL FinIsh
	POP {R0-R12, PC}
	ENDFUNC
	
DrawTA3ADOL	FUNCTION
	PUSH {R0-R12, LR}
	MOV R6,#0X0000
	MOV R7,#0X0140
	MOV R8,#0X0000
	MOV R9,#0X01E0
    ; Fill screen with color (area)
    MOV R11, #Red
	BL TFT_Filldraw4INP
	BL FinIsh
	POP {R0-R12, PC}


FinIsh
	MOV R0, #1
	BL delay
FINISH_IN1	
	BL GET_state
	AND R10,R10, #0x001F
	CMP R10, #00      ;Keep looping while input = 0
	BEQ FINISH_IN1
	LDR R0, =XO_array
	MOV R1,0X00000000
	STR R1, [R0]
	POP{R0-R12,PC}
	ENDFUNC
;------------------------
; Update_Left_Sidebar  (todo)
;------------------------
Update_Left_Sidebar    FUNCTION
    PUSH    {LR}
    ;TODO
    POP     {PC}
	ENDFUNC


Main_Game_XO FUNCTION
	PUSH{R0-R12,LR}
out	
	BL TFT_DrawGrid
	LDR R12, =XO_array  ;Store 0 in XO_array
	MOV R11, #0
	STR R11, [R12]
	LDR R12, =XO_counter  ;Store 0 in XO_counter
	MOV R11, #0X0010
	STR R11, [R12]
MAINLOOP	
	MOV R1, #0x70
	MOV R2, #0x70
	MOV R11,#Yellow
	BL DrawBorder

INPUT1233                ;Wait for input from user
	BL GET_state
	AND R10,R10, #0x001F
	CMP R10, #00      ;Keep looping while input = 0
	BEQ INPUT1233
	
	CMP R10, #0x0010 ;If input == ENTER, jump to where we draw X/O and check win
	BEQ ENTERrr
	
	BL TFT_MoveCursor
	B INPUT1233
	
ENTERrr
	BL Draw_XO
	MOV R11,#Black
	BL DrawBorder

	BL Check_Win
	LDR R0, =XO_array
	LDR R0, [R0]
	CMP R0,#0
	BEQ out
	B MAINLOOP
	ENDFUNC


    END