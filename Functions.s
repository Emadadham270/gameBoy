	AREA MYDATA, DATA, READONLY
	
RCC_BASE	     EQU		0x40023800;;;;;;;;
RCC_AHB1ENR		 EQU		RCC_BASE + 0x30 ;;;;;;


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
INTERVAL EQU 0x566004
	
	
	
	
	AREA CODEY, CODE, READONLY
	EXPORT SETUP
	EXPORT TEST_A	
	EXPORT TEST_B	
	EXPORT TEST_C	
	
	
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

	
	
	
	
	END