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
		

colorLoop:

	; Sync the CPU
	jsr synccpu

	move.w  #$888,$DFF180
	move.w  #$000,$DFF180
	move.w  #$FFF,$DFF180
	bra.s colorLoop

synccpu:
	; Sync horizontally
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

	; Sync vertically
	move.w  #$00F,d0
	move.w  #$FF0,d1
	ds.w    24,$4E71       ; NOPs

hsyncloop:
	nop
	;ds.w    36,$4E71       ; NOPs
	move.w  d0,$DFF180
	ds.w    96,$4E71       ; NOPs
	move.w  (a3),d2       
	;swap    d2
	move.w  d1,$DFF180
	and     #$FF00,d2
	cmp.w   #$6000,d2
	bne     hsyncloop
	rts