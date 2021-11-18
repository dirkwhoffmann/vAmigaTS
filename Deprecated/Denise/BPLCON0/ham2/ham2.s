	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

SCREEN_WIDTH		equ 320
SCREEN_HEIGHT		equ 256
SCREEN_WIDTH_BYTES	equ (SCREEN_WIDTH/8)
SCREEN_BIT_DEPTH	equ 6
SCREEN_RES		    equ 8 	; 8=lo resolution, 4=hi resolution
RASTER_X_START		equ $81	; hard coded coordinates from hardware manual
RASTER_Y_START		equ $2c
RASTER_X_STOP		equ RASTER_X_START+SCREEN_WIDTH
RASTER_Y_STOP		equ RASTER_Y_START+SCREEN_HEIGHT

BPL5DAT             equ $118
BPL6DAT             equ $11A

MAIN:	
	; Load OCS base address into a1
	lea CUSTOM,a1
	lea CUSTOM,a6

	include "image-palette.s"

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a1)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a1)

	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a1)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a1)
	
	; move.w	#(SCREEN_BIT_DEPTH<<12)|COLOR_ON|HOMOD,BPLCON0(a1)
	move.w	#$6A00,BPLCON0(a1)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL1MOD(a1)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL2MOD(a1)

 	; Setup bitplane pointers
	lea     bitplanes(pc),a1
	lea     copper(pc),a2
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a2)
	swap	d1
	move.w  d1,6(a2)
	lea	    SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#8,a2
	dbra	d0,.bitplaneloop

	; Install Copper list and enable DMA
	lea 	CUSTOM,a1
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

.mainLoop:
	bra.b	.mainLoop


copper:
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0

	dc.w    DDFSTRT,$0038
	dc.w	DDFSTOP,$00D0
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPLCON0,$0A00
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES

	dc.w    $3001,$FFFE ; Wait
	dc.w	BPLCON0,$1A00

	dc.w    $4001,$FFFE ; Wait
	dc.w	BPLCON0,$2A00

	dc.w    $5001,$FFFE ; Wait
	dc.w	BPLCON0,$3A00

	dc.w    $6001,$FFFE ; Wait
	dc.w	BPLCON0,$4A00

	dc.w    $7001,$FFFE ; Wait
	dc.w	BPLCON0,$5A00

	dc.w    $8001,$FFFE ; Wait
	dc.w	BPLCON0,$6A00

	dc.w    $9001,$FFFE ; Wait
	dc.w	BPLCON0,$7A00

	dc.w    $A001,$FFFE ; Wait
	dc.w	BPLCON0,$8A00

	dc.w    $B001,$FFFE ; Wait
	dc.w	BPLCON0,$9A00

	dc.w    $C001,$FFFE ; Wait
	dc.w	BPLCON0,$AA00

	dc.w    $D001,$FFFE ; Wait
	dc.w	BPLCON0,$BA00

	dc.w    $E001,$FFFE ; Wait
	dc.w	BPLCON0,$CA00

	dc.w    $F001,$FFFE ; Wait
	dc.w	BPLCON0,$DA00

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w    $0001,$FFFE ; Wait
	dc.w	BPLCON0,$EA00

	dc.w    $1001,$FFFE ; Wait
	dc.w	BPLCON0,$FA00

	dc.l	$fffffffe

bitplanes:
	;incbin	"image.bin"
	incbin	"hampic.bin"
	