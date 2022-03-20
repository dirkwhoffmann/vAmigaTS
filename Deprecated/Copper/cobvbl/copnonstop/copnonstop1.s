	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

MAIN:
	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable DMA
	move.w  #$7FFF,DMACON(a1)

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w  #$8080,DMACON(a1)    ; Copper DMA
	move.w  #$8200,DMACON(a1)    ; DMA enable

;
; Main loop
;

main: 
	bra     main

copper:

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 
	dc.w    COLOR00,$000

	dc.w    $3839,$FFFE ; WAIT
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$600
	dc.w    COLOR00,$060
	dc.w    COLOR00,$006
	dc.w    COLOR00,$660
	dc.w    COLOR00,$066
	dc.w    COLOR00,$606

	dc.w    COLOR00,$F00
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$600
	dc.w    COLOR00,$060
	dc.w    COLOR00,$006
	dc.w    COLOR00,$660
	dc.w    COLOR00,$066
	dc.w    COLOR00,$606

	dc.w    COLOR00,$F00
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$600
	dc.w    COLOR00,$060
	dc.w    COLOR00,$006
	dc.w    COLOR00,$660
	dc.w    COLOR00,$066
	dc.w    COLOR00,$606

	dc.w    COLOR00,$F00
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$600
	dc.w    COLOR00,$060
	dc.w    COLOR00,$006
	dc.w    COLOR00,$660
	dc.w    COLOR00,$066
	dc.w    COLOR00,$606

	dc.w    COLOR00,$F00
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$600
	dc.w    COLOR00,$060
	dc.w    COLOR00,$006
	dc.w    COLOR00,$660
	dc.w    COLOR00,$066
	dc.w    COLOR00,$606

	dc.w    COLOR00,$F00
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$600
	dc.w    COLOR00,$060
	dc.w    COLOR00,$006
	dc.w    COLOR00,$660
	dc.w    COLOR00,$066
	dc.w    COLOR00,$606

	dc.w    COLOR00,$F00
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$600
	dc.w    COLOR00,$060
	dc.w    COLOR00,$006
	dc.w    COLOR00,$660
	dc.w    COLOR00,$066
	dc.w    COLOR00,$606

	dc.w    COLOR00,$F00
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$600
	dc.w    COLOR00,$060
	dc.w    COLOR00,$006
	dc.w    COLOR00,$660
	dc.w    COLOR00,$066
	dc.w    COLOR00,$606

	dc.w    COLOR00,$000
	dc.l    $fffffffe	
