	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c

SCREEN_WIDTH	    equ 320
SCREEN_HEIGHT	  	equ 256
WIDTH_BYTES			equ (SCREEN_WIDTH/8)
BIT_DEPTH			equ 5
SCREEN_RES	        equ 8    ; lores
X_START	          	equ $81	
Y_START		        equ $2c
X_STOP		        equ X_START+SCREEN_WIDTH
Y_STOP		        equ Y_START+SCREEN_HEIGHT
	
BLIT_ABCD           equ $1   ; D only
BLIT_MINTERM        equ $CC  ; "Copy B"
BLIT_ROWS           equ 100
BLIT_COLS           equ 10

MAIN:	

	; Load OCS base address
	lea     CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Set up bitplane data
	lea     bitplanes(pc),a0 
	move.w  #51201,d0
.loop:
	move.b  #$0F,(a0)+
	dbra    d0,.loop

	; Set up colors
	move.w  #$000,COLOR00(a1)
	move.w  #$FF0,COLOR01(a1)

	; Set up canvas
	move.w  #(Y_START<<8)|X_START,DIWSTRT(a1)
	move.w	#((Y_STOP-256)<<8)|(X_STOP-256),DIWSTOP(a1)
	move.w	#(X_START/2-SCREEN_RES),DDFSTRT(a1)
	move.w	#(X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a1)

	; Install interrupt handlers
	lea	    irq3(pc),a2
 	move.l  a2,LVL3_INT_VECTOR

	; Install copper list
	lea     copper(pc),a0
	move.l  a0,COP1LC(a1)
	move.w  COPJMP1(a1),d2

	; Enable DMA
	move.w  #$8040,DMACON(a1)   ; Blitter
	move.w  #$8080,DMACON(a1)   ; Copper
	move.w  #$8100,DMACON(a1)   ; Bitplane
	move.w  #$8200,DMACON(a1)   ; EN

	; Enable innterrupts
	move.w  #$8020,INTENA(a1)   ; VBLANK
	move.w  #$C000,INTENA(a1)   ; EN
	
	; Prepare Blitter
	bsr     blitWait
	move.w  #(BLIT_ABCD<<8|BLIT_MINTERM),BLTCON0(a1)
	move.l  #$FFFFFFFF,BLTAFWM(a1)
	move.w  #0,BLTAMOD(a1)	        	; A modulo=bytes to skip between lines
	move.w  #0,BLTBMOD(a1)	        	; B modulo=bytes to skip between lines
	move.w  #0,BLTCMOD(a1)	            ; C modulo
	move.w  #20,BLTDMOD(a1)	            ; D modulo

	lea     bitplanes(pc),a2
	add.l   #2080,a2
	move.l  #0,BLTAPTH(a1)	
	move.l  #0,BLTBPTH(a1)	
	move.l  #0,BLTCPTH(a1)	
	move.l  a2,BLTDPTH(a1)

	; The actual test
	move.w  #$4000,BLTCON1(a1)
	move.w  #$0F0F,BLTBDAT(a1)
	move.w  #$0000,BLTCON1(a1)   ; Reset scroll value before Blitter starts
    
	; Perform Blit
	move.w  #(BLIT_ROWS<<6|BLIT_COLS),BLTSIZE(a1)

.mainLoop:
	bra.b   .mainLoop

blitWait:
	tst     DMACONR(a1)		;for compatibility
.waitblit:
	btst    #6,DMACONR(a1)
	bne.s   .waitblit
	rts

irq3:
	movem.l	d0-a6,-(sp)
	lea 	CUSTOM,a1
	move.w	#$3FFF,INTREQ(a1)	; Acknowledge
	lea     bitplanes(pc),a2
	lea     BPL1PTH(a1),a3
	move.l	a2,(a3)
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w	BPL1MOD,$0000
	dc.w	BPL2MOD,$0000
 
	dc.w	BPLCON0,(1<<12)|$200 ; 1 bitplanes, lores mode

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w    COLOR01,$F44

	dc.w	$C401,$FFFE  ; WAIT 
	dc.w    COLOR01,$8F8

	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.w	$00D9,$FFFE  ; WAIT 
	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off
	dc.l	$fffffffe

bitplanes:
	ds.b    51201
	