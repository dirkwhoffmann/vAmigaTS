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
    dc.w    DIWSTOP,$2cd1
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES


 	include	"out/image-copper-list.s"


    ; Lores mode, 4 bitplanes
	dc.w	BPLCON0,(4<<12)|$200

    ;
	; First color block
	;

	; 
	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$3101,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

    ; 
	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$39A1,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$00A8 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	; 
	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$4101,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	; 
	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$49A3,$FFFE  ; WAIT
	dc.w    DDFSTRT,$00A8 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	; 
	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$5101,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	; 
	dc.w	$5801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$59A5,$FFFE  ; WAIT
	dc.w    DDFSTRT,$00A8 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $111

	;
	; Second color block (similar to first block, but DDFSTRT not dividable by 4)
	; 

	dc.w    $7001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $7101,$FFFE  ; WAIT
  	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000
	
	dc.w    $7801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $78A7,$FFFE  ; WAIT
  	dc.w    DDFSTRT,$00A8 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $8001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $8101,$FFFE  ; WAIT
 	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $8801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $89A9,$FFFE  ; WAIT
    dc.w    DDFSTRT,$00A8 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $9001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $9101,$FFFE  ; WAIT
    dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $9801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $99A1,$FFFE  ; WAIT
    dc.w    DDFSTRT,$00AA 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $A001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $A101,$FFFE  ; WAIT
    dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	;	
	; Third color block
	;
	
	dc.w    $B801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $B9A3,$FFFE  ; WAIT
	dc.w    DDFSTRT,$00AA 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $C001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C101,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $C801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C9A5,$FFFE  ; WAIT
	dc.w    DDFSTRT,$00AA 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $D001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D101,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $D801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D9A7,$FFFE  ; WAIT
	dc.w    DDFSTRT,$00AA 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $E001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $E101,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $E801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $E9A9,$FFFE  ; WAIT
	dc.w    DDFSTRT,$00AA 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $ffdf,$fffe ; Cross vertical boundary

; Fourth color block: Set DIWSTRT too late
	dc.w    $0001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $0101,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $0801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $09AB,$FFFE  ; WAIT
	dc.w    DDFSTRT,$00AA 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $1001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $1101,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $1801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $18AB,$FFFE  ; WAIT
	dc.w    DDFSTRT,$00B1 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $2001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $2101,$FFFE  ; WAIT
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    $2801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $29AB,$FFFE  ; WAIT
	dc.w    DDFSTRT,$00B2 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w    DDFSTRT,$0038 ; Reset normal values
	dc.w	DDFSTOP,$00D0

	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"
	