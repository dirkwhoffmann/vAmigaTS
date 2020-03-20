	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
BASE                equ $38

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
	dc.w    BPLCON1,$11
	dc.w    $39A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $3A61,$FFFE  
	dc.w    BPLCON1,$11
	dc.w    $3AA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $3B61,$FFFE  
	dc.w    BPLCON1,$11
	dc.w    $3BA1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$3CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $3F61,$FFFE  ; Scroll
	dc.w    BPLCON1,$22
	dc.w    $3FA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $4061,$FFFE  
	dc.w    BPLCON1,$22
	dc.w    $40A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $4161,$FFFE  
	dc.w    BPLCON1,$22
	dc.w    $41A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$4201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$42D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $4561,$FFFE  ; Scroll
	dc.w    BPLCON1,$33
	dc.w    $45A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $4661,$FFFE  
	dc.w    BPLCON1,$33
	dc.w    $46A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $4761,$FFFE  
	dc.w    BPLCON1,$33
	dc.w    $47A1,$FFFE  
	dc.w    BPLCON1,$00

 	; 
	; Block 2 (LORES)
	;

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $4B61,$FFFE  ; Scroll
	dc.w    BPLCON1,$44
	dc.w    $4BA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $4C61,$FFFE  
	dc.w    BPLCON1,$44
	dc.w    $4CA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $4D61,$FFFE  
	dc.w    BPLCON1,$44
	dc.w    $4DA1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$4E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$4ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $5161,$FFFE  ; Scroll
	dc.w    BPLCON1,$55
	dc.w    $51A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $5261,$FFFE  
	dc.w    BPLCON1,$55
	dc.w    $52A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $5361,$FFFE  
	dc.w    BPLCON1,$55
	dc.w    $53A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$54D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $5761,$FFFE  ; Scroll
	dc.w    BPLCON1,$66
	dc.w    $57A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $5861,$FFFE  
	dc.w    BPLCON1,$66
	dc.w    $58A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $5961,$FFFE  
	dc.w    BPLCON1,$66
	dc.w    $59A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$5A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$5AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $5D61,$FFFE  ; Scroll
	dc.w    BPLCON1,$77
	dc.w    $5DA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $5E61,$FFFE  
	dc.w    BPLCON1,$77
	dc.w    $5EA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $5F61,$FFFE  
	dc.w    BPLCON1,$77
	dc.w    $5FA1,$FFFE  
	dc.w    BPLCON1,$00

	; 
	; Block 3 (LORES)
	;

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6361,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    $63A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $6461,$FFFE  
	dc.w    BPLCON1,$88
	dc.w    $64A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $6561,$FFFE  
	dc.w    BPLCON1,$88
	dc.w    $65A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$6601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$66D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6961,$FFFE  ; Scroll
	dc.w    BPLCON1,$99
	dc.w    $69A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $6A61,$FFFE  
	dc.w    BPLCON1,$99
	dc.w    $6AA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $6B61,$FFFE  
	dc.w    BPLCON1,$99
	dc.w    $6BA1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$6CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6F61,$FFFE  ; Scroll
	dc.w    BPLCON1,$AA
	dc.w    $6FA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $7061,$FFFE  
	dc.w    BPLCON1,$AA
	dc.w    $70A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $7161,$FFFE  
	dc.w    BPLCON1,$AA
	dc.w    $71A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$7201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$72D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $7561,$FFFE  ; Scroll
	dc.w    BPLCON1,$BB
	dc.w    $75A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $7661,$FFFE  
	dc.w    BPLCON1,$BB
	dc.w    $76A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $7761,$FFFE  
	dc.w    BPLCON1,$BB
	dc.w    $77A1,$FFFE  
	dc.w    BPLCON1,$00

	; 
	; Block 4 (LORES)
	;

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $7B61,$FFFE  ; Scroll
	dc.w    BPLCON1,$CC
	dc.w    $7BA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $7C61,$FFFE  
	dc.w    BPLCON1,$CC
	dc.w    $7CA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $7D61,$FFFE  
	dc.w    BPLCON1,$CC
	dc.w    $7DA1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$7E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$7ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $8161,$FFFE  ; Scroll
	dc.w    BPLCON1,$DD 
	dc.w    $81A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $8261,$FFFE  
	dc.w    BPLCON1,$DD
	dc.w    $82A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $8361,$FFFE  
	dc.w    BPLCON1,$DD
	dc.w    $83A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$8401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$84D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $8761,$FFFE  ; Scroll 
	dc.w    BPLCON1,$EE 
	dc.w    $87A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $8861,$FFFE  
	dc.w    BPLCON1,$EE
	dc.w    $88A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $8961,$FFFE  
	dc.w    BPLCON1,$EE
	dc.w    $89A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$8A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$8AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $8D61,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF 
	dc.w    $8DA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $8E61,$FFFE  
	dc.w    BPLCON1,$FF
	dc.w    $8EA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $8F61,$FFFE  
	dc.w    BPLCON1,$FF
	dc.w    $8FA1,$FFFE  
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
	dc.w    BPLCON1,$11
	dc.w    $A9A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $AA61,$FFFE  
	dc.w    BPLCON1,$11
	dc.w    $AAA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $AB61,$FFFE  
	dc.w    BPLCON1,$11
	dc.w    $ABA1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$AC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$ACD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $AF61,$FFFE  ; Scroll
	dc.w    BPLCON1,$22
	dc.w    $AFA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $B061,$FFFE  
	dc.w    BPLCON1,$22
	dc.w    $B0A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $B161,$FFFE  
	dc.w    BPLCON1,$22
	dc.w    $B1A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$B201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $B561,$FFFE  ; Scroll
	dc.w    BPLCON1,$33
	dc.w    $B5A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $B661,$FFFE  
	dc.w    BPLCON1,$33
	dc.w    $B6A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $B761,$FFFE  
	dc.w    BPLCON1,$33
	dc.w    $B7A1,$FFFE  
	dc.w    BPLCON1,$00

 	; 
	; Block 2 (HIRES)
	;

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	dc.w	$B8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $BB61,$FFFE  ; Scroll
	dc.w    BPLCON1,$44
	dc.w    $BBA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $BC61,$FFFE  
	dc.w    BPLCON1,$44
	dc.w    $BCA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $BD61,$FFFE  
	dc.w    BPLCON1,$44
	dc.w    $BDA1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$BE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$BED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $C161,$FFFE  ; Scroll
	dc.w    BPLCON1,$55
	dc.w    $C1A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $C261,$FFFE  
	dc.w    BPLCON1,$55
	dc.w    $C2A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $C361,$FFFE  
	dc.w    BPLCON1,$55
	dc.w    $C3A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$C401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$C4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $C761,$FFFE  ; Scroll
	dc.w    BPLCON1,$66
	dc.w    $C7A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $C861,$FFFE  
	dc.w    BPLCON1,$66
	dc.w    $C8A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $C961,$FFFE  
	dc.w    BPLCON1,$66
	dc.w    $C9A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$CA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$CAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $CD61,$FFFE  ; Scroll
	dc.w    BPLCON1,$77
	dc.w    $CDA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $CE61,$FFFE  
	dc.w    BPLCON1,$77
	dc.w    $CEA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $CF61,$FFFE  
	dc.w    BPLCON1,$77
	dc.w    $CFA1,$FFFE  
	dc.w    BPLCON1,$00

	; 
	; Block 3 (HIRES)
	;

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $D361,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    $D3A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $D461,$FFFE  
	dc.w    BPLCON1,$88
	dc.w    $D4A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $D561,$FFFE  
	dc.w    BPLCON1,$88
	dc.w    $D5A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$D601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$D6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $D961,$FFFE  ; Scroll
	dc.w    BPLCON1,$99
	dc.w    $D9A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $DA61,$FFFE  
	dc.w    BPLCON1,$99
	dc.w    $DAA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $DB61,$FFFE  
	dc.w    BPLCON1,$99
	dc.w    $DBA1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$DC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$DCD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $DF61,$FFFE  ; Scroll
	dc.w    BPLCON1,$AA
	dc.w    $DFA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $E061,$FFFE  
	dc.w    BPLCON1,$AA
	dc.w    $E0A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $E161,$FFFE  
	dc.w    BPLCON1,$AA
	dc.w    $E1A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$E201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$E2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $E561,$FFFE  ; Scroll
	dc.w    BPLCON1,$BB
	dc.w    $E5A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $E661,$FFFE  
	dc.w    BPLCON1,$BB
	dc.w    $E6A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $E761,$FFFE  
	dc.w    BPLCON1,$BB
	dc.w    $E7A1,$FFFE  
	dc.w    BPLCON1,$00

	; 
	; Block 4 (HIRES)
	;

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	dc.w	$E8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $EB61,$FFFE  ; Scroll
	dc.w    BPLCON1,$CC
	dc.w    $EBA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $EC61,$FFFE  
	dc.w    BPLCON1,$CC
	dc.w    $ECA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $ED61,$FFFE  
	dc.w    BPLCON1,$CC
	dc.w    $EDA1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$EE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$EED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $F161,$FFFE  ; Scroll
	dc.w    BPLCON1,$DD 
	dc.w    $F1A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $F261,$FFFE  
	dc.w    BPLCON1,$DD
	dc.w    $F2A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $F361,$FFFE  
	dc.w    BPLCON1,$DD
	dc.w    $F3A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$F401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$F4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $F761,$FFFE  ; Scroll 
	dc.w    BPLCON1,$EE 
	dc.w    $F7A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $F861,$FFFE  
	dc.w    BPLCON1,$EE
	dc.w    $F8A1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $F961,$FFFE  
	dc.w    BPLCON1,$EE
	dc.w    $F9A1,$FFFE  
	dc.w    BPLCON1,$00

	dc.w	$FA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$FAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $FD61,$FFFE  ; Scroll
	dc.w    BPLCON1,$FF 
	dc.w    $FDA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $FE61,$FFFE  
	dc.w    BPLCON1,$FF
	dc.w    $FEA1,$FFFE  
	dc.w    BPLCON1,$00
	dc.w    $FF61,$FFFE  
	dc.w    BPLCON1,$FF
	dc.w    $FFA1,$FFFE  
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
	