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

.enableDMA:
	move.w  #$8200,DMACON(a5)

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


    ; Set number of bitplanes to 4, so Copper cannot be blocked by bitplane DMA.
	dc.w	BPLCON0,(4<<12)|$200

    ; First color block
	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$0028 
	dc.w	DDFSTOP,$00C0
	dc.w    DMACON,$0100
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$311B,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$38D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$391D,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$40D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$411F,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$4921,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$50D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$5123,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$5801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$58D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$5925,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$6127,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	; Second color block
	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$002A 
	dc.w	DDFSTOP,$00C2
	dc.w    DMACON,$0100
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$791B,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$8001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$80D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$811D,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$8801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$88D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$891F,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$90D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$9121,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$9801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$98D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$9923,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$A001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$A0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$A125,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$A801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$A8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$A927,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$B001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$B0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$B129,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	; Third color block
	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$002C 
	dc.w	DDFSTOP,$00C4
	dc.w    DMACON,$0100
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$D11B,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$D801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$D8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$D91D,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$E001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$E0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$E11F,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$E8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$E921,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$F001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$F0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$F123,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$F801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$F8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$F925,$FFFE  ; WAIT 
	dc.w    DMACON,$8100
	
	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w	$0001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$00D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$0127,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$0801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$08D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$0927,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

; Fourth color block: Set DIWSTRT too late

	;dc.w    DDFSTRT,$0038 ; Reset normal values
	;dc.w	DDFSTOP,$00D0

	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"
	