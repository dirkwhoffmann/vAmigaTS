	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAAPRA             equ $BFE001	
CIABPRB             equ $BFD100	
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	
    ; Disable all bitplanes 
	; move.w #(4<<12)|$200,$DFF100
	move.w #$200,$DFF100

	; Disable all interrupts
	move.w  #$7FFF,$DFF09A

	; Disable entire DMA
	lea CUSTOM,a1
	move.w  #$7FFF,dmacon(a1)
		
	; Sync the CPU
	jsr synccpu

	; Some delay
	move.w  #$080,$DFF180
	move.w  #$800,$DFF180
	move.w  #$008,$DFF180
	move.w  #$080,$DFF180
	move.w  #$800,$DFF180
	move.w  #$008,$DFF180

	; Enter the color loop
	move.w  #$00F,d0
	move.w  #$FF0,d1
	lea     mainLoop(pc),a3	

mainLoop:
	move.w  d0,$DFF180
	ds.w    44,$4E71       ; NOPs
	btst    #1,d0          ; 6 cycles
	move.w  d1,$DFF180
	jmp     (a3)           ; 8 cycles

synccpu:
	lea     $DFF006,a3     ; VHPOSR
	andi.w  #$F,(a3)       ; 16 cycles
	bne     synccpu        ; 10 cycles
	move.w  #$008,$DFF180
synccpu2:
	andi.w  #$1F,(a3)      ; 16 cycles
	bne     synccpu2       ; 10 cycles
	move.w  #$800,$DFF180
synccpu3:
	andi.w  #$FF,(a3)      ; 16 cycles
	nop                    ;  4 cycles
	beq     synced         ; 10 cycles
	bra.s   synccpu3
synced:
	rts