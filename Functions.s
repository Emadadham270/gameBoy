    AREA    MYDATA, DATA, READWRITE

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

;--- TFT control-line masks ---
TFT_CS         EQU     (1 << 8)
TFT_DC         EQU     (1 << 9)
TFT_WR         EQU     (1 << 10)
TFT_RD         EQU     (1 << 11)
TFT_RST        EQU     (1 << 12)

;--- Colors ---
Black          EQU     0x0000
White          EQU     0xFFFF
	;XO_array:
    ;DCB     0x1A
    ;DCB     0x3F
    ;DCB     0x07

    AREA    CODEY, CODE, READONLY

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
    EXPORT  Draw_Result
    EXPORT  Update_Left_Sidebar


;------------------------
; SETUP
;------------------------
SETUP    FUNCTION
    PUSH    {R0-R2, LR}

    LDR     R0, =RCC_AHB1ENR
    LDR     R1, [R0]
    ORR     R1, R1, #1
    STR     R1, [R0]

    LDR     R0, =RCC_AHB1ENR
    LDR     R1, [R0]
    ORR     R1, R1, LSL #1
    STR     R1, [R0]

    LDR     R0, =RCC_AHB1ENR
    LDR     R1, [R0]
    ORR     R1, R1, LSL #2
    STR     R1, [R0]

    LDR     R0, =GPIOA_BASE
    LDR     R2, =0x55555555
    STR     R2, [R0]

    LDR     R0, =GPIOB_BASE
    MOV     R2, #0
    STR     R2, [R0]

    LDR     R0, =GPIOC_BASE
    LDR     R2, =0x55555555
    STR     R2, [R0]

    LDR     R0, =GPIOA_SPEEDR
    LDR     R2, =0xFFFFFFFF
    STR     R2, [R0]
    LDR     R0, =GPIOB_SPEEDR
    STR     R2, [R0]
    LDR     R0, =GPIOC_SPEEDR
    STR     R2, [R0]

    LDR     R0, =GPIOA_OTYPER
    MOV     R2, #0
    STR     R2, [R0]
    LDR     R0, =GPIOB_OTYPER
    STR     R2, [R0]
    LDR     R0, =GPIOC_OTYPER
    STR     R2, [R0]

    LDR     R0, =GPIOA_PUPDR
    LDR     R2, =0x55555555
    STR     R2, [R0]
    LDR     R0, =GPIOB_PUPDR
    STR     R2, [R0]
    LDR     R0, =GPIOC_PUPDR
    STR     R2, [R0]

    POP     {R0-R2, PC}
	ENDFUNC


;------------------------
; TFT_WriteCommand
;------------------------
TFT_WriteCommand FUNCTION
    PUSH    {R1-R2, LR}

    LDR     R1, =GPIOA_ODR
    LDR     R2, [R1]
    BIC     R2, R2, #TFT_CS
    STR     R2, [R1]

    BIC     R2, R2, #TFT_DC
    STR     R2, [R1]

    ORR     R2, R2, #TFT_RD
    STR     R2, [R1]

    BIC     R2, R2, #0xFF
    AND     R0, R0, #0xFF
    ORR     R2, R2, R0
    STR     R2, [R1]

    BIC     R2, R2, #TFT_WR
    STR     R2, [R1]
    ORR     R2, R2, #TFT_WR
    STR     R2, [R1]

    ORR     R2, R2, #TFT_CS
    STR     R2, [R1]

    POP     {R1-R2, PC}
	ENDFUNC


;------------------------
; TFT_WriteData
;------------------------
TFT_WriteData    FUNCTION
    PUSH    {R1-R2, LR}

    LDR     R1, =GPIOA_ODR
    LDR     R2, [R1]
    BIC     R2, R2, #TFT_CS
    STR     R2, [R1]

    ORR     R2, R2, #TFT_DC
    STR     R2, [R1]

    ORR     R2, R2, #TFT_RD
    STR     R2, [R1]

    BIC     R2, R2, #0xFF
    AND     R0, R0, #0xFF
    ORR     R2, R2, R0
    STR     R2, [R1]

    BIC     R2, R2, #TFT_WR
    STR     R2, [R1]
    ORR     R2, R2, #TFT_WR
    STR     R2, [R1]

    ORR     R2, R2, #TFT_CS
    STR     R2, [R1]

    POP     {R1-R2, PC}
    BX      LR
	ENDFUNC


;------------------------
; TFT_Init
;------------------------
TFT_Init    FUNCTION
    PUSH    {R0-R2, LR}

    LDR     R1, =GPIOA_ODR
    LDR     R2, [R1]
    BIC     R2, R2, #TFT_RST
    STR     R2, [R1]
    BL      delay

    ORR     R2, R2, #TFT_RST
    STR     R2, [R1]
    BL      delay

    MOV     R0, #0x3A
    BL      TFT_WriteCommand
    MOV     R0, #0x55
    BL      TFT_WriteData

    MOV     R0, #0xC5
    BL      TFT_WriteCommand
    MOV     R0, #0x54
    BL      TFT_WriteData
    MOV     R0, #0x00
    BL      TFT_WriteData

    MOV     R0, #0x36
    BL      TFT_WriteCommand
    MOV     R0, #0x08
    BL      TFT_WriteData

    MOV     R0, #0x11
    BL      TFT_WriteCommand
    BL      delay

    MOV     R0, #0x29
    BL      TFT_WriteCommand

    POP     {R0-R2, PC}
    BX      LR
	ENDFUNC


;------------------------
; TFT_DrawImage
;------------------------
TFT_DrawImage    FUNCTION
    PUSH    {R0,R4-R12, LR}

    LDR     R4, [R3], #4    ; width
    LDR     R5, [R3], #4    ; height

    MOV     R0, #0x2A
    BL      TFT_WriteCommand

    ; column start/end
    MOV     R0, R1, LSR #8
    BL      TFT_WriteData
    UXTB    R0, R1
    BL      TFT_WriteData
    ADD     R0, R1, R4
    SUB     R0, R0, #1
    MOV     R0, R0, LSR #8
    BL      TFT_WriteData
    ADD     R0, R1, R4
    SUB     R0, R0, #1
    BL      TFT_WriteData

    MOV     R0, #0x2B
    BL      TFT_WriteCommand

    ; page start/end
    MOV     R0, R2, LSR #8
    BL      TFT_WriteData
    UXTB    R0, R2
    BL      TFT_WriteData
    ADD     R0, R2, R5
    SUB     R0, R0, #1
    MOV     R0, R0, LSR #8
    BL      TFT_WriteData
    ADD     R0, R2, R5
    SUB     R0, R0, #1
    BL      TFT_WriteData

    MOV     R0, #0x2C
    BL      TFT_WriteCommand

    MUL     R6, R4, R5      ; pixel count

ImageLoop
    LDRH    R0, [R3], #2
    MOV     R1, R0, LSR #8
    AND     R2, R0, #0xFF
    MOV     R0, R1
    BL      TFT_WriteData
    MOV     R0, R2
    BL      TFT_WriteData
    SUBS    R6, R6, #1
    BNE     ImageLoop

    POP     {R0,R4-R12, PC}
    BX      LR
	ENDFUNC


;------------------------
; TFT_DrawGrid
;------------------------
TFT_DrawGrid    FUNCTION
    PUSH    {R0-R10, LR}

    MOV     R6, #0
    LDR     R7, =0x0139
    MOV     R8, #0
    LDR     R9, =0x01DE
    MOV     R0, #Black
    BL      TFT_Filldraw4INP

    MOV     R6, #2
    LDR     R7, =0x0137
    MOV     R8, #2
    LDR     R9, =0x0137
    LDR     R0, =White
    BL      TFT_Filldraw4INP

    MOV     R6, #0x62
    MOV     R7, #0x70
    MOV     R8, #2
    LDR     R9, =0x0137
    MOV     R0, #Black
    BL      TFT_Filldraw4INP

    MOV     R6, #0xD0
    MOV     R7, #0xDE
    MOV     R8, #2
    LDR     R9, =0x0137
    MOV     R0, #Black
    BL      TFT_Filldraw4INP

    MOV     R6, #2
    LDR     R7, =0x0137
    MOV     R8, #0x62
    MOV     R9, #0x70
    MOV     R0, #Black
    BL      TFT_Filldraw4INP

    MOV     R6, #2
    LDR     R7, =0x0137
    MOV     R8, #0xD0
    MOV     R9, #0xDE
    MOV     R0, #Black
    BL      TFT_Filldraw4INP

    ;...etc. (rest unchanged)...

    POP     {R0-R10, PC}
    BX      LR
	ENDFUNC


;------------------------
; TFT_Filldraw4INP
;------------------------
TFT_Filldraw4INP    FUNCTION
    PUSH    {R1-R5, LR}

    MOV     R5, R0

    MOV     R0, #0x2A
    BL      TFT_WriteCommand

    MOV     R10, R6, LSR #8
    MOV     R0, R10
    BL      TFT_WriteData
    MOV     R0, R6
    BL      TFT_WriteData

    MOV     R10, R7, LSR #8
    MOV     R0, R10
    BL      TFT_WriteData
    MOV     R0, R7
    BL      TFT_WriteData

    MOV     R0, #0x2B
    BL      TFT_WriteCommand

    MOV     R10, R8, LSR #8
    MOV     R0, R10
    BL      TFT_WriteData
    MOV     R0, R8
    BL      TFT_WriteData

    MOV     R10, R9, LSR #8
    MOV     R0, R10
    BL      TFT_WriteData
    MOV     R0, R9
    BL      TFT_WriteData

    MOV     R0, #0x2C
    BL      TFT_WriteCommand

    MOV     R1, R5, LSR #8
    AND     R2, R5, #0xFF

    LDR     R3, =153600
	
FillLoopdraw4INP
    MOV     R0, R1
    BL      TFT_WriteData
    MOV     R0, R2
    BL      TFT_WriteData
    SUBS    R3, R3, #1
    BNE     FillLoopdraw4INP

    POP     {R1-R5, PC}
    BX      LR
	ENDFUNC


;------------------------
; GET_state  (debounced)
;------------------------
GET_state    FUNCTION
    PUSH    {R0-R4, LR}

    MOV     R0, #25
    BL      delay

    LDR     R1, =GPIOB_IDR
    LDR     R1, [R1]

    MOV     R0, #50
    BL      delay
    LDR     R2, =GPIOB_IDR
    LDR     R2, [R2]

    BL      delay
    LDR     R3, =GPIOB_IDR
    LDR     R3, [R3]

    BL      delay
    LDR     R4, =GPIOB_IDR
    LDR     R4, [R4]

    AND     R1, R1, R2
    AND     R1, R1, R3
    AND     R1, R1, R4

    MOV     R10, R1

    POP     {R0-R4, PC}
	ENDFUNC


;------------------------
; delay
;------------------------
delay    FUNCTION
    PUSH    {R1, LR}
	LDR		R1,=INTERVAL
DelayInner_Loop
    SUBS    R1, R0
    CMP     R1, #0
    BGT     DelayInner_Loop
    POP     {R1, PC}
	ENDFUNC


;------------------------
; Draw_XO  (todo)
;------------------------
Draw_XO    FUNCTION
    PUSH    {LR}
    ;TODO
    POP     {PC}
	ENDFUNC


;------------------------
; Check_Win  (todo)
;------------------------
Check_Win    FUNCTION
    PUSH    {LR}
    ;TODO
    POP     {PC}
	ENDFUNC


;------------------------
; Draw_Result  (todo)
;------------------------
Draw_Result    FUNCTION
    PUSH    {LR}
    ;TODO
    POP     {PC}
	ENDFUNC


;------------------------
; Update_Left_Sidebar  (todo)
;------------------------
Update_Left_Sidebar    FUNCTION
    PUSH    {LR}
    ;TODO
    POP     {PC}
	ENDFUNC


    END