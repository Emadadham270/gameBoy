    AREA    MYDATA, DATA, READWRITE


RCC_BASE       EQU     0x40023800
RCC_AHB1ENR    EQU     RCC_BASE + 0x30

GPIOA_BASE     EQU     0x40020000
GPIOA_MODER	   EQU     0x40020000
GPIOA_SPEEDR   EQU     GPIOA_BASE + 0x08
GPIOA_OTYPER   EQU     GPIOA_BASE + 0x04
GPIOA_PUPDR    EQU     GPIOA_BASE + 0x0C
GPIOA_IDR      EQU     GPIOA_BASE + 0x10
GPIOA_ODR      EQU     GPIOA_BASE + 0x14

GPIOB_BASE     EQU     0x40020400
GPIOB_MODER	   EQU     0x40020400
GPIOB_SPEEDR   EQU     GPIOB_BASE + 0x08
GPIOB_OTYPER   EQU     GPIOB_BASE + 0x04
GPIOB_PUPDR    EQU     GPIOB_BASE + 0x0C
GPIOB_IDR      EQU     GPIOB_BASE + 0x10
GPIOB_ODR      EQU     GPIOB_BASE + 0x14

INTERVAL       EQU     0x566004
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
	
RNG_State DCD 1 ; 32-bit seed (must be non-zero)



    AREA    CODEY, CODE, READONLY
    EXPORT  TFT_WriteCommand
    EXPORT  TFT_WriteData
    EXPORT  TFT_Init
    EXPORT  TFT_DrawImage
    EXPORT  TFT_Filldraw4INP
    EXPORT  GET_state
    EXPORT  delay
	EXPORT	CONFIGURE_PORTS
	EXPORT  Num_to_LCD
	EXPORT  DrawDigit
	EXPORT  Init_RandomSeed
	EXPORT  Get_Random

;-----------------------------------------
; Initially call in main function
;-----------------------------------------
CONFIGURE_PORTS FUNCTION
    PUSH{R0-R1,LR}
    
    ;SET the clock of  C B A  PORTS
    LDR R0, =RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, R1 , #0x07 ;00000111 -> HGFEDCBA 
    STR R1, [R0]

;-----------------------------------------
; PART A
;-----------------------------------------

    ;SET THE PORT A AS OUTPUT 
    LDR R0, =GPIOA_MODER
    LDR R1, =0x55555555  ;0101010101---01 -> OUTPUT ;WHY LDR NOT MOV ? MOV CAN'T MOVE LARGER THAN NON-ZERO 16 BITS 
    STR R1, [R0]
    
    ;SET THE SPEED OF THE PORT A as HIGH SPEED
    LDR R0, =GPIOA_SPEEDR
    LDR R1, =0xFFFFFFFF  ;1111111--11 -> High Speed
    STR R1, [R0]

    ;PUSH/PULL
	LDR R0, =GPIOA_OTYPER
	MOV R1, #0x00000000
	STR R1, [R0]

    ;SET THE PUPDR OF THE PORT A as PULL-UP
 	LDR R0, =GPIOA_PUPDR
 	LDR R1, =0x55555555
 	STR R1, [R0]

;-----------------------------------------
; PART B
;-----------------------------------------

    ;SET THE PORT B AS INPUT  
 	LDR R0, =GPIOB_MODER             
 	MOV R1, #0x00000000    ;00000--00 -> INPUT
 	STR R1, [R0]

    ;SET THE SPEED OF THE PORT B as HIGH SPEED
 	LDR R0, =GPIOB_SPEEDR
 	LDR R1, =0xFFFFFFFF
 	STR R1, [R0]

	;SET THE TYPE OF PORT B AS PUSH-PULL
 	LDR R0, =GPIOB_OTYPER
 	MOV R1, #0x00000000
 	STR R1, [R0]

	;SET THE PUPDR OF THE PORT B as PULL-UP
 	LDR R0, =GPIOB_PUPDR
 	LDR R1, =0x55555555
 	STR R1, [R0]

    POP{R0-R1,PC}
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
	LTORG
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
; TFT_Filldraw4INP  color-R11  R6,R7-column start/end   R8,R9-page start/end
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
; R0 -> Input
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


Get_Random FUNCTION  ;gets a random number in R0
	PUSH {R1,LR} ; save caller-saved R1 just in case
    LDR     R1, =RNG_State   ; R1 → state
    LDR     R0, [R1]         ; R0 = current state
    CMP     R0, #0           ; avoid the all-zero lock-up
    MOVEQ   R0, #1
    EOR     R0, R0, R0, LSL #13   ; xorshift32
    EOR     R0, R0, R0, LSR #17
    EOR     R0, R0, R0, LSL #5
    STR     R0, [R1]         ; save new state
    POP     {R1,PC}          ; return with random value in R0
    ENDFUNC

Init_RandomSeed FUNCTION
	LDR R0, =0xE000E018 ; STCURRENT register address
	LDR R0, [R0] ; read whatever value is ticking
	CMP R0, #0 ; keep seed non-zero
	MOVEQ R0, #1
	LDR R1, =RNG_State
	STR R0, [R1]
	BX LR
	ENDFUNC


;------------------------------------------
; Num_to_LCD FUNCTION
;
; Inputs:
;  R0 = binary number to display
;  R1 = X origin
;  R2 = Y origin
;  R3 = segment thickness
;  R4 = segment length
;  R5 = digit count
;  R11 = Color
; Clobbers: R5,R6,R7,R8,R9
; Returns R0 = raw 32-bit segment word (optional)
;------------------------------------------
Num_to_LCD FUNCTION
	PUSH {R5-R9, LR}

	; Save R5 (number of digits to display) to a preserved register
	MOV R9, R5        ; R9 = digit count from user

	; compute digit width = length + 3*thickness
	ADD R5, R4, R3
	ADD R5, R3, LSL #2    ; R5 = 2*R3 + R3 + R4

	; 1) binary → BCD
	BL Binary_to_BCD ; R0 = [d3:d2:d1:d0] BCD

	; 2) BCD → four 7-seg masks in one word
	BL BCD_TO_SEVEN_SEG ; R0 = {seg(d3),seg(d2),seg(d1),seg(d0)}

	; save segment-word, base X
	MOV R7, R0        ; R7 = segment-word
	MOV R6, #0        ; Start with least significant bit (LSB)

loop_digits
	; extract byte = (R7 >> R6) & 0xFF → R12
	MOV R12, R7, LSR R6
	AND R12, R12, #0xFF

	; 3) draw that digit
	BL DrawDigit

	; advance to next digit position
	ADD R2, R2, R5    ; X += digit_width

	; next byte
	ADD R6, R6, #8    ; Move to next significant byte
	SUBS R9, R9, #1   ; Decrement digit counter
	BNE loop_digits   ; Continue until we've drawn requested digits

	POP {R5-R9, PC}
ENDFUNC
	
;INPUT AND OUTPUT IN R0
; Binary_to_BCD
;  R0 = 16-bit binary in
;  R0 = [d3:d2:d1:d0] BCD out
Binary_to_BCD
    PUSH   {R1-R5, LR}
    MOV    R1, R0        ; working copy of binary
    MOV    R2, #0        ; BCD accumulator
    MOV    R3, #16       ; bits to process

b2b_loop
    ; --- add 3 to any nibble ≥ 5 ---
    MOV    R4, R2
    AND    R5, R4, #0x000F
    CMP    R5, #5
    ADDCS  R2, R2, #0x0003

    AND    R5, R4, #0x00F0
    LSR    R5, R5, #4
    CMP    R5, #5
    ADDCS  R2, R2, #0x0030

    AND    R5, R4, #0x0F00
    LSR    R5, R5, #8
    CMP    R5, #5
    ADDCS  R2, R2, #0x0300

    AND    R5, R4, #0xF000
    LSR    R5, R5, #12
    CMP    R5, #5
    ADDCS  R2, R2, #0x3000

    ; --- now shift left and bring in next bit ---
    LSL    R2, R2, #1
    TST    R1, #0x8000
    ORRNE  R2, R2, #1
    LSL    R1, R1, #1

    SUBS   R3, R3, #1
    BNE    b2b_loop

    MOV    R0, R2        ; return BCD
    POP    {R1-R5, PC}
;------------------------------------------------------------
; R0 = [d3:d2:d1:d0] four BCD digits
; Returns R0 = {seg(d3), seg(d2), seg(d1), seg(d0)}
;------------------------------------------------------------
BCD_TO_SEVEN_SEG FUNCTION
	PUSH {R1-R6, LR}
	MOV R2, #0 ; clear output word
	MOV R1, #0 ; bit-shift offset = 0
	MOV R3, #4 ; loop 4 times

loop
	AND R4, R0, #0xF ; R4 = low nibble
decode
	CMP R4, #0
	BEQ digit_zero
	CMP R4, #1
	BEQ digit_one
	CMP R4, #2
	BEQ digit_two
	CMP R4, #3
	BEQ digit_three
	CMP R4, #4
	BEQ digit_four
	CMP R4, #5
	BEQ digit_five
	CMP R4, #6
	BEQ digit_six
	CMP R4, #7
	BEQ digit_seven
	CMP R4, #8
	BEQ digit_eight
	CMP R4, #9
	BEQ digit_nine
	MOV R5, #0         ; invalid ? blank
	B dec_end
	
digit_zero
	MOV R5, #0x3F ; 0 ? 0b0111111
	B dec_end
digit_one
	MOV R5, #0x06 ; 1 ? 0b0000110
	B dec_end
digit_two
	MOV R5, #0x5B ; 2 ? 0b1011011
	B dec_end
digit_three
	MOV R5, #0x4F ; 3 ? 0b1001111
	B dec_end
digit_four
	MOV R5, #0x66 ; 4 ? 0b1100110
	B dec_end
digit_five
	MOV R5, #0x6D ; 5 ? 0b1101101
	B dec_end
digit_six
	MOV R5, #0x7D ; 6 ? 0b1111101
	B dec_end
digit_seven
	MOV R5, #0x07 ; 7 ? 0b0000111
	B dec_end
digit_eight
	MOV R5, #0x7F ; 8 ? 0b1111111
	B dec_end
digit_nine
	MOV R5, #0x6F ; 9 ? 0b1101111
 
dec_end
	MOV R6, R5, LSL R1     ;insert byte at offset R1
	ORR R2, R2, R6        
	ADD R1, R1, #8 		   ;next byte
	LSR R0, R0, #4 		   ;drop low nibble
	SUBS R3, R3, #1 	   ;decrement loop-count
	BNE loop
	
	MOV R0, R2
	POP {R1-R6, PC}
	ENDFUNC
	
; Draw7Segments FUNCTION
; R1 = x coordinate (origin)
; R2 = y coordinate (origin)
; R3 = thickness (e.g., 8)
; R4 = segment length
; R12 = Digit (Only 8 bits, everything else is 0)

DrawDigit FUNCTION
	PUSH {R5-R9, LR}
	
;---------------------------
; SEGMENT A (bit0) – top horizontal
;   x:  x+R3     … x+R3+R4
;   y:  y+2(R3+R4) … y+3R3+2R4
;---------------------------
	TST R12,#0x01
	BEQ skipA
	ADD R8,R2,R3
	ADD R9,R8,R4
	ADD R6,R1,R3
	ADD R6,R6,R3
	ADD R6,R6,R4
	ADD R6,R6,R4
	ADD R7,R6,R3
	BL TFT_Filldraw4INP
skipA

;---------------------------
; SEGMENT B (bit1) – upper-left vertical
;   x:  x      … x+R3
;   y:  y+R4+2R3 … y+2(R3+R4)
;---------------------------
	TST R12,#0x02
	BEQ skipB
	MOV R8,R2
	ADD R9,R2,R3
	ADD R6,R1,R4
	ADD R6,R6,R3
	ADD R6,R6,R3
	ADD R7,R1,R3
	ADD R7,R7,R3
	ADD R7,R7,R4
	ADD R7,R7,R4
	BL TFT_Filldraw4INP
skipB

;---------------------------
; SEGMENT C (bit2) – upper-right vertical
;   x:  x   … x+R3
;   y:  y+R3   … y+R3+R4
;---------------------------
	TST R12,#0x04
	BEQ skipC
	MOV R8,R2
	ADD R9,R8,R3
	ADD R6,R1,R3
	ADD R7,R6,R4
	BL TFT_Filldraw4INP
skipC

;---------------------------
; SEGMENT D (bit3) – bottom horizontal
;   x:  x+R3   … x+R3+R4
;   y:  y      … y+R3
;---------------------------
	TST R12,#0x08
	BEQ skipD
	ADD R8,R2,R3
	ADD R9,R8,R4
	MOV R6,R1
	ADD R7,R1,R3
	BL TFT_Filldraw4INP
skipD

;---------------------------
; SEGMENT E (bit4) – lower-left vertical
;   x:  x+R3+R4 … x+2R3+R4
;   y:  y+R3   … y+R3+R4
;---------------------------
	TST R12,#0x10
	BEQ skipE
	ADD R8,R2,R3
	ADD R8,R8,R4
	ADD R9,R8,R3
	ADD R6,R1,R3
	ADD R7,R6,R4
	BL TFT_Filldraw4INP
skipE

;---------------------------
; SEGMENT F (bit5) – upper-left vertical
;   x:  x+R3+R4 … x+2R3+R4
;   y:  y+2R3+R4 … y+2(R3+R4)
;---------------------------
	TST R12,#0x20
	BEQ skipF
	ADD R8,R2,R3
	ADD R8,R8,R4
	ADD R9,R8,R3
	ADD R6,R1,R3
	ADD R6,R6,R3
	ADD R6,R6,R4
	ADD R7,R1,R3
	ADD R7,R7,R3
	ADD R7,R7,R4
	ADD R7,R7,R4
	BL TFT_Filldraw4INP
skipF

;---------------------------
; SEGMENT G (bit6) – middle horizontal
;   x:  x+R3   … x+R3+R4
;   y:  y+R3+R4 … y+2R3+R4
;---------------------------
	TST R12,#0x40
	BEQ skipG
	ADD R8,R2,R3
	ADD R9,R8,R4
	ADD R6,R1,R3
	ADD R6,R6,R4
	ADD R7,R6,R3
	BL TFT_Filldraw4INP
skipG
	POP {R5-R9, PC}
	ENDFUNC
	
	END