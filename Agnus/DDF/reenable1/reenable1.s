	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
LEFT                equ $80
RIGHT               equ $b0

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
	dc.w    DDFSTRT,$38
	dc.w	DDFSTOP,$80
	dc.w	$3091,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$A0
	dc.w	DDFSTOP,$D0
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$200 ; 1 bitplanes, lores mode
	dc.w    COLOR01,$66F
	dc.w    DDFSTRT,$38
	dc.w	DDFSTOP,$48
	dc.w	$3851,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$58
	dc.w	DDFSTOP,$68
	dc.w	$3871,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$78
	dc.w	DDFSTOP,$88
	dc.w	$3891,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$98
	dc.w	DDFSTOP,$A8
	dc.w	$38B1,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$B8
	dc.w	DDFSTOP,$C8
	dc.w	$38D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$200 ; 1 bitplanes, lores mode
	dc.w    COLOR01,$66F
	dc.w    DDFSTRT,$38
	dc.w	DDFSTOP,$38
	dc.w	$4051,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$58
	dc.w	DDFSTOP,$58
	dc.w	$4071,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$78
	dc.w	DDFSTOP,$78
	dc.w	$4091,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$98
	dc.w	DDFSTOP,$98
	dc.w	$40B1,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$B8
	dc.w	DDFSTOP,$B8
	dc.w	$40D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$200 ; 1 bitplanes, lores mode
	dc.w    COLOR01,$66F
	dc.w    DDFSTRT,$38
	dc.w	DDFSTOP,$38
	dc.w	$4851,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$60
	dc.w	DDFSTOP,$60
	dc.w	$4871,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$80
	dc.w	DDFSTOP,$80
	dc.w	$4891,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$A0
	dc.w	DDFSTOP,$A0
	dc.w	$48B1,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$C0
	dc.w	DDFSTOP,$C0
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off
	dc.w    DDFSTRT,$0038 ; Reset normal values
	dc.w	DDFSTOP,$00D0

	dc.l	$fffffffe

bitplanes:
	ds.b    51201
	