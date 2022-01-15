	include "../../../include/registers.i"
	include "../../../include/ministartup.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
LEFT                equ $80
RIGHT               equ $b0

RULER	MACRO
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	ENDM

MAIN:
	; Load OCS base address
	lea     CUSTOM,a1
	
	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$0200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01

	; Install interrupt handlers
	lea	    irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	; Setup Copper
	lea	    copper,a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	
	; Setup Copper
	lea	    copper,a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Setup bitplane data
	lea 	bitplanes(pc),a0 
	move.w 	#4096,d0
	move.l  #$AAAAAAAA,d1
.loop:
	move.l 	d1,(a0)+
	dbra 	d0,.loop

	; Setup colors
	move.w 	#$000,COLOR00(a1)
	move.w 	#$FF0,COLOR01(a1)
	
	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable interrupts
	move.w	#$C020,INTENA(a1)

.mainLoop:
	bra.b	.mainLoop

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
	dc.w    DIWSTRT,$2c81 
	dc.w	DIWSTOP,$2cc7
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES

	;
	; Round 1
	; 

	dc.w	$7D01,$FFFE  ; WAIT 
 	dc.w	BPLCON0,(1<<12)|$200
	dc.w    COLOR01,$B6F
	dc.w    DIWSTRT,$7881 
	dc.w	DIWSTOP,$2cc7

	dc.w	$8061,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$80c7          ; Close DIW

	dc.w	$8239,$FFFE  ; WAIT 
    RULER

	dc.w	$8461,$FFFE  ; WAIT 
	dc.w	DIWSTRT,$8481          ; Open DIW

	dc.w	$8671,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$86c7          ; Close DIW
	dc.w	DIWSTRT,$8681          ; Does not open, because vstop matches

	dc.w	$8839,$FFFE  ; WAIT 
    RULER
  
  	dc.w	$8A61,$FFFE  ; WAIT 
	dc.w	DIWSTRT,$8A81          ; Open DIW

  	dc.w	$8C81,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$8Bc7          ; Does not close, because vpos is too small
	; dc.w	DIWSTRT,$8C81          ; Open DIW

	dc.w	$9291,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$92c7          ; Close DIW
	dc.w	DIWSTRT,$9281          ; Does not open, because vstop matches
	dc.w	$92B1,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$91c7          ; DIW opens, because vstop no longer matches

	dc.w    $9401,$FFFE 
	dc.w	BPLCON0,(0<<12)|$200
	dc.w    $9539,$FFFE 
	RULER
	dc.w    DDFSTRT,$0018 
	dc.w	DDFSTOP,$00E0

	;
	; Round 2
	; 
	
	dc.w	$AD01,$FFFE  ; WAIT 
 	dc.w	BPLCON0,(1<<12)|$200
	dc.w    COLOR01,$F6F
	dc.w    DIWSTRT,$7881 
	dc.w	DIWSTOP,$2cc7

	dc.w	$B063,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$B0c7          ; Close DIW

	dc.w	$B239,$FFFE  ; WAIT 
    RULER

	dc.w	$B463,$FFFE  ; WAIT 
	dc.w	DIWSTRT,$B481          ; Open DIW

	dc.w	$B673,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$B6c7          ; Close DIW
	dc.w	DIWSTRT,$B681          ; Does not open, because vstop matches

	dc.w	$B839,$FFFE  ; WAIT 
    RULER
  
  	dc.w	$BA63,$FFFE  ; WAIT 
	dc.w	DIWSTRT,$BA81          ; Open DIW

  	dc.w	$BC83,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$BBc7          ; Does not close, because vpos is too small
	; dc.w	DIWSTRT,$BC81          ; Open DIW

	dc.w	$C293,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$C2c7          ; Close DIW
	dc.w	DIWSTRT,$C281          ; Does not open, because vstop matches
	dc.w	$C2B3,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$C1c7          ; DIW opens, because vstop no longer matches

	dc.w    $C401,$FFFE 
	dc.w	BPLCON0,(0<<12)|$200
	dc.w    $C539,$FFFE 
	RULER
	dc.w    DDFSTRT,$0018 
	dc.w	DDFSTOP,$00E0

	;
	; Round 3
	; 

	dc.w	$DD01,$FFFE  ; WAIT 
 	dc.w	BPLCON0,(1<<12)|$200
	dc.w    COLOR01,$66F
	dc.w    DIWSTRT,$4881 
	dc.w	DIWSTOP,$4cc7

	dc.w	$E061,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$E0c7          ; Close DIW

	dc.w	$E239,$FFFE  ; WAIT 
    RULER

	dc.w	$E45F,$FFFE  ; WAIT 
	dc.w	DIWSTRT,$E481          ; Open DIW

	dc.w	$E66F,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$E6c7          ; Close DIW
	dc.w	DIWSTRT,$E681          ; Does not open, because vstop matches

	dc.w	$E839,$FFFE  ; WAIT 
    RULER
  
  	dc.w	$EA5F,$FFFE  ; WAIT 
	dc.w	DIWSTRT,$EA81          ; Open DIW

  	dc.w	$EC7F,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$EBc7          ; Does not close, because vpos is too small
	; dc.w	DIWSTRT,$EC81          ; Open DIW

	dc.w	$F28F,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$F2c7          ; Close DIW
	dc.w	DIWSTRT,$F281          ; Does not open, because vstop matches
	dc.w	$F2AF,$FFFE  ; WAIT 
	dc.w	DIWSTOP,$F1c7          ; DIW opens, because vstop no longer matches

	dc.w    $F401,$FFFE 
	dc.w	BPLCON0,(0<<12)|$200
	dc.w    $F539,$FFFE 
	RULER
	dc.w    DDFSTRT,$0018 
	dc.w	DDFSTOP,$00E0

	dc.l	$fffffffe

bitplanes:
	ds.b    16384,$00
	