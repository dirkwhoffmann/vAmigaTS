	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

MAIN:	
	; Load OCS base address
	lea CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

    ; Setup test memory
	move.w  #$F00,COLOR00(a1)
	move.l  #7999,d0 
	lea     sourceA,a0
.initLoop:
	move.b  d0,(a0)+
	dbra	d0,.initLoop

	; Prepare the Blitter
	bsr.s   blitWait
	bsr.s 	prepareblit  

    ; Run the Blitter
	move.w  #$8240,DMACON(a1)
	move.l  #$0FF00880,d2
	move.l  #$FF,d0 
	move.w  #$5F00,d3               ; Current BPLCON0 value
.blitterLoop:
	move.w  d2,COLOR00(a1)
	swap    d2
	bsr.s   blitWait 	            ; Wait until the Blitter is ready
	move.w  d3,BLTCON0(a1)          ; Select channels and minterms
	addq    #1,d3
	move.w  #(2)<<6|(2),BLTSIZE(a1) ; Start the Blitter
	dbra	d0,.blitterLoop

	move.w  #$0F0,COLOR00(a1)
.done:
	bra.s	.done

blitWait:
	tst     DMACONR(a1)	         	; for compatibility
.waitblit:
	btst    #6,DMACONR(a1)
	bne.s   .waitblit
	rts

waitBlitIdle:
	btst    #14,DMACONR(a1)
	bne.s   waitBlitIdle
	rts
	
prepareblit:	
	movem.l d0-a6,-(sp)
	lea CUSTOM,a1
	move.w #$10,BLTCON1(a1)           ; Exclusive fill
	move.l #$ffaa,BLTAFWM(a1)
	move.l #$affc,BLTALWM(a1)
	move.w #0,BLTAMOD(a1)	        	
	move.w #0,BLTBMOD(a1)	        	
	move.w #0,BLTCMOD(a1)	           
	move.w #0,BLTDMOD(a1)	          
	lea    sourceA,a0   
	move.l a0,BLTAPTH(a1)
	lea    sourceB,a0   
	move.l a0,BLTBPTH(a1)	
	lea    sourceC,a0   
	move.l a0,BLTCPTH(a1)	
	lea    destD,a0   
	move.l a0,BLTDPTH(a1)
	movem.l (sp)+,d0-a6
	rts

sourceA:
	ds.b    2200,$00
sourceB:
	ds.b    2200,$00
sourceC:
	ds.b    2200,$00
destD:
	ds.b    2200,$00
