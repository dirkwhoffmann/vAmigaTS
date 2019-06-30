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


    ; Set number of bitplanes to 4, so Copper cannot be blocked by bitplane DMA.
	dc.w	BPLCON0,(4<<12)|$200

    ; First color block: Shrink the visible area
	dc.w	$3001,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c81 
	dc.w	DIWSTOP,$2cC1
	dc.w	$3801,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c91 
	dc.w	DIWSTOP,$2cB1
	dc.w	$4001,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cA1 
	dc.w	DIWSTOP,$2cA1
	dc.w	$4801,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cB1 
	dc.w	DIWSTOP,$2c91
	dc.w	$5001,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81
	dc.w	$5801,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cD1 
	dc.w	DIWSTOP,$2c71

	; Make some horizontal coordinates visible by changing the background color
	;dc.w	$6041,$FFFE  ; WAIT 
	;dc.w    COLOR00, $F00
	;dc.w	$6101,$FFFE  ; WAIT 
	;dc.w    COLOR00, $000
	;dc.w	$6161,$FFFE  ; WAIT 
	;dc.w	COLOR00, $0F0
	;dc.w	$6201,$FFFE  ; WAIT 
	;dc.w    COLOR00, $000
	;dc.w	$6281,$FFFE  ; WAIT 
	;dc.w    COLOR00, $55F
	;dc.w	$6301,$FFFE  ; WAIT 
	;dc.w    COLOR00, $000

	;dc.w	$63B1,$FFFE  ; WAIT 
	;dc.w    COLOR00, $F00
	;dc.w	$6401,$FFFE  ; WAIT 
	;dc.w    COLOR00, $000
	;dc.w	$64C1,$FFFE  ; WAIT 
	;dc.w	COLOR00, $0F0
	;dc.w	$6501,$FFFE  ; WAIT 
	;dc.w    COLOR00, $000
	;dc.w	$65D1,$FFFE  ; WAIT 
	;dc.w    COLOR00, $55F
	;dc.w	$6601,$FFFE  ; WAIT 
	;dc.w    COLOR00, $000
	;dc.w	$66E1,$FFFE  ; WAIT 
	;dc.w	COLOR00, $FF0
	;dc.w	$6701,$FFFE  ; WAIT (restore)
	;dc.w    DIWSTRT,$2cC1 
	;dc.w	DIWSTOP,$2c81
	;dc.w	COLOR00, $000

	; Second color block: Test DISTRT with horizontal values 0,1,2,3
	dc.w    $6F01,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $6FC1,$FFFE  ; WAIT
    dc.w    DIWSTRT,$2c00
	dc.w	DIWSTOP,$2c71
	dc.w    $7001,$FFFE  ; WAIT
	dc.w	COLOR00, $000
    dc.w    $78C1,$FFFE  ; WAIT (restore) 
  	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.w    $7F01,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $7FC1,$FFFE  ; WAIT
    dc.w    DIWSTRT,$2c01
	dc.w	DIWSTOP,$2c71
	dc.w    $8001,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $88C1,$FFFE  ; WAIT (restore) 
  	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81
	dc.w	COLOR00, $000

	dc.w    $8F01,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $8FC1,$FFFE  ; WAIT
    dc.w    DIWSTRT,$2c02
	dc.w	DIWSTOP,$2c71
	dc.w    $9001,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $98C1,$FFFE  ; WAIT (restore) 
  	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81
	dc.w	COLOR00, $000

	dc.w    $9F01,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $9FC1,$FFFE  ; WAIT
    dc.w    DIWSTRT,$2c03
	dc.w	DIWSTOP,$2c71
	dc.w    $A001,$FFFE  ; WAIT
	dc.w	COLOR00, $000
    dc.w    $A8C1,$FFFE  ; WAIT (restore) 
  	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81
	dc.w	COLOR00, $000

	; Third color block: Test DIWSTOP with horizontal values ...
	dc.w    $B701,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $B7B1,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cB1
	dc.w    DIWSTOP,$2cC5
	dc.w    $B801,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $C001,$FFFE  ; WAIT (restore) 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.w    $C701,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C7C9,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cB1
	dc.w    DIWSTOP,$2cC6
	dc.w    $C801,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $D001,$FFFE  ; WAIT (restore) 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.w    $D701,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D7C9,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cB1
	dc.w    DIWSTOP,$2cC7
	dc.w    $D801,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $E001,$FFFE  ; WAIT (restore) 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.w    $E701,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $E7D9,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cB1
	dc.w    DIWSTOP,$2cC8
	dc.w    $E801,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $F001,$FFFE  ; WAIT (restore) 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.w    $ffdf,$fffe ; Cross vertical boundary

; Fourth color block: Set DIWSTRT too late
	dc.w    $0001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $005B,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cF1
	dc.w    DIWSTOP,$2cA1
	dc.w    $0101,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $0801,$FFFE  ; WAIT (restore) 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.w    $1001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $105D,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cF1
	dc.w    DIWSTOP,$2cA1
	dc.w    $1101,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $1801,$FFFE  ; WAIT (restore) 
	dc.w    DIWSTRT,$2cC1 
	dc.w	DIWSTOP,$2c81

	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"
	