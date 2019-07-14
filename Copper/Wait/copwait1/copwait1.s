	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

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

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.s	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; clear interrupt bit	

.resetBitplanePointers:
	lea	bitplanes(pc),a1
	lea     BPL1PTH(a5),a2
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l	a1,(a2)
	lea	SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#4,a2
	dbra	d0,.bitplaneloop
	
.checkCopper:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete
.copperInterrupt:
	move.w	#INTF_COPER,INTREQ(a5)	; clear interrupt bit	
	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"


    ; Set number of bitplanes
	dc.w	BPLCON0,(4<<12)|$200

    ; First color block
	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$38D9,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$40D9,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$50D9,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000
	dc.w	$5101,$FFFE  ; WAIT 

	dc.w	$5801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$58D9,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	; Between first and second block
	dc.w	$6241,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $000

	dc.w	$6261,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	$6261,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6281,$FFFE  ; WAIT
	dc.w	COLOR00, $0FF
	dc.w    $6281,$FFFE  ; WAIT
	dc.w    $6281,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $62B1,$FFFE  ; WAIT
	dc.w	COLOR00, $F0F
	dc.w    $62B1,$FFFE  ; WAIT
	dc.w    $62B1,$FFFE  ; WAIT
	dc.w    $62B1,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w	$6443,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $000

	dc.w	$6463,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	$6265,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6483,$FFFE  ; WAIT
	dc.w	COLOR00, $0FF
	dc.w    $6485,$FFFE  ; WAIT
	dc.w    $6485,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $64B3,$FFFE  ; WAIT
	dc.w	COLOR00, $F0F
	dc.w    $64B5,$FFFE  ; WAIT
	dc.w    $64B5,$FFFE  ; WAIT
	dc.w    $64B5,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	; Second color block
	dc.w    $7001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $70D9,$FFFE  ; WAIT
  	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $7801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $78D9,$FFFE  ; WAIT
  	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $8001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $80D9,$FFFE  ; WAIT
 	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $8801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $88D9,$FFFE  ; WAIT
    dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $9001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $90D9,$FFFE  ; WAIT
    dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $9801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $98D9,$FFFE  ; WAIT
    dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $A001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $A0D9,$FFFE  ; WAIT
    dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	; Between second and third block
	dc.w	$AB41,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $000

	dc.w	$AB61,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	$AB65,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $AB81,$FFFE  ; WAIT
	dc.w	COLOR00, $0FF
	dc.w    $AB85,$FFFE  ; WAIT
	dc.w    $AB85,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $ABB1,$FFFE  ; WAIT
	dc.w	COLOR00, $F0F
	dc.w    $ABB7,$FFFE  ; WAIT
	dc.w    $ABB7,$FFFE  ; WAIT
	dc.w    $ABB7,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w	$AD43,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $000

	dc.w	$AD63,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	$AD6B,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $AD83,$FFFE  ; WAIT
	dc.w	COLOR00, $0FF
	dc.w    $AD8B,$FFFE  ; WAIT
	dc.w    $AD8B,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $ADB3,$FFFE  ; WAIT
	dc.w	COLOR00, $F0F
	dc.w    $ADBB,$FFFE  ; WAIT
	dc.w    $ADBB,$FFFE  ; WAIT
	dc.w    $ADBB,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	; Third color block
	dc.w    $B801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $B8D9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $C001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C0D9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $C801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C8D9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $D001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D0D9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $D801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D8D9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $E001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $E0D9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $E801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $E8D9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	; Between third and fourth block
	dc.w	$F441,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $000

	dc.w	$F461,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	$F469,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $F481,$FFFE  ; WAIT
	dc.w	COLOR00, $0FF
	dc.w    $F48B,$FFFE  ; WAIT
	dc.w    $F48B,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $F4B1,$FFFE  ; WAIT
	dc.w	COLOR00, $F0F
	dc.w    $F4BD,$FFFE  ; WAIT
	dc.w    $F4BD,$FFFE  ; WAIT
	dc.w    $F4BD,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w	$F643,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $000

	dc.w	$F663,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	$F671,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $F683,$FFFE  ; WAIT
	dc.w	COLOR00, $0FF
	dc.w    $F693,$FFFE  ; WAIT
	dc.w    $F693,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $F6B3,$FFFE  ; WAIT
	dc.w	COLOR00, $F0F
	dc.w    $F6C5,$FFFE  ; WAIT
	dc.w    $F6C5,$FFFE  ; WAIT
	dc.w    $F6C5,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $ffdf,$fffe ; Cross vertical boundary


	; Fourth color block
	dc.w    $0001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $00D9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $0801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $08D9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $1001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $10D9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $1801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $18D9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $2001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $20D9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $2801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $28D9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    DDFSTRT,$0038 ; Reset normal values
	dc.w	DDFSTOP,$00D0

	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"
	