	AREA MYDATA, DATA, READONLY
	
RCC_BASE	     EQU		0x40023800;;;;;;;;
RCC_AHB1ENR		 EQU		RCC_BASE + 0x30 ;;;;;;


Red     EQU 0xF800  ; 11111 000000 00000
Green   EQU 0x07E0  ; 00000 111111 00000
Blue    EQU 0x001F  ; 00000 000000 11111
Yellow  EQU 0xFFE0  ; 11111 111111 00000
White   EQU 0xFFFF  ; 11111 111111 11111
Black   EQU 0x0000  ; 00000 000000 00000 


TFT_RST         EQU     (1 << 15)
TFT_RD          EQU     (1 << 9)
TFT_WR          EQU     (1 << 10)
TFT_DC          EQU     (1 << 11)
TFT_CS          EQU     (1 << 12)

GPIOC_BASE        EQU        0x40020800  ;;;;;
GPIOC_SPEEDR	  EQU        GPIOC_BASE+0x08;;;;;;;;;
GPIOC_ODR         EQU        GPIOC_BASE+0x14;;;;
GPIOC_IDR         EQU        GPIOC_BASE+0x10;;;;;
GPIOC_OTYPER      EQU        GPIOC_BASE+0x04
GPIOC_PUPDR       EQU		 GPIOC_BASE+0x0C


GPIOA_BASE        EQU        0x40020000 ;;;;;
GPIOA_SPEEDR      EQU		 GPIOA_BASE+0x08;;;;;;;
GPIOA_ODR         EQU        GPIOA_BASE+0x14;;;;;;
GPIOA_IDR 	      EQU		 GPIOA_BASE+0x10;;;;;;
GPIOA_OTYPER      EQU		 GPIOA_BASE+0x04
GPIOA_PUPDR       EQU		 GPIOA_BASE+0x0C
;0x08 



GPIOB_BASE        EQU        0x40020400  ;;;;;;;;;;;;;
GPIOB_SPEEDR      EQU		 GPIOB_BASE+0x08;;;;;;;
GPIOB_ODR     	  EQU        GPIOB_BASE+0x14;;;;;;
GPIOB_IDR 	  	  EQU		 GPIOB_BASE+0x10;;;;;;
GPIOB_OTYPER      EQU		 GPIOB_BASE+0x04
GPIOB_PUPDR       EQU		 GPIOB_BASE+0x0C
;AFIO_BASE		EQU		0x40010000
;AFIO_MAPR	EQU		AFIO_BASE + 0x04
INTERVAL EQU 0x166004
	
	
	
	
	AREA CODEY, CODE, READONLY
	EXPORT SETUP
	EXPORT TEST_A	
	EXPORT TEST_B	
	EXPORT TEST_C
	;EXPORT TFT_Init
	EXPORT TFT_FillRed
	EXPORT TFT_FillBlack
	EXPORT TFT_FillWhite
	EXPORT TFT_Fillyellow
	
	
SETUP  FUNCTION
    PUSH {R0-R2, LR}
    ; Enable GPIOA clock
    LDR R0, =RCC_AHB1ENR         ; Address of RCC_APB2ENR register
    LDR R1, [R0]                 ; Read the current value of RCC_APB2ENR
	MOV R2, #1
    ORR R1, R1, R2       
    STR R1, [R0]                 ; Write the updated value back to RCC_APB2ENR
	
	
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
	
    
    ; Configure PORT B AS OUTPUT 
    LDR R0, =GPIOB_BASE                  
    MOV R2, #0x55555555    
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
	LDR R0, =GPIOA_ODR
	
    BL TFT_Init

    POP{R0-R2, PC}

	ENDFUNC
	
TEST_A  FUNCTION
    PUSH{R0-R12, LR}
    LDR R0, =GPIOA_ODR
    MOV R2, #0

TESTA_LOOP
    MOV R1, #1
    LSL R1, R2
    STR R1, [R0]
    BL delay_1_second
    ADD R2, R2, #1
    CMP R2, #16
    BLT TESTA_LOOP

    POP{R0-R12, PC}

	ENDFUNC


TEST_B  FUNCTION
    PUSH{R0-R12, LR}
    LDR R0, =GPIOB_ODR
    MOV R2, #0

TESTB_LOOP
    MOV R1, #1
    LSL R1, R2
    STR R1, [R0]
    BL delay_1_second
    ADD R2, R2, #1
    CMP R2, #16
    BLT TESTB_LOOP

    POP{R0-R12, PC}
	ENDFUNC


TEST_C  FUNCTION
    PUSH{R0-R12, LR}
    LDR R0, =GPIOC_ODR
    MOV R2, #0

TESTC_LOOP
    MOV R1, #1
    LSL R1, R2
    STR R1, [R0]
    BL delay_1_second
    ADD R2, R2, #1
    CMP R2, #16
    BLT TESTC_LOOP

    POP{R0-R12, PC}
	ENDFUNC







delay_1_second FUNCTION
    PUSH {R0, LR}               ; Push R4 and Link Register (LR) onto the stack
    LDR R0, =INTERVAL           ; Load the delay count
DelayInner_Loop
        SUBS R0, #2             ; Decrement the delay count
		cmp	R0, #0
        BGT DelayInner_Loop     ; Branch until the count becomes zero
    
    POP {R0, PC}                ; Pop R4 and return from subroutine
	ENDFUNC

TFT_WriteCommand 
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
    BIC R2, R2, #0xFF   ; Clear data bits PE0-PE7
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

    POP {R1-R3, LR}
	BX LR
; *************************************************************
; TFT Write Data (R0 = data)
; *************************************************************
TFT_WriteData 
    PUSH {R1-R3, LR}

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

    POP {R1-R3, LR}
	BX LR

; *************************************************************
; TFT Initialization
; *************************************************************
TFT_Init 
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

    ; Sleep Out
    MOV R0, #0x11
    BL TFT_WriteCommand
    BL delay
	
    ; Enable Color Inversion
    MOV R0, #0x21      ; Command for Color Inversion ON
    BL TFT_WriteCommand

    
    ; Display ON
    MOV R0, #0x29
    BL TFT_WriteCommand

    POP {R0-R2, LR}
	BX LR

; *************************************************************
; TFT Fill Screen (R0 = 16-bit color)
; *************************************************************
TFT_FillRed FUNCTION
    PUSH {R1-R5, LR}

    ; Save color
    MOV R5, R0

    ; Set Column Address (0-239)
    MOV R0, #0x2A
    BL TFT_WriteCommand
  
  ;start col
	MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0xA0
    BL TFT_WriteData
  ;end col
	MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0xEF      ; 239
    BL TFT_WriteData
	
	

	

    ; Set Page Address (0-319)
    MOV R0, #0x2B
    BL TFT_WriteCommand
    MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x01      ; High byte of 0x013F (319)
    BL TFT_WriteData
    MOV R0, #0x3F      ; Low byte of 0x013F (319)
    BL TFT_WriteData

    ; Memory Write
    MOV R0, #0x2C
    BL TFT_WriteCommand

    ; Prepare color bytes
    MOV R1, R5, LSR #8     ; High byte
    AND R2, R5, #0xFF      ; Low byte

    ; Fill screen with color (320x480 = 153600 pixels)
    LDR R3, =153600
FillLoopRed
    ; Write high byte
    MOV R0, R1
    BL TFT_WriteData
    
    ; Write low byte
    MOV R0, R2
    BL TFT_WriteData
    
    SUBS R3, R3, #1
    BNE FillLoopRed

    POP {R1-R5, LR}
		ENDFUNC
	
	
TFT_FillWhite FUNCTION
    PUSH {R1-R5, LR}

    ; Save color
    MOV R5, R0

    ; Set Column Address (0-239)
    MOV R0, #0x2A
    BL TFT_WriteCommand
  
  ;start col
	MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x50
    BL TFT_WriteData
  ;end col
	MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0xA0      ; 239
    BL TFT_WriteData
	
	

	

    ; Set Page Address (0-319)
    MOV R0, #0x2B
    BL TFT_WriteCommand
    MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x01      ; High byte of 0x013F (319)
    BL TFT_WriteData
    MOV R0, #0x3F      ; Low byte of 0x013F (319)
    BL TFT_WriteData

    ; Memory Write
    MOV R0, #0x2C
    BL TFT_WriteCommand

    ; Prepare color bytes
    MOV R1, R5, LSR #8     ; High byte
    AND R2, R5, #0xFF      ; Low byte

    ; Fill screen with color (320x240 = 76800 pixels)
    LDR R3, =153600
FillLoopWHITE
    ; Write high byte
    MOV R0, R1
    BL TFT_WriteData
    
    ; Write low byte
    MOV R0, R2
    BL TFT_WriteData
    
    SUBS R3, R3, #1
    BNE FillLoopWHITE

    POP {R1-R5, LR}
		ENDFUNC

TFT_FillBlack FUNCTION
    PUSH {R1-R5, LR}

    ; Save color
    MOV R5, R0

    ; Set Column Address (0-239)
    MOV R0, #0x2A
    BL TFT_WriteCommand
  
  ;start col
	MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x00
    BL TFT_WriteData
  ;end col
	MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x50      ; 239
    BL TFT_WriteData
	
	

	

    ; Set Page Address (0-319)
    MOV R0, #0x2B
    BL TFT_WriteCommand
    MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x01      ; High byte of 0x013F (319)
    BL TFT_WriteData
    MOV R0, #0x3F      ; Low byte of 0x013F (319)
    BL TFT_WriteData

    ; Memory Write
    MOV R0, #0x2C
    BL TFT_WriteCommand

    ; Prepare color bytes
    MOV R1, R5, LSR #8     ; High byte
    AND R2, R5, #0xFF      ; Low byte

    ; Fill screen with color (320x240 = 76800 pixels)
    LDR R3, =153600
FillLoopBLACK
    ; Write high byte
    MOV R0, R1
    BL TFT_WriteData
    
    ; Write low byte
    MOV R0, R2
    BL TFT_WriteData
    
    SUBS R3, R3, #1
    BNE FillLoopBLACK

    POP {R1-R5, LR}
		ENDFUNC



TFT_Fillyellow FUNCTION
    PUSH {R1-R5, LR}

    ; Save color
    MOV R5, R0

    ; Set Column Address (0-239)
    MOV R0, #0x2A
    BL TFT_WriteCommand
  
  ;start col
	MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x69
    BL TFT_WriteData
  ;end col
	MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x82      ; 239
    BL TFT_WriteData
	
	

	

    ; Set Page Address (0-319)
    MOV R0, #0x2B
    BL TFT_WriteCommand
;start row   
   MOV R0, #0x00;00
    BL TFT_WriteData
    MOV R0, #0x95
    BL TFT_WriteData
    ;end row
	MOV R0, #0x00;01      ; High byte of 0x013F (319)
    BL TFT_WriteData
    MOV R0, #0xA0      ; Low byte of 0x013F (319)
    BL TFT_WriteData

    ; Memory Write
    MOV R0, #0x2C
    BL TFT_WriteCommand

    ; Prepare color bytes
    MOV R1, R5, LSR #8     ; High byte
    AND R2, R5, #0xFF      ; Low byte

    ; Fill screen with color (320x240 = 76800 pixels)
    LDR R3, =153600
FillLoopyellow
    ; Write high byte
    MOV R0, R1
    BL TFT_WriteData
    
    ; Write low byte
    MOV R0, R2
    BL TFT_WriteData
    
    SUBS R3, R3, #1
    BNE FillLoopyellow

    POP {R1-R5, LR}
		ENDFUNC; *************************************************************
; Delay Functions
; *************************************************************
delay
    PUSH {R0, LR}
    LDR R0, =INTERVAL
delay_loop
    SUBS R0, R0, #1
    BNE delay_loop
    POP {R0, LR}
    BX LR

	
	
	
	END