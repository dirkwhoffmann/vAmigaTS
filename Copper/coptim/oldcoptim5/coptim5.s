	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
entry:

	lea 	CUSTOM,a6           ; Chipset base

	move	#$7fff,INTENA(a6)	; Disable all interrupts
	move.b  #$7F,$BFDD00        ; Disable CIA B interrupts
	move.b  #$7F,$BFED01        ; Disable CIA A interrupts
	
	move.w  #$8003,COPCON(a6)   ; Allow Copper to write Blitter registers
	lea	    copper1(pc),a0      ; Get pointer to first Copper list
	move.l	a0,COP1LC(a6)       ; Write pointer to Copper location register 1
	lea	    copper2(pc),a0      ; Get pointer to second Copper list
	move.l	a0,COP2LC(a6)       ; Write pointer to Copper location register 2
 	move.w  COPJMP1(a6),d0      ; Jump to the first Copper list
	
	move.w	#$0FFF,DMACON(a6)   ; Disable all DMA
	move.w	#$8280,DMACON(a6)   ; Enable Copper DMA

.mainLoop:
	bra.s	.mainLoop

copper1:

    ; Enable 0 bitplanes
	dc.w    BPLCON0, (0<<12)|$200

  	dc.w    $2F39, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000

    ;
    ; Perform some basic timing tests
	;

	dc.w	$31D9,$FFFE     ; WAIT 
	dc.w	$3101,$FFFE     ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w    COLOR00, $000

	dc.w	$33DB,$FFFE     ; WAIT 
	dc.w	$3303,$FFFE     ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w    COLOR00, $000

	dc.w	$35DD,$FFFE     ; WAIT 
	dc.w	$3503,$FFFE     ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w    COLOR00, $000

	dc.w	$37DF,$FFFE     ; WAIT 
	dc.w	$3703,$FFFE     ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0
	dc.w    COLOR00, $000

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe	

copper2:
	; dc.w    $4051,$FFFE    ; WAIT 
	dc.w	COLOR00, $0F0
	dc.w	COLOR00, $000

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe	
