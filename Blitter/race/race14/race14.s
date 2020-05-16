	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

BLIT_ABCD           equ 14

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR	    equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
	
BLIT_LF_MINTERM		equ $ca
BLIT_A_SOURCE_SHIFT	equ 0
BLIT_DEST		    equ $100
BLIT_SRCC	    	equ $200
BLIT_SRCB	    	equ $400
BLIT_SRCA	    	equ $800
BLIT_ASHIFTSHIFT	equ 12
BLIT_BLTCON1		equ 0

MAIN:	
	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable interrupts and DMA
	move.b  #$7F,$BFDD00        ; CIA B
	move.b  #$7F,$BFED01        ; CIA A
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)

	; Disable all bitplanes 
	move.w  #$200,BPLCON0(a1)

	; Install interrupt handlers
	lea	    irq1(pc),a2
 	move.l	a2,LVL1_INT_VECTOR
	lea	    irq3(pc),a2
 	move.l	a2,LVL3_INT_VECTOR

	; Install copper list
	lea    	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #$8003,COPCON(a1)   ; Allow Copper to write Blitter registers

	bsr.s 	prepareblit         ; Prepare the Blitter

	; Enable DMA
	move.w  #$8080,DMACON(a1)   ; Copper
	move.w  #$8040,DMACON(a1)   ; Blitter
	move.w  #$8200,DMACON(a1)   ; General enable

	; Enable innterrupts
	move.w	#$C044,INTENA(a1) 

.mainLoop:
	bra.s	.mainLoop

blitWait:
	tst DMACONR(a1)		;for compatibility
.waitblit:
	btst #6,DMACONR(a1)
	bne.s .waitblit
	rts

waitBlitIdle:
	btst #14,DMACONR(a1)
	bne.s waitBlitIdle
	rts
	
prepareblit:	
	bsr blitWait
	move.w #(BLIT_ABCD<<8|BLIT_LF_MINTERM|BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT),BLTCON0(a1)
	move.w #BLIT_BLTCON1,BLTCON1(a1) 
	move.l #0,BLTAFWM(a1)   	
	move.w #0,BLTAMOD(a1)	        
	move.w #0,BLTBMOD(a1)	        
	move.w #0,BLTCMOD(a1)	        
	move.w #0,BLTDMOD(a1)	        
	move.l #spare,BLTAPTH(a1)	
	move.l #spare,BLTBPTH(a1)	    
	move.l #spare,BLTCPTH(a1)
	move.l #spare,BLTDPTH(a1)
	rts

cpuloop1:
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 

	move.w  #$888,$DFF180 
	rts

cpuloop2:
  	moveq #40,d2
.loop:
	move.w  #$44F,$DFF180 
	move.w  #$FF0,$DFF180 
    dbra d2,.loop

	move.w  #$888,$DFF180 
	rts

cpuloop3:
  	moveq #40,d2
.loop:
	move.b  #$FF,$DFF180 
	move.b  #$00,$DFF180 
    dbra d2,.loop

	move.w  #$888,$DFF180 
	rts

cpuloop4:
  	moveq #40,d2
.loop:
	move.w  #$44F,$DFF180 
	btst    #1,d0                     ; Consume cycles
	move.w  #$FF0,$DFF180 
    dbra d2,.loop

	move.w  #$888,$DFF180 
	rts

irq1:
	move.w  #$0004,INTREQ(a1)         ; Acknowledge	
	jsr     prepareblit 
	move.w  #$44F,COLOR00(a1)
	move.w  #(50)<<6|(50),BLTSIZE(a1) ; Do Blit
	jsr     cpuloop1
	jsr     cpuloop2
	jsr     cpuloop3
	jsr     cpuloop4
	rte

irq3:                                 ; Called when the Blitter terminates
	move.w  #$0040,INTREQ(a1)         ; Acknowledge
	move.w  #$000,COLOR00(a1)
	rte

copper:

    ; All bitplanes off
	dc.w    BPLCON0, (0<<12)|$200

  	dc.w    $1F39, $FFFE         ; WAIT
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

	; Perform first blit
	dc.w    DMACON,$8400            ; BLTPRI on
	dc.w	$3039,$FFFE             ; Wait 
	dc.w	COLOR00, $44F	
	dc.w    INTREQ, $8004           ; IRQ
	dc.w    $3401,$7FFE             ; Wait for the Blitter (Blit has not yet started)
	dc.w	COLOR00, $F00	

	; Perform second blit
	dc.w    DMACON,$0400            ; BLTPRI off
	dc.w	$9039,$FFFE             ; Wait 
	dc.w	COLOR00, $44F	
	dc.w    INTREQ, $8004           ; IRQ
	dc.w    $9401,$7FFE             ; Wait for the Blitter (Blit has not yet started)
	dc.w	COLOR00, $F00	

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 
	dc.w	COLOR00, $000	

	dc.l    $fffffffe	

bitplanes:
	ds.b    51200,$00

spare:
	ds.b    1280,$00
