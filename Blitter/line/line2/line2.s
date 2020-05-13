	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"
	
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
SCREEN_WIDTH		equ 320
SCREEN_HEIGHT		equ 256
SCREEN_WIDTH_BYTES	equ (SCREEN_WIDTH/8)
SCREEN_BIT_DEPTH	equ 5
SCREEN_RES	        equ 8 	; 8=lo resolution, 4=hi resolution
RASTER_X_START		equ $81	; hard coded coordinates from hardware manual
RASTER_Y_START		equ $2c
RASTER_X_STOP		equ RASTER_X_START+SCREEN_WIDTH
RASTER_Y_STOP		equ RASTER_Y_START+SCREEN_HEIGHT

BOB_WIDTH 		    equ 64
BOB_HEIGHT		    equ 64
BOB_WIDTH_BYTES		equ BOB_WIDTH/8
BOB_WIDTH_WORDS		equ BOB_WIDTH/16
BOB_XPOS		    equ 64
BOB_YPOS		    equ 8	
BOB_XPOS_BYTES		equ (BOB_XPOS)/8	
	
MAIN:	
	; Load OCS base address
	lea     CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install interrupt handlers
	lea	irq1(pc),a2
 	move.l	a2,LVL1_INT_VECTOR
	lea	irq3(pc),a2
 	move.l	a2,LVL3_INT_VECTOR

	bsr blitWait 	            ; Wait until the Blitter is ready

	; include "out/image-palette.s"
	
	; Set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a1)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a1)

	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a1)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a1)
	
	move.w	#(SCREEN_BIT_DEPTH<<12)|$200,BPLCON0(a1)
	move.w	#0,BPL1MOD(a1)
	move.w	#0,BPL2MOD(a1)

	bsr.s 	prepareblit         ; Prepare the Blitter

	; Setup bitplane pointers
	lea     bitplanes(pc),a2
	lea     copper(pc),a3
	moveq	#4,d0
.bitplaneloop:
	move.l 	a2,d1
	move.w	d1,2(a3)
	swap	d1
	move.w  d1,6(a3)
	addq	#8,a3
	dbra	d0,.bitplaneloop

	; Configure Copper
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #$8003,COPCON(a1)   ; Allow Copper to write Blitter registers

	; Enable DMA
	move.w	#$87C0,DMACON(a1)   ; BLTPRI, DMAEN, BPLEN, COPEN, BLTEN

	; Enable interrupts
	move.w	#$C044,INTENA(a1)  

.mainLoop:
	bra.s	.mainLoop

blitWait:
	tst DMACONR(a1)		;for compatibility
.waitblit:
	btst #6,DMACONR(a1)
	bne.s .waitblit
	rts

waitBlitIdle:
	btst #14,DMACONR(a1)
	bne.s waitBlitIdle
	rts

delayLoop:
	move.l    #$010000,D0
	subq.l    #1,D0 
	bgt.s     delayLoop
	rts
	
prepareblit:	
	movem.l d0-a6,-(sp)
	bsr blitWait
	; bsr waitBlitIdle    ; DO WE NEED THIS? 

    ; Line blit examle from "Amiga Intern"
	move.l #bitplanes+$232,BLTCPTH(a1)
	move.l #bitplanes+$232,BLTDPTH(a1)
	move.w #40,BLTCMOD(a1)
	move.w #40,BLTDMOD(a1)
	move.w #110,BLTAPTL(a1)
	move.w #-80,BLTAMOD(a1)
	move.w #300,BLTBMOD(a1)
	move.w #$ABCA,BLTCON0(a1)
	move.w #$11,BLTCON1(a1)
	move.w #$8000,BLTADAT(a1)
	move.w #$FFFF,BLTBDAT(a1)
	move.l #$FFFFFFFF,BLTAFWM(a1)

	movem.l (sp)+,d0-a6
	rts

irq1:
	move.w	#$04,INTREQ(a1)
	jsr     prepareblit
	rte

irq3:
	move.w  #$000,COLOR00(a1)
	move.w	#$40,INTREQ(a1)
	rte

copper:
	; Bitplane pointers must be first else poking addresses will be incorrect
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

    include "colors.s"

 	dc.w    $1F39, $FFFE         ; WAIT
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

	dc.w    INTREQ,$8004         ; Prepare Blitter 

    ; Enable 0 bitplanes
	dc.w	BPLCON0, $200

    ; Perform blit (emoji)
	dc.w	$3051,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $2F82
	dc.w    COLOR00, $0F0

    ; Perform blit again with size 1x1
	dc.w	$A051,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $42
	dc.w    COLOR00, $0F0

 	; Perform blit again with size 1x2
	dc.w	$A251,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $82
	dc.w    COLOR00, $0F0

    ; Perform blit again with size 2x1
	dc.w	$A451,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $C2
	dc.w    COLOR00, $0F0
	
	; Perform blit again with size 2x2
	dc.w	$A651,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $102
	dc.w    COLOR00, $0F0
	
	; Perform blit again with size 3x2
	dc.w	$A851,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $182
	dc.w    COLOR00, $0F0

	; Perform blit again with size 2x3
	dc.w	$AA51,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $202
	dc.w    COLOR00, $0F0

	; Perform blit again with size 3x3
	dc.w	$AC51,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $302
	dc.w    COLOR00, $0F0
	
	; Perform blit again with size 4x3
	dc.w	$AE51,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $402
	dc.w    COLOR00, $0F0

	; Perform blit again with size 3x4
	dc.w	$B051,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $502
	dc.w    COLOR00, $0F0

	; Perform blit again with size 4x4
	dc.w	$B251,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $602
	dc.w    COLOR00, $0F0

    ; ;; Enable all bitplanes (to show the emoji)
	dc.w    $C001,$FFFE ; WAIT
	dc.w    BPLCON0, (5<<12)|$200

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe	

bitplanes:
	; incbin	"out/image.bin"
	ds.b    51200,$00
	ds.b    128,$00

emoji:
	;incbin	"out/emoji.bin"
	ds.b    128,$00

emojiMask:	
	;incbin	"out/emoji-mask.bin"
	ds.b    128,$00