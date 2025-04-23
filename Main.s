	AREA RESET, CODE, READONLY

    EXPORT __main
	
	IMPORT SETUP
	IMPORT TEST_A
	IMPORT TEST_B
	IMPORT TEST_C
	
	
;Colors
Red     EQU 0xFFE0 ; 11111 000000 00000; red done
Green   EQU 0x07E0; 00000 111111 00000
Blue    EQU 0x001F  ; 00000 000000 11111
Yellow  EQU 0xFCFC; 11111 111111 00000;green?
White   EQU 0x0000  ; 11111 111111 11111;white done
purple   EQU 0xFFFF  ; 00000 000000 00000; purble "dark "done
	

; Define register base addresses
RCC_BASE        EQU     0x40023800
GPIOA_BASE      EQU     0x40020000
GPIOB_BASE        EQU        0x40020400
GPIOB_IDR 	  	  EQU		 GPIOB_BASE+0x10
; Define register offsets
RCC_AHB1ENR     EQU     0x30
GPIO_MODER      EQU     0x00
GPIO_OTYPER     EQU     0x04
GPIO_OSPEEDR    EQU     0x08
GPIO_PUPDR      EQU     0x0C
GPIO_IDR        EQU     0x10
GPIO_ODR        EQU     0x14

; Control Pins on Port A
TFT_RST         EQU     (1 << 8)
TFT_RD          EQU     (1 << 10)
TFT_WR          EQU     (1 << 11)
TFT_DC          EQU     (1 << 12)
TFT_CS          EQU     (1 << 15)

DELAY_INTERVAL  EQU     0x1D6529  

__main FUNCTION
    ; Enable clocks for GPIOE
    LDR R0, =RCC_BASE + RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, R1, #0x0F
    STR R1, [R0]

    ; Configure GPIOE as General Purpose Output Mode
    LDR R0, =GPIOA_BASE + GPIO_MODER
    LDR R1, =0x55555555  
    STR R1, [R0]

    ; Configure output speed for GPIOE (High Speed)
    LDR R0, =GPIOA_BASE + GPIO_OSPEEDR
    LDR R1, =0xFFFFFFFF  
    STR R1, [R0]

    ; Initialize TFT
    BL TFT_Init


looooop1
	BL GET_state
	and R7, #1
    CMP   R7, #0
    BEQ  looooop1
;**********************************
; additional function that help in case of not pressing on the swtich
;**********************************
    ; Fill screen with color 
    MOV R0, #Red
    BL TFT_FillRed
    
	MOV R0, #White
    BL TFT_FillWhite
    
	MOV R0, #purple
    BL TFT_FillBlack
	
	MOV R0, #Yellow
    BL TFT_Fillyellow
	
	B .
; *************************************************************
; TFT Write Command (R0 = command)
; *************************************************************
TFT_WriteCommand
    PUSH {R1-R2, LR}

    ; Set CS low
    LDR R1, =GPIOA_BASE + GPIO_ODR
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

    POP {R1-R2, LR}
    BX LR

; *************************************************************
; TFT Write Data (R0 = data)
; *************************************************************
TFT_WriteData
    PUSH {R1-R2, LR}

    ; Set CS low
    LDR R1, =GPIOA_BASE + GPIO_ODR
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

    POP {R1-R2, LR}
    BX LR

; *************************************************************
; TFT Initialization
; *************************************************************
TFT_Init
    PUSH {R0-R2, LR}

    ; Reset sequence
    LDR R1, =GPIOA_BASE + GPIO_ODR
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
TFT_FillRed
    PUSH {R1-R5, LR}

    ; Save color
    MOV R5, R0

    ; Set PAGE Address (0-239)
    MOV R0, #0x2A
    BL TFT_WriteCommand
  
  ;start row
	MOV R0, #0x00		
    BL TFT_WriteData
    MOV R0, #0x00		
    BL TFT_WriteData
	
  ;end row
	MOV R0, #0x00 		; High byte of 0x013F (319)
    BL TFT_WriteData
    MOV R0, #0x6A      ; low byte of 0x013F (319)
    BL TFT_WriteData
	
	

	

    ; Set COL Address (0-319)
    MOV R0, #0x2B
    BL TFT_WriteCommand
    ;start col
	MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x00
    BL TFT_WriteData
    ;end col
	MOV R0, #0x01      ; High byte of 0x01DF (479)
    BL TFT_WriteData
    MOV R0, #0xDF      ; Low byte of 0x01DF (479)
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
    BX LR
	
	
	
TFT_FillWhite
    PUSH {R1-R5, LR}

    ; Save color
    MOV R5, R0

    ; Set PAGE Address (0-239)
    MOV R0, #0x2A
    BL TFT_WriteCommand
  
  ;start row
	MOV R0, #0x00		
    BL TFT_WriteData
    MOV R0, #0x6A		
    BL TFT_WriteData
	
  ;end row
	MOV R0, #0x00 		; High byte of 0x013F (319)
    BL TFT_WriteData
    MOV R0, #0xD4      ; low byte of 0x013F (319)
    BL TFT_WriteData
	
	

	

    ; Set COL Address (0-319)
    MOV R0, #0x2B
    BL TFT_WriteCommand
    ;start col
	MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x00
    BL TFT_WriteData
    ;end col
	MOV R0, #0x01      ; High byte of 0x01DF (479)
    BL TFT_WriteData
    MOV R0, #0xDF      ; Low byte of 0x01DF (479)
    BL TFT_WriteData

    ; Memory Write
    MOV R0, #0x2C
    BL TFT_WriteCommand

    ; Prepare color bytes
    MOV R1, R5, LSR #8     ; High byte
    AND R2, R5, #0xFF      ; Low byte

    ; Fill screen with color (320x480 = 153600 pixels)
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
    BX LR
	

TFT_FillBlack
       PUSH {R1-R5, LR}

    ; Save color
    MOV R5, R0

    ; Set PAGE Address (0-239)
    MOV R0, #0x2A
    BL TFT_WriteCommand
  
  ;start row
	MOV R0, #0x00		
    BL TFT_WriteData
    MOV R0, #0xD4		
    BL TFT_WriteData
	
  ;end row
	MOV R0, #0x01 		; High byte of 0x013F (319)
    BL TFT_WriteData
    MOV R0, #0x3F      ; low byte of 0x013F (319)
    BL TFT_WriteData
	
	

	

    ; Set COL Address (0-319)
    MOV R0, #0x2B
    BL TFT_WriteCommand
    ;start col
	MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0x00
    BL TFT_WriteData
    ;end col
	MOV R0, #0x01      ; High byte of 0x01DF (479)
    BL TFT_WriteData
    MOV R0, #0xDF      ; Low byte of 0x01DF (479)
    BL TFT_WriteData

    ; Memory Write
    MOV R0, #0x2C
    BL TFT_WriteCommand

    ; Prepare color bytes
    MOV R1, R5, LSR #8     ; High byte
    AND R2, R5, #0xFF      ; Low byte

    ; Fill screen with color (320x480 = 153600 pixels)
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
    BX LR



TFT_Fillyellow
    PUSH {R1-R5, LR}

    ; Save color
    MOV R5, R0

    ; Set PAGE Address (0-319)
    MOV R0, #0x2A
    BL TFT_WriteCommand
  
  ;start row
	MOV R0, #0x00		
    BL TFT_WriteData
    MOV R0, #0x8D		
    BL TFT_WriteData
	
  ;end row
	MOV R0, #0x00 		; High byte of 0x013F (319)
    BL TFT_WriteData
    MOV R0, #0xB1      ; low byte of 0x013F (319)
    BL TFT_WriteData
	
	

	

    ; Set COL Address (0-479)
    MOV R0, #0x2B
    BL TFT_WriteCommand
    ;start col
	MOV R0, #0x00
    BL TFT_WriteData
    MOV R0, #0xE1
    BL TFT_WriteData
    ;end col
	MOV R0, #0x01      ; High byte of 0x01DF (479)
    BL TFT_WriteData
    MOV R0, #0x09      ; Low byte of 0x01DF (479)
    BL TFT_WriteData

    ; Memory Write
    MOV R0, #0x2C
    BL TFT_WriteCommand

    ; Prepare color bytes
    MOV R1, R5, LSR #8     ; High byte
    AND R2, R5, #0xFF      ; Low byte

    ; Fill screen with color (320x480 = 153600 pixels)
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
    BX LR
	
	
; *************************************************************
; GET STATE  Gets button status In R7
; *************************************************************
GET_state
	PUSH {LR}
	MOV R7,#0
	LDR R0, =GPIOB_IDR   ; Load address of input data register
	LDR R7, [R0]         ; Read GPIOB input register   ; Shift right to get PC8 at bit 0 and PC9 at bit 1 and PC10 at bit 2 and PC11 at bit 3
	POP {PC}


; *************************************************************
; Delay Functions
; *************************************************************
delay
    PUSH {R0, LR}
    LDR R0, =DELAY_INTERVAL
delay_loop
    SUBS R0, R0, #1
    BNE delay_loop
    POP {R0, LR}
    BX LR

    ENDFUNC
    END
	
	END