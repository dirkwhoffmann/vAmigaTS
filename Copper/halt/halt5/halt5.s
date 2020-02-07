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
	cmp.w   #$B000,d2
	bne     .loop
	and     #1,(a3)
	bne     .loop

	move.w  #$000,COLOR00(a1)
	move.w  #DMAF_COPPER,DMACON(a1)  ; Disable Copper DMA

	; Wait some more lines
.loop2                       
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$D000,d2
	bne     .loop2

	move.w  #(DMAF_SETCLR!DMAF_COPPER),DMACON(a1)  ; Disable Copper DMA

	bra.s   main

;
; Copper
;

	copper:
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPL1MOD,$0 
	dc.w	BPL2MOD,$0

	dc.w    $A001, $FFFE         ; WAIT
	dc.w    COLOR00,$00F
	dc.w    $0000, $0000         ; Halt Copper

	dc.w    $D001, $FFFE         ; WAIT
	dc.w    COLOR00,$00F
	dc.w    $E001, $FFFE         ; WAIT
	dc.w    COLOR00,$000

	dc.w	$ffdf,$fffe          ; Cross vertical boundary
	dc.w    COLOR00,$000

	dc.l	$fffffffe            ; Disable Copper by waiting for an invalid coordinate
