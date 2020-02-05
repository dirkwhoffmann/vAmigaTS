	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
CIAA_ICR            equ $BFED01
CIAB_ICR            equ $BFDD00

;
; Main
;

entry:	
	; Load OCS base address into a1
	lea CUSTOM,a1
		
    ; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,CIAB_ICR     ; CIA B
	move.b  #$7F,CIAA_ICR     ; CIA A

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)

	; Disable all DMA
	move.w  #$7FFF,DMACON(a1)
		
	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable Copper DMA
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),DMACON(a1)

;
; Main loop
;

main: 
	; Wait until we have reached the middle of a frame
	lea     VHPOSR(a1),a3
.loop                       
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$0500,d2
	bne     .loop
	and     #1,VPOSR(a1)
	beq     .loop

	move.w  #$0,COPJMP1(a1)     ; Reenable Copper
	bra.s   main

;
; Copper
;

	copper:
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPL1MOD,$0 
	dc.w	BPL2MOD,$0

	dc.w    $2001, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w    $3001, $FFFE         ; WAIT
	dc.w    COLOR00,$000

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.w    $0000, $FFFE         ; Disable Copper by writing into a blocked register
	dc.w    COLOR00,$0FF       ; Should never be executed

