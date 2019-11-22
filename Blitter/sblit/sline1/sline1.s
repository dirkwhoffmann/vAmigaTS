	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
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
	
entry:

	lea 	CUSTOM,a6           ; Chipset base

	move	#$7fff,INTENA(a6)	; Disable all interrupts
	move.b  #$7F,$BFDD00        ; Disable CIA B interrupts
	move.b  #$7F,$BFED01        ; Disable CIA A interrupts

	bsr blitWait 	            ; Wait until the Blitter is ready

	move.w	#$C080,INTENA(a6)   ; Enable audio interrupt (level 4)

	lea	level3IrqHandler(pc),a3 ; Install handler for level 3 IRQs
 	move.l	a3,LVL3_INT_VECTOR

	include "out/image-palette.s"
	
	; Set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a6)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a6)

	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a6)
	
	move.w	#(SCREEN_BIT_DEPTH<<12)|$200,BPLCON0(a6)
	move.w	#0,BPL1MOD(a6)
	move.w	#0,BPL2MOD(a6)

	bsr.s 	prepareblit         ; Prepare the Blitter

	move.w  #$8003,COPCON(a6)   ; Allow Copper to write Blitter registers
	lea	copper(pc),a0           ; Get pointer to Copper list
	move.l	a0,COP1LC(a6)       ; Write pointer to Copper location register 1
 	move.w  COPJMP1(a6),d0      ; Jump to the first Copper list

	move.w	#(INTF_SETCLR|INTF_INTEN|INTF_VERTB),INTENA(a6)  ; Enable vertical blank interrupt
	
	move.w	#$07C0,DMACON(a6)   ; Disable all DMA
	move.w	#$87C0,DMACON(a6)   ; Set BLTPRI, DMAEN, BPLEN, COPEN, BLTEN

.mainLoop:
	bra.s	.mainLoop

blitWait:
	tst DMACONR(a6)		;for compatibility
.waitblit:
	btst #6,DMACONR(a6)
	bne.s .waitblit
	rts

waitBlitIdle:
	btst #14,DMACONR(a6)
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
	move.l #bitplanes+$232,BLTCPTH(a6)
	move.l #bitplanes+$232,BLTDPTH(a6)
	move.w #40,BLTCMOD(a6)
	move.w #40,BLTDMOD(a6)
	move.w #110,BLTAPTL(a6)
	move.w #-80,BLTAMOD(a6)
	move.w #300,BLTBMOD(a6)
	move.w #$ABCA,BLTCON0(a6)
	move.w #$11,BLTCON1(a6)
	move.w #$8000,BLTADAT(a6)
	move.w #$FFFF,BLTBDAT(a6)
	move.l #$FFFFFFFF,BLTAFWM(a6)

	movem.l (sp)+,d0-a6
	rts

level3IrqHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.w	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; Clear interrupt bit	
	move.w  #$000,COLOR00(a5)       ; Clear background color
	jsr prepareblit

.resetBitplanePointers:
	lea	bitplanes(pc),a1
	lea     BPL1PTH(a5),a2
	moveq	#SCREEN_BIT_DEPTH-1,d0

.bitplaneloop:
	move.l	a1,(a2)
	; lea	SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
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
	move.w	#$70,INTREQ(a5)
	movem.l	(sp)+,d0-a6
	rte

copper:

    ; Enable 0 bitplanes
	dc.w	BPLCON0, $200

    ; Perform blit (emoji)
	dc.w	$3051,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $2F82
	dc.w    COLOR00, $0F0
	dc.w    $3051,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000

    ; Perform blit again with size 1x1
	dc.w	$A051,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $42
	dc.w    COLOR00, $0F0
	dc.w    $A051,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000

 	; Perform blit again with size 1x2
	dc.w	$A251,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $82
	dc.w    COLOR00, $0F0
	dc.w    $A251,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000

    ; Perform blit again with size 2x1
	dc.w	$A451,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $C2
	dc.w    COLOR00, $0F0
	dc.w    $A451,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000
	
	; Perform blit again with size 2x2
	dc.w	$A651,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $102
	dc.w    COLOR00, $0F0
	dc.w    $A651,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000
	
	; Perform blit again with size 3x2
	dc.w	$A851,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $182
	dc.w    COLOR00, $0F0
	dc.w    $A851,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000

	; Perform blit again with size 2x3
	dc.w	$AA51,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $202
	dc.w    COLOR00, $0F0
	dc.w    $AA51,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000

	; Perform blit again with size 3x3
	dc.w	$AC51,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $302
	dc.w    COLOR00, $0F0
	dc.w    $AC51,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000
	
	; Perform blit again with size 4x3
	dc.w	$AE51,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $402
	dc.w    COLOR00, $0F0
	dc.w    $AC51,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000

	; Perform blit again with size 3x4
	dc.w	$B051,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $502
	dc.w    COLOR00, $0F0
	dc.w    $AC51,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000

	; Perform blit again with size 4x4
	dc.w	$B251,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, $602
	dc.w    COLOR00, $0F0
	dc.w    $AC51,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000

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
	incbin	"out/emoji.bin"
	ds.b    128,$00

emojiMask:	
	incbin	"out/emoji-mask.bin"
	ds.b    128,$00