	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"
	
LVL3_INT_VECTOR		equ $6c

; THIS MEMORY AREA NEEDS TO BE FREE FOR THE TEST TO RUN
PT1                 equ $40000
PTH1                equ $4
PT2                 equ $50000
PTH2                equ $5
PTL                 equ $0000

MAIN:	
	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00 
	move.b  #$7F,$BFED01

	; Install interrupt handler
	lea	    irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	
	; Setup colors
	moveq   #30,d0
	lea     COLOR01(a1),a2 
.l0:
	move.w  #$88F,(a2)+
	dbra    d0,.l0

	; Setup bitplane data
	lea     PT1,a2
	move.w  #$FFFF,d0
.loop1:
	move.b  #$80,(a2)+
	dbra    d0,.loop1

	lea     PT2,a2 
	move.w  #$FFFF,d0
.loop2:
	move.b  #$FF,(a2)+
	dbra    d0,.loop2

	; Setup Copper
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 
	
	; Enable innterrupts
	move.w	#$C020,INTENA(a1) 

.mainLoop:
	bra.b	.mainLoop

irq3:

	movem.l	d0-a6,-(sp)
	lea 	CUSTOM,a1
	move.w	#$3FFF,INTREQ(a1)	; Acknowledge
	move.l  #PT1,BPL1PTH(a1)
	move.l  #PT1,BPL2PTH(a1)
	move.l  #PT1,BPL3PTH(a1)
	move.l  #PT1,BPL4PTH(a1)
	move.l  #PT1,BPL5PTH(a1)
	move.l  #PT1,BPL6PTH(a1)
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPL1MOD,160
	dc.w	BPL2MOD,160
 	dc.w    DDFSTRT,$0038
	dc.w	DDFSTOP,$00C0
	
    ; 
	; Block 1 (LORES)
	;

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(PLANES<<12)|$200 ; lores mode
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $3151,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$3601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$36D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $3751,$FFFE
	dc.w    TARGET,PTH1

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$3CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $3D53,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$4201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$42D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $4353,$FFFE
	dc.w    TARGET,PTH1

 	; 
	; Block 2 (LORES)
	;

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $4955,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$4E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$4ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $4F55,$FFFE
	dc.w    TARGET,PTH1

	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$54D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $5557,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$5A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$5AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $5B57,$FFFE
	dc.w    TARGET,PTH1

	; 
	; Block 3 (LORES)
	;

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6159,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$6601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$66D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6759,$FFFE
	dc.w    TARGET,PTH1

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$6CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6D5B,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$7201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$72D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $735B,$FFFE
	dc.w    TARGET,PTH1

	; 
	; Block 4 (LORES)
	;

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $795D,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$7E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$7ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $7F5D,$FFFE
	dc.w    TARGET,PTH1

	dc.w	$8401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$84D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $855F,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$8A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$8AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $8B5F,$FFFE
	dc.w    TARGET,PTH1

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
	dc.w	BPLCON0,(PLANES<<12)|$8200 ; hires mode
	dc.w	$A0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $A151,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$A601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $A751,$FFFE
	dc.w    TARGET,PTH1

	dc.w	$AC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$ACD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $AD53,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$B201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $B353,$FFFE
	dc.w    TARGET,PTH1

 	; 
	; Block 2 (HIRES)
	;

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $B955,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$BE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$BED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $BF55,$FFFE
	dc.w    TARGET,PTH1

	dc.w	$C401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$C4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $C557,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$CA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$CAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $CB57,$FFFE
	dc.w    TARGET,PTH1

	; 
	; Block 3 (HIRES)
	;

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $D159,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$D601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$D6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $D759,$FFFE
	dc.w    TARGET,PTH1

	dc.w	$DC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$DCD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $DD5B,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$E201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$E2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $E35B,$FFFE
	dc.w    TARGET,PTH1

	; 
	; Block 4 (HIRES)
	;

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$E8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $E95D,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$EE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$EED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $EF5D,$FFFE
	dc.w    TARGET,PTH1

	dc.w	$F401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$F4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $F55F,$FFFE
	dc.w    TARGET,PTH2

	dc.w	$FA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$FAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $FB5F,$FFFE
	dc.w    TARGET,PTH1

	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.w	$0001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$00D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off

	dc.l	$fffffffe
