	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
BASE                equ $38
SCROLL              equ $AA

entry:	
	lea 	CUSTOM,a1

	; Install interrupt handler
	lea	level3InterruptHandler(pc),a3
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

	;; install copper list and enable DMA
	lea 	CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	
.mainLoop:
	bra.b	.mainLoop

level3InterruptHandler:

	movem.l	d0-a6,-(sp)
	lea 	CUSTOM,a1
	move.w	#$3FFF,INTREQ(a1)	; Acknowledge
	lea     bitplanes(pc),a2
	lea     BPL1PTH(a1),a3
	move.l	a2,(a3)
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w    BPLCON1,$0000
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
    ; 
	; Block 1 (LORES)
	;

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$200 ; 1 bitplanes, lores mode
	dc.w    COLOR01,$66F
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$3601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$36D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $3961,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $39A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $3A61,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $3AA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $3B61,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $3BA1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$3CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $3F63,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $3FA3,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $4063,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $40A3,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $4163,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $41A3,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$4201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$42D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $4565,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $45A5,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $4665,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $46A5,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $4765,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $47A5,$FFFE  
	dc.w    BPLCON1,$00

 	; 
	; Block 2 (LORES)
	;

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $4B67,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $4BA7,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $4C67,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $4CA7,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $4D67,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $4DA7,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$4E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$4ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $5169,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $51A9,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $5269,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $52A9,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $5369,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $53A9,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$54D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $576B,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $57AB,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $586B,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $58AB,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $596B,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $59AB,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$5A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$5AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $5D6D,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $5DAD,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $5E6D,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $5EAD,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $5F6D,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $5FAD,$FFFE  
	dc.w    BPLCON1,$00

	; 
	; Block 3 (LORES)
	;

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $636F,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $63AF,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $646F,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $64AF,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $656F,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $65AF,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$6601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$66D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6971,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $69B1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $6A71,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $6AB1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $6B71,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $6BB1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$6CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6F73,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $6FB3,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $7073,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $70B3,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $7173,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $71B3,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$7201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$72D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $7575,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $75B5,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $7675,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $76B5,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $7775,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $77B5,$FFFE  
	dc.w    BPLCON1,$00

	; 
	; Block 4 (LORES)
	;

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $7B77,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $7BB7,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $7C77,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $7CB7,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $7D77,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $7DB7,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$7E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$7ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $8179,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF 
	dc.w    $81B9,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $8279,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $82B9,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $8379,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $83B9,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$8401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$84D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $877B,$FFFE  ; Scroll 
	dc.w    BPLCON1,$FF 
	dc.w    $87BB,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $887B,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $88BB,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $897B,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $89BB,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$8A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$8AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $8D7D,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF 
	dc.w    $8DBD,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $8E7D,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $8EBD,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $8F7D,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $8FBD,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$90D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off
	dc.w    BPLCON1,$00

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

	dc.w	$A601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $A961,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $A9A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $AA61,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $AAA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $AB61,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $ABA1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$AC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$ACD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $AF63,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $AFA3,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $B063,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $B0A3,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $B163,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $B1A3,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$B201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $B565,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $B5A5,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $B665,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $B6A5,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $B765,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $B7A5,$FFFE  
	dc.w    BPLCON1,$00

 	; 
	; Block 2 (HIRES)
	;

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	dc.w	$B8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $BB67,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $BBA7,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $BC67,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $BCA7,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $BD67,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $BDA7,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$BE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$BED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $C169,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $C1A9,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $C269,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $C2A9,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $C369,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $C3A9,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$C401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$C4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $C76B,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $C7AB,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $C86B,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $C8AB,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $C96B,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $C9AB,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$CA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$CAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $CD6D,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $CDAD,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $CE6D,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $CEAD,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $CF6D,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $CFAD,$FFFE  
	dc.w    BPLCON1,$00

	; 
	; Block 3 (HIRES)
	;

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $D36F,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $D3AF,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $D46F,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $D4AF,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $D56F,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $D5AF,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$D601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$D6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $D971,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $D9B1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $DA71,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $DAB1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $DB71,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $DBB1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$DC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$DCD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $DF73,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $DFB3,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $E073,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $E0B3,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $E173,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $E1B3,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$E201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$E2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $E575,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $E5B5,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $E675,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $E6B5,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $E775,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $E7B5,$FFFE  
	dc.w    BPLCON1,$00

	; 
	; Block 4 (HIRES)
	;

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	dc.w	$E8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $EB77,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF
	dc.w    $EBB7,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $EC77,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $ECB7,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $ED77,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $EDB7,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$EE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$EED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $F179,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF 
	dc.w    $F1B9,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $F279,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $F2B9,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $F379,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $F3B9,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$F401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$F4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $F77B,$FFFE  ; Scroll 
	dc.w    BPLCON1,$FF 
	dc.w    $F7BB,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $F87B,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $F8BB,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $F97B,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $F9BB,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$FA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$FAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $FD7D,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF 
	dc.w    $FDBD,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $FE7D,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $FEBD,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $FF7D,$FFFE  
	dc.w    BPLCON1,SCROLL
	dc.w    $FFBD,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.w	$0001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$00D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off
	dc.w    DDFSTRT,$0038 ; Reset normal values
	dc.w	DDFSTOP,$00B0

	dc.l	$fffffffe

bitplanes:
	ds.b    51201
	