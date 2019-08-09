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
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"

    ; First color block: Shrink the visible area by modifying DIWSTRT and DIWSTOP
	dc.w	$3801,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cA1
	dc.w    DIWSTOP,$2cA1
	dc.w	COLOR00, $F00
	dc.w	$3901,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$3B01,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cA2
	dc.w    DIWSTOP,$2cA0
	dc.w	COLOR00, $F00
	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$3E01,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cA3
	dc.w    DIWSTOP,$2c9F
	dc.w	COLOR00, $F00
	dc.w	$3F01,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4101,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cA4
	dc.w    DIWSTOP,$2c9E
	dc.w	COLOR00, $F00
	dc.w	$4201,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4401,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cA5
	dc.w    DIWSTOP,$2c9D
	dc.w	COLOR00, $F00
	dc.w	$4501,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4701,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cA6
	dc.w    DIWSTOP,$2c9C
	dc.w	COLOR00, $F00
	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4A01,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cA7
	dc.w    DIWSTOP,$2c9B
	dc.w	COLOR00, $F00
	dc.w	$4B01,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4D01,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cA8
	dc.w    DIWSTOP,$2c9A
	dc.w	COLOR00, $F00
	dc.w	$4E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cA9
	dc.w    DIWSTOP,$2c99
	dc.w	COLOR00, $F00
	dc.w	$5101,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5301,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2cAA
	dc.w    DIWSTOP,$2c98
	dc.w	COLOR00, $F00
	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5701,$FFFE  ; WAIT (restore old values) 
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1

    ; Second color block: Skip matches with DIWSTOP
	dc.w    $6Fb1,$FFFE  ; WAIT
	dc.w    DIWSTOP,$2ca1
	dc.w	COLOR00, $F00

	dc.w    $7091,$FFFE  ; WAIT
	dc.w    DIWSTOP,$2c81
	dc.w	COLOR00, $0F0

	dc.w    $7171,$FFFE  ; WAIT
	dc.w    DIWSTOP,$2c61
	dc.w	COLOR00, $00F

	dc.w    $7251,$FFFE  ; WAIT
	dc.w    DIWSTOP,$2c41
	dc.w	COLOR00, $FF0

	dc.w    $7231,$FFFE  ; WAIT
	dc.w    DIWSTOP,$2c21
	dc.w	COLOR00, $0FF

	dc.w    $7311,$FFFE  ; WAIT
	dc.w    DIWSTOP,$2c01
	dc.w	COLOR00, $888

  ; Third color block: Test smallest DISSTRT and largest DIWSTOP that take effect
	dc.w    $B7C9,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2c01
	dc.w    DIWSTOP,$2cc1
	dc.w	COLOR00, $F00
	dc.w	$B901,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $C001,$FFFE  ; WAIT (restore old values) 
	dc.w    DIWSTRT,$2c81 
	dc.w	DIWSTOP,$2cc1

	dc.w    $C7C9,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2c02
	dc.w    DIWSTOP,$2cc1
	dc.w	COLOR00, $F00
	dc.w	$C901,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $D001,$FFFE  ; WAIT (restore old values) 
	dc.w    DIWSTRT,$2c81 
	dc.w	DIWSTOP,$2cc1

	dc.w    $D7C9,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cA1
	dc.w    DIWSTOP,$2cC7
	dc.w	COLOR00, $F00
	dc.w	$D901,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $E001,$FFFE  ; WAIT (restore old values) 
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1

	dc.w    $E7D9,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cA1
	dc.w    DIWSTOP,$2cC8
	dc.w	COLOR00, $F00
	dc.w	$E901,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $F001,$FFFE  ; WAIT (restore old values) 
	dc.w    DIWSTRT,$2c81 
	dc.w	DIWSTOP,$2cc1

	dc.w    $ffdf,$fffe ; Cross vertical boundary

; Fourth color block: Put start and stop values close together
	dc.w    $00C9,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cFE
	dc.w    DIWSTOP,$2c01
	dc.w	COLOR00, $F00
	dc.w	$0201,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $0801,$FFFE  ; WAIT (restore old values) 
	dc.w    DIWSTRT,$2c81 
	dc.w	DIWSTOP,$2cc1

	dc.w    $10C9,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cFE
	dc.w    DIWSTOP,$2c00
	dc.w	COLOR00, $F00
	dc.w	$1201,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $1801,$FFFE  ; WAIT (restore old values) 
	dc.w    DIWSTRT,$2c81 
	dc.w	DIWSTOP,$2cc1

	dc.w    $20C9,$FFFE  ; WAIT
	dc.w    DIWSTRT,$2cFF
	dc.w    DIWSTOP,$2c00
	dc.w	COLOR00, $F00
	dc.w	$2201,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $2801,$FFFE  ; WAIT (restore old values) 
	dc.w    DIWSTRT,$2c81 
	dc.w	DIWSTOP,$2cc1

	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"
	