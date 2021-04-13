	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
	include "ministartup.s"
		
; Constants
LVL3_INT_VECTOR		equ $6c
PAYLOAD             equ $003C    
	
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

	; Install interrupt handlers
	lea	irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	
	; Setup bitplane data
	lea bitplanes(pc),a0 
	move.w #51201,d0
.loop:
	move.b #$AA,(a0)+
	dbra d0,.loop

	; Setup colors
	move.w #$000,COLOR00(a1)
	move.w #$FF0,COLOR01(a1)

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable interrupts
	move.w  #$C020,INTENA(a1)
	
.mainLoop:
	bra.b	.mainLoop

irq3:

	movem.l	d0-a6,-(sp)
	move.w	#$3FFF,INTREQ(a1)	; Acknowledge
	lea     bitplanes(pc),a2
	lea     BPL1PTH(a1),a3
	move.l	a2,(a3)
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w    BPLCON1,$00
	dc.w    DDFSTRT,PAYLOAD ;    $0038
	dc.w	DDFSTOP,$00B0
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPL1MOD,$00 
	dc.w	BPL2MOD,$00
 
    ; 
	; Block 1 (LORES)
	;

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$200 ; 1 bitplanes, lores mode
	dc.w    COLOR01,$66F
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $3301,$FFFE  
	dc.w    BPLCON1,$0011

	dc.w	$3601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$36D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $3901,$FFFE  
	dc.w    BPLCON1,$0022

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$3CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $3F01,$FFFE  
	dc.w    BPLCON1,$0033

	dc.w	$4201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$42D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $4501,$FFFE  
	dc.w    BPLCON1,$0044

 	; 
	; Block 2 (LORES)
	;

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $4B01,$FFFE  
	dc.w    BPLCON1,$0055

	dc.w	$4E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$4ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $5101,$FFFE  
	dc.w    BPLCON1,$0066

	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$54D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $5701,$FFFE  
	dc.w    BPLCON1,$0077

	dc.w	$5A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$5AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $5D01,$FFFE  
	dc.w    BPLCON1,$0088

	; 
	; Block 3 (LORES)
	;

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $6301,$FFFE  
	dc.w    BPLCON1,$0099

	dc.w	$6601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$66D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $6901,$FFFE  
	dc.w    BPLCON1,$00AA

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$6CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $6F01,$FFFE  
	dc.w    BPLCON1,$00BB

	dc.w	$7201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$72D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $7501,$FFFE  
	dc.w    BPLCON1,$00CC

	; 
	; Block 4 (LORES)
	;

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $7B01,$FFFE  
	dc.w    BPLCON1,$00DD

	dc.w	$7E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$7ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $8101,$FFFE  
	dc.w    BPLCON1,$00EE

	dc.w	$8401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$84D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $8701,$FFFE  
	dc.w    BPLCON1,$00FF

	dc.w	$8A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$8AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $8D01,$FFFE  
	dc.w    BPLCON1,$0000

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$90D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off

	;
	; HIRES
	;

	dc.w    $9839, $FFFE         ; WAIT
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
	; Block 1 (HIRES)
	;

	dc.w	$A001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$8200 ; 1 bitplanes, hires mode
	dc.w    COLOR01,$66F
	dc.w	$A0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $A301,$FFFE  
	dc.w    BPLCON1,$0011

	dc.w	$A601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $A901,$FFFE  
	dc.w    BPLCON1,$0022

	dc.w	$AC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$ACD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $AF01,$FFFE  
	dc.w    BPLCON1,$0033

	dc.w	$B201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $B501,$FFFE  
	dc.w    BPLCON1,$0044

 	; 
	; Block 2 (HIRES)
	;

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	dc.w	$B8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $BB01,$FFFE  
	dc.w    BPLCON1,$0055

	dc.w	$BE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$BED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $C101,$FFFE  
	dc.w    BPLCON1,$0066

	dc.w	$C401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$C4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $C701,$FFFE  
	dc.w    BPLCON1,$0077

	dc.w	$CA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$CAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $CD01,$FFFE  
	dc.w    BPLCON1,$0088

	; 
	; Block 3 (HIRES)
	;

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $D301,$FFFE  
	dc.w    BPLCON1,$0099

	dc.w	$D601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$D6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $D901,$FFFE  
	dc.w    BPLCON1,$00AA

	dc.w	$DC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$DCD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $DF01,$FFFE  
	dc.w    BPLCON1,$00BB

	dc.w	$E201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$E2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $E501,$FFFE  
	dc.w    BPLCON1,$00CC

	; 
	; Block 4 (HIRES)
	;

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	dc.w	$E8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $EB01,$FFFE  
	dc.w    BPLCON1,$00DD

	dc.w	$EE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$EED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $F101,$FFFE  
	dc.w    BPLCON1,$00EE

	dc.w	$F401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$F4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $F701,$FFFE  
	dc.w    BPLCON1,$00FF

	dc.w	$FA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$FAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $FD01,$FFFE  
	dc.w    BPLCON1,$0000

	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.w	$0001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$00D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off
	dc.l	$fffffffe

bitplanes:
	ds.b    51201
	