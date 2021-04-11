	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"

EXEC_BASE           equ $4
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
LEFT                equ $34 ;$54
RIGHT               equ $CC ;$AC
SHIFT1              equ $00
SHIFT2              equ $FF

entry:	
	lea 	CUSTOM,a1

	move.l  EXEC_BASE,a6
	jsr     -$84(a6)         ; Forbid()

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
	lea     BPL2PTH(a1),a3
	move.l	a2,(a3)
	lea     BPL3PTH(a1),a3
	move.l	a2,(a3)
	lea     BPL4PTH(a1),a3
	move.l	a2,(a3)
	lea     BPL5PTH(a1),a3
	move.l	a2,(a3)
	lea     BPL6PTH(a1),a3
	move.l	a2,(a3)
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w    DIWSTRT,$1871 ;2c89
	dc.w	DIWSTOP,$31d1 ;f5b9
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w    BPLCON1,$FF

	dc.w    COLOR01,$44F
	dc.w    COLOR02,$F00
	dc.w    COLOR03,$0F0
	dc.w    COLOR04,$00F
	dc.w    COLOR05,$FF0
	dc.w    COLOR06,$0FF
	dc.w    COLOR07,$F0F
	dc.w    COLOR08,$888
	dc.w    COLOR09,$F88
	dc.w    COLOR10,$8F8
	dc.w    COLOR11,$88F
	dc.w    COLOR12,$448
	dc.w    COLOR13,$FA3
	dc.w    COLOR14,$292
	dc.w    COLOR15,$4CC
	dc.w    COLOR16,$128
	dc.w    COLOR17,$812
	dc.w    COLOR18,$182
	dc.w    COLOR19,$FFF
	dc.w    COLOR20,$600
	dc.w    COLOR21,$269
	dc.w    COLOR22,$9AA
	dc.w    COLOR23,$F22
	dc.w    COLOR24,$325
	dc.w    COLOR25,$FF4
	dc.w    COLOR26,$F4F
	dc.w    COLOR27,$FF4
	dc.w    COLOR28,$48C
	dc.w    COLOR29,$8C4
	dc.w    COLOR30,$337
	dc.w    COLOR31,$44F

	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT

    ; 
	; Block 1 (LORES)
	;

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(6<<12)|$600 ; 6 bitplanes, DPF, lores
	dc.w    COLOR31,$66F
	dc.w    BPLCON1,$08
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w	$3601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$18
	dc.w	$36D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$28
	dc.w	$3CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$38
	dc.w	$42D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

 	; 
	; Block 2 (LORES)
	;

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR31,$B6F
	dc.w    BPLCON1,$48
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$58
	dc.w	$4ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$68
	dc.w	$54D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$78
	dc.w	$5AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 3 (LORES)
	;

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,SHIFT2
	dc.w    COLOR31,$F6F
	dc.w    BPLCON1,$88
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$6601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$98
	dc.w	$66D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$A8
	dc.w	$6CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$7201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$B8
	dc.w	$72D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 4 (LORES)
	;

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR31,$F6B
	dc.w    BPLCON1,$C8
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$7E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$D8
	dc.w	$7ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$8401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$E8
	dc.w	$84D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$8A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$F8
	dc.w	$8AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

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
	dc.w	BPLCON0,(4<<12)|$8600 ; 4 bitplanes, DPF, hires
	dc.w    BPLCON1,SHIFT1
	dc.w    COLOR15,$66F
	dc.w    BPLCON1,$08
	dc.w	$A0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w	$A601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$18
	dc.w	$A6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$AC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$28
	dc.w	$ACD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$B201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$38
	dc.w	$B2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

 	; 
	; Block 2 (HIRES)
	;

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR15,$B6F
	dc.w    BPLCON1,$48
	dc.w	$B8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$BE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$58
	dc.w	$BED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$C401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$68
	dc.w	$C4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$CA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$78
	dc.w	$CAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 3 (HIRES)
	;

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR15,$F6F
	dc.w    BPLCON1,$88
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$D601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$98
	dc.w	$D6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$DC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$A8
	dc.w	$DCD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$E201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$B8
	dc.w	$E2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 4 (HIRES)
	;

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR15,$F6B
	dc.w    BPLCON1,$C8
	dc.w	$E8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$EE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$D8
	dc.w	$EED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$F401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$E8
	dc.w	$F4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$FA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$F8
	dc.w	$FAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.w	$0001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$00D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off
	dc.w    DDFSTRT,$0038 ; Reset normal values
	dc.w	DDFSTOP,$00D0

	dc.l	$fffffffe

bitplanes:
	ds.b    51201
	