	include "../../../include/registers.i"
	include "../../../include/ministartup.i"

LENGTH		equ (11<<6)|1
PATTERN     equ $FFFF
OFFSET      equ 6*40
SKIP        equ 3*40
MAIN:

	; Load OCS base address
	lea     CUSTOM,a1
	lea     CUSTOM,a6

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Setup bitplane pointers
	lea     bitplanes(pc),a2
	lea     copper(pc),a3
	moveq	#5,d0
.bitplaneloop:
	move.l 	a2,d1
	move.w	d1,2(a3)
	swap	d1
	move.w  d1,6(a3)
	addq	#8,a3
	dbra	d0,.bitplaneloop
	
	; Prepare test data
	lea     bitplanes,a2
	moveq	#$05,d0
.loop:
	move.w 	#$FFFF,(a2)+
	move.w 	#$0000,(a2)+
	dbra	d0,.loop

	; Install copper list
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8040,DMACON(a1)   ; Blitter DMA 	
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 
	move.w	#$8400,DMACON(a1)   ; BlitPri = 1 

	; Run the test
	bsr     runtest

.mainloop:
	jmp     .mainloop

runtest:

	;
	; Section 1
	; 

	; Copy blit 1
	bsr     blitWait
	move.w  #0,BLTAMOD(a1)
	move.w  #0,BLTBMOD(a1)
	move.w  #0,BLTCMOD(a1)
	move.w  #0,BLTDMOD(a1)
	move.l  #$ffffffff,BLTAFWM(a1)
	move.l  #bitplanes+1*40,BLTAPTH(a1)
	move.l  #bitplanes+1*40,BLTBPTH(a1)
	move.l  #bitplanes+1*40,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET,BLTDPTH(a1)
	move.w  #$71CC,BLTCON0(a1)                ; ASH = 7, USE = D, MINTERM = B
	move.w  #$0000,BLTCON1(a1)                ; Set BSH
	move.w  #$3333,BLTBDAT(a1)                ; Run Barrel shifter (sets BOLD)
	move.w  #$8000,BLTCON1(a1)                ; Set BSH
	move.w  #$FFFF,BLTBDAT(a1)                ; Run Barrel shifter (sets BHOLD)
	move.w  #LENGTH,BLTSIZE(a1)

	; Copy blit 2
	bsr     blitWait
	move.l  #bitplanes+OFFSET+1*SKIP,BLTDPTH(a1)
	move.w  #LENGTH,BLTSIZE(a1)               ; BHOLD is unchanged

	; Copy blit 3
	bsr     blitWait
	move.l  #bitplanes+OFFSET+2*SKIP,BLTDPTH(a1)
	move.w  #$FFFF,BLTBDAT(a1)                ; BOLD is zero now
	move.w  #LENGTH,BLTSIZE(a1)

	; Copy blit 4
	bsr     blitWait
	move.l  #bitplanes+OFFSET+3*SKIP,BLTDPTH(a1)
	move.w  #$8000,BLTCON1(a1)                ; Set BSH
	move.w  #$33AA,BLTBDAT(a1)                ; Run Barrel shifter (sets BOLD)
	move.w  #$8000,BLTCON1(a1)                ; Set BSH
	move.w  #$FFCC,BLTBDAT(a1)                ; Run Barrel shifter (sets BHOLD)
	move.w  #LENGTH,BLTSIZE(a1)

	; Copy blit 5
	bsr     blitWait
	move.l  #bitplanes+OFFSET+4*SKIP,BLTDPTH(a1)
	move.w  #$8000,BLTCON1(a1)                ; Set BSH
	move.w  #$AA33,BLTBDAT(a1)                ; Run Barrel shifter (sets BOLD)
	move.w  #$FFCC,BLTBDAT(a1)                ; Run Barrel shifter (sets BHOLD)
	move.w  #LENGTH,BLTSIZE(a1)

	; Copy blit 6
	bsr     blitWait
	move.l  #bitplanes+OFFSET+5*SKIP,BLTDPTH(a1)
	move.w  #$8000,BLTCON1(a1)                ; BSH = 8
	move.w  #$FFAA,BLTBDAT(a1)
	move.w  #LENGTH,BLTSIZE(a1)

	; Copy blit 7
	bsr     blitWait
	move.l  #bitplanes+OFFSET+6*SKIP,BLTDPTH(a1)
	move.w  #$0000,BLTCON1(a1)                ; Set BSH
	move.w  #$3333,BLTBDAT(a1)                ; Run Barrel shifter (sets BOLD)
	move.w  #$4000,BLTCON1(a1)                ; Set BSH
	move.w  #$FFCC,BLTBDAT(a1)                ; Run Barrel shifter (sets BHOLD)
	move.w  #LENGTH,BLTSIZE(a1)

	; Copy blit 8
	bsr     blitWait
	move.l  #bitplanes+OFFSET+7*SKIP+20,BLTDPTH(a1)
	move.w  #$0002,BLTCON1(a1)                ; Set BSH + Descending mode
	move.w  #$3333,BLTBDAT(a1)                ; Run Barrel shifter (sets BOLD)
	move.w  #$4002,BLTCON1(a1)                ; Set BSH + Descending mode
	move.w  #$FFCC,BLTBDAT(a1)                ; Run Barrel shifter (sets BHOLD)
	move.w  #LENGTH,BLTSIZE(a1)

	;
	; Section 2
	; 

	; Line blit 1
	bsr     blitWait
	move.w  #40,BLTCMOD(a1)
	move.w  #40,BLTDMOD(a1)
	move.w  #-100,BLTAPTL(a1)
	move.w  #-200,BLTAMOD(a1)
	move.w  #0,BLTBMOD(a1)
	move.w  #$0BCA,BLTCON0(a1)
	move.l  #$FFFFFFFF,BLTAFWM(a1)
	move.w  #$8000,BLTADAT(a1)
	move.l  #bitplanes+OFFSET+9*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+9*SKIP,BLTDPTH(a1)
	move.w  #$0051,BLTCON1(a1)  
	move.w  #$3333,BLTBDAT(a1)  
	move.w  #$8051,BLTCON1(a1)  
	move.w  #$FFFF,BLTBDAT(a1)
	move.w  #$2C02,BLTSIZE(a1)

	; Line blit 2
	bsr     blitWait
	move.l  #bitplanes+OFFSET+10*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+10*SKIP,BLTDPTH(a1)	
	move.w  #$2C02,BLTSIZE(a1)

	; Line blit 3
	bsr     blitWait
	move.l  #bitplanes+OFFSET+11*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+11*SKIP,BLTDPTH(a1)	
	move.w  #$FFFF,BLTBDAT(a1)                ; BOLD is zero now
	move.w  #$2C02,BLTSIZE(a1)

	; Line blit 4
	bsr     blitWait
	move.l  #bitplanes+OFFSET+12*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+12*SKIP,BLTDPTH(a1)	
	move.w  #$8051,BLTCON1(a1)   
	move.w  #$33AA,BLTBDAT(a1)   
	move.w  #$8051,BLTCON1(a1)   
	move.w  #$FFCC,BLTBDAT(a1)   
	move.w  #$2C02,BLTSIZE(a1)

	; Line blit 5
	bsr     blitWait
	move.l  #bitplanes+OFFSET+13*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+13*SKIP,BLTDPTH(a1)	
	move.w  #$8051,BLTCON1(a1)      
	move.w  #$AA33,BLTBDAT(a1)      
	move.w  #$FFCC,BLTBDAT(a1)      
	move.w  #$2C02,BLTSIZE(a1)

	; Line blit 6
	bsr     blitWait
	move.l  #bitplanes+OFFSET+14*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+14*SKIP,BLTDPTH(a1)	
	move.w  #$8051,BLTCON1(a1) 
	move.w  #$FFAA,BLTBDAT(a1)
	move.w  #$2C02,BLTSIZE(a1)

	; Line blit 7
	bsr     blitWait
	move.l  #bitplanes+OFFSET+15*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+15*SKIP,BLTDPTH(a1)	
	move.w  #$0051,BLTCON1(a1)  
	move.w  #$3333,BLTBDAT(a1)  
	move.w  #$4051,BLTCON1(a1)  
	move.w  #$FFCC,BLTBDAT(a1)  
	move.w  #$2C02,BLTSIZE(a1)

	; Line blit 8
	bsr     blitWait
	move.l  #bitplanes+OFFSET+16*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+16*SKIP,BLTDPTH(a1)	
	move.w  #$4051,BLTCON1(a1)     
	move.w  #$3333,BLTBDAT(a1)     
	move.w  #$0051,BLTCON1(a1)     
	move.w  #$FFCC,BLTBDAT(a1)     
	move.w  #$2C02,BLTSIZE(a1)

	;
	; Section 3
	; 

	; Copy blit 9
	bsr     blitWait
	move.w  #0,BLTAMOD(a1)
	move.w  #0,BLTBMOD(a1)
	move.w  #0,BLTCMOD(a1)
	move.w  #0,BLTDMOD(a1)
	move.l  #$ffffffff,BLTAFWM(a1)
	move.l  #bitplanes+1*40,BLTAPTH(a1)
	move.l  #bitplanes+1*40,BLTBPTH(a1)
	move.l  #bitplanes+1*40,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+18*SKIP,BLTDPTH(a1)
	move.w  #$0000,BLTCON1(a1)         
	move.w  #$01F0,BLTCON0(a1)                ; ASH = 0, USE = D, MINTERM = A
	move.w  #$3333,BLTADAT(a1)         
	move.w  #$81F0,BLTCON0(a1)         
	move.w  #$F0F0,BLTADAT(a1)         
	move.w  #LENGTH,BLTSIZE(a1)

	; Copy blit 10
	bsr     blitWait
	move.l  #bitplanes+OFFSET+19*SKIP,BLTDPTH(a1)
	move.w  #LENGTH,BLTSIZE(a1)      

	; Copy blit 11
	bsr     blitWait
	move.l  #bitplanes+OFFSET+20*SKIP,BLTDPTH(a1)
	move.w  #$FFFF,BLTADAT(a1)       
	move.w  #LENGTH,BLTSIZE(a1)

	; Copy blit 12
	bsr     blitWait
	move.l  #bitplanes+OFFSET+21*SKIP,BLTDPTH(a1)
	move.w  #$81F0,BLTCON0(a1)         
	move.w  #$33AA,BLTADAT(a1)       
	move.w  #$81F0,BLTCON0(a1)         
	move.w  #$FFCC,BLTADAT(a1)       
	move.w  #LENGTH,BLTSIZE(a1)

	; Copy blit 13
	bsr     blitWait
	move.l  #bitplanes+OFFSET+22*SKIP,BLTDPTH(a1)
	move.w  #$81F0,BLTCON0(a1)         
	move.w  #$AA33,BLTADAT(a1) 
	move.w  #$FFCC,BLTADAT(a1) 
	move.w  #LENGTH,BLTSIZE(a1)

	; Copy blit 14
	bsr     blitWait
	move.l  #bitplanes+OFFSET+23*SKIP,BLTDPTH(a1)
	move.w  #$81F0,BLTCON0(a1)         
	move.w  #$FFAA,BLTADAT(a1)
	move.w  #LENGTH,BLTSIZE(a1)

	; Copy blit 15
	bsr     blitWait
	move.l  #bitplanes+OFFSET+24*SKIP,BLTDPTH(a1)
	move.w  #$01F0,BLTCON0(a1)         
	move.w  #$3333,BLTADAT(a1)        
	move.w  #$41F0,BLTCON0(a1)         
	move.w  #$FFCC,BLTADAT(a1)        
	move.w  #LENGTH,BLTSIZE(a1)

	; Copy blit 16
	bsr     blitWait
	move.l  #bitplanes+OFFSET+25*SKIP+20,BLTDPTH(a1)
	move.w  #$0002,BLTCON1(a1)   
	move.w  #$01F0,BLTCON0(a1)         
	move.w  #$3333,BLTADAT(a1)    
	move.w  #$41F0,BLTCON0(a1)         
	move.w  #$FFCC,BLTADAT(a1)    
	move.w  #LENGTH,BLTSIZE(a1)

	;
	; Section 4
	; 

	; Line blit 9
	bsr     blitWait
	move.w  #40,BLTCMOD(a1)
	move.w  #40,BLTDMOD(a1)
	move.w  #-100,BLTAPTL(a1)
	move.w  #-200,BLTAMOD(a1)
	move.w  #0,BLTBMOD(a1)
	move.l  #$FFFFFFFF,BLTAFWM(a1)
	move.w  #$8000,BLTADAT(a1)
	move.w  #$FFFF,BLTBDAT(a1)    
	move.l  #bitplanes+OFFSET+27*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+27*SKIP,BLTDPTH(a1)
	move.w  #$0051,BLTCON1(a1)         
	move.w  #$0BF0,BLTCON0(a1)         
	move.w  #$3333,BLTADAT(a1)         
	move.w  #$8BF0,BLTCON0(a1)         
	move.w  #$F0F0,BLTADAT(a1)     
	move.w  #$2C02,BLTSIZE(a1)
	
	; Line blit 10
	bsr     blitWait
	move.l  #bitplanes+OFFSET+28*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+28*SKIP,BLTDPTH(a1)
	move.w  #$2C02,BLTSIZE(a1)      

	; Line blit 11
	bsr     blitWait
	move.l  #bitplanes+OFFSET+29*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+29*SKIP,BLTDPTH(a1)
	move.w  #$FFFF,BLTADAT(a1)       
	move.w  #$2C02,BLTSIZE(a1)

	; Line blit 12
	bsr     blitWait
	move.l  #bitplanes+OFFSET+30*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+30*SKIP,BLTDPTH(a1)
	move.w  #$8BF0,BLTCON0(a1)         
	move.w  #$33AA,BLTADAT(a1)       
	move.w  #$8BF0,BLTCON0(a1)         
	move.w  #$FFCC,BLTADAT(a1)       
	move.w  #$2C02,BLTSIZE(a1)

	; Line blit 13
	bsr     blitWait
	move.l  #bitplanes+OFFSET+31*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+31*SKIP,BLTDPTH(a1)
	move.w  #$8BF0,BLTCON0(a1)         
	move.w  #$AA33,BLTADAT(a1) 
	move.w  #$FFCC,BLTADAT(a1) 
	move.w  #$2C02,BLTSIZE(a1)

	; Line blit 14
	bsr     blitWait
	move.l  #bitplanes+OFFSET+32*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+32*SKIP,BLTDPTH(a1)
	move.w  #$8BF0,BLTCON0(a1)         
	move.w  #$FFAA,BLTADAT(a1)
	move.w  #$2C02,BLTSIZE(a1)

	; Line blit 15
	bsr     blitWait
	move.l  #bitplanes+OFFSET+33*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+33*SKIP,BLTDPTH(a1)
	move.w  #$0BF0,BLTCON0(a1)         
	move.w  #$3333,BLTADAT(a1)        
	move.w  #$4BF0,BLTCON0(a1)         
	move.w  #$FFCC,BLTADAT(a1)        
	move.w  #$2C02,BLTSIZE(a1)

	; Line blit 16
	bsr     blitWait
	move.l  #bitplanes+OFFSET+34*SKIP,BLTCPTH(a1)
	move.l  #bitplanes+OFFSET+34*SKIP,BLTDPTH(a1)
	move.w  #$4BF0,BLTCON0(a1)         
	move.w  #$3333,BLTADAT(a1)    
	move.w  #$0BF0,BLTCON0(a1)         
	move.w  #$FFCC,BLTADAT(a1)    
	move.w  #$2C02,BLTSIZE(a1)

	rts

blitWait:
	tst DMACONR(a1)		;for compatibility
.waitblit:
	btst #6,DMACONR(a1)
	bne.s .waitblit
	rts

copper:
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0

	dc.w	BPLCON0,(1<<12)|$200 
	dc.w    DDFSTRT,$38
	dc.w    DDFSTOP,$D0
	dc.w    COLOR01,$FFF

	dc.w    $2F39, $FFFE         ; WAIT
	include "copperline.i"

	dc.w    $4A39, $FFFE         ; WAIT
	include "copperline.i"

	dc.w    $6539, $FFFE         ; WAIT
	include "copperline.i"

	dc.w    $8039, $FFFE         ; WAIT
	include "copperline.i"

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe

bitplanes:
	ds.b    61440,$00
	