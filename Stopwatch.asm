.include "m64def.inc"

;====================================================================
; VARIABLES
;====================================================================

;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================
.org 0x0000
    rjmp Start
.org 0x000A
    rjmp ext_int4
.org 0x001E
    jmp timer0_com
.org 0x0050

;====================================================================
; CODE SEGMENT
;====================================================================

Start:
    ; Initialize stack pointer
    ldi R16, high(ramend)
    out sph, R16
    ldi R16, low(ramend)
    out spl, R16
    
    ; Enable external interrupt INT4
    ldi R16, 0x10
    out eimsk, R16 
    ; Configure interrupt type for INT4 (falling edge)
    ldi R16, 0x01
    out eicrB, R16
    
    ; Configure Timer0 for normal operation
    ldi R16, 0x0f       ; Clock source: CPU clock, normal mode
    out tccr0, R16
    ; Initialize Timer0 counter value
    ldi R16, 0x00
    out tcnt0, R16
    ; Set output compare value for Timer0
    ldi R16, 0x1f
    out ocr0, R16
    
    ; Configure ports D and E for output
    ldi R16, 0xff
    out ddrd, R16
    ldi R16, 0x0f
    out ddre, R16       
    
    ; Activate external crystal for Timer0
    ldi R16, 0x08
    out ASSR, R16
    
    ; Initialize loop counters
    ldi R20, 0x00
    ldi R19, 0x09
    ldi R21, 0x00
    ldi R22, 0x02
    
    ; Enable global interrupts
    SEI
    
    ; Infinite loop
Loop:
    rjmp  Loop
      
      
timer0_com:
    ; Output current stopwatch value
    out portd, R20
    out porte, R21
      
    ; Increment stopwatch counters
    inc R20
    cp R19, R20
    Brcc next1
    clr R20
    inc R21
    cp R19, R21
    Brcc next1
    clr R21
      
next1:     
    reti

ext_int4:
    ; Signal button press
    sbi portd, 6
   
    ; Toggle stopwatch mode
    mov R10, R21
    ldi R24, 1
    out porte, R24
   
    ; Stop Timer0
    ldi R16, 0x00
    out ASSR, R16
    ldi R16, 0x00
    out tccr0, R16
   
    ; Check stopwatch mode
    cpi R22, 1
    BREQ next2
    ; If not in stopwatch mode, reset timer and display value
    ldi R16, 0xc8
    out portd, R16
    dec R22
  
    reti

next2:    
    ; If in stopwatch mode, start Timer0
    sbi ddrd, 6
    sbi ddrd, 7 
   
    ldi R16, 0x0f
    out tccr0, R16
    ldi R16, 0x08
    out ASSR, R16
   
    sbi porta, 0    
    ldi R22, 0x02
   
    out porte, R24
   
    reti
