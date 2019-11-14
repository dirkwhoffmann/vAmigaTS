	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
; Configuring the test case
BLIT_ABCD           equ 5

BLIT_LF_MINTERM		equ $ca
BLIT_A_SOURCE_SHIFT	equ 0
BLIT_DEST		    equ $100
BLIT_SRCC	    	equ $200
BLIT_SRCB	    	equ $400
BLIT_SRCA	    	equ $800
BLIT_ASHIFTSHIFT	equ 12
BLIT_BLTCON1		equ 0

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
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL1MOD(a6)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL2MOD(a6)

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
	move.w #(BLIT_ABCD<<8|BLIT_LF_MINTERM|BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT),BLTCON0(A6)
	move.w #BLIT_BLTCON1,BLTCON1(a6) 
	move.l #$ffffffff,BLTAFWM(a6)   	; no masking of first/last word
	move.w #0,BLTAMOD(a6)	        	; A modulo=bytes to skip between lines
	move.w #0,BLTBMOD(a6)	        	; B modulo=bytes to skip between lines
	move.w #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTCMOD(a6)	; C modulo
	move.w #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTDMOD(a6)	; D modulo
	move.l #emojiMask,BLTAPTH(a6)	    ; mask bitplane
	move.l #emoji,BLTBPTH(a6)	        ; bob bitplane
	move.l #bitplanes+BOB_XPOS_BYTES+(SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*BOB_YPOS),BLTCPTH(a6) ; background top left corner
	move.l #emoji,BLTDPTH(a6) ; destination top left corner
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
	move.w	#$70,INTREQ(a5)
	movem.l	(sp)+,d0-a6
	rte

copper:

    ; Enable 0 bitplanes
	dc.w    BPLCON0, (0<<12)|$200

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

    ;
    ; Perform blits with different sizes
	;
	dc.w	$3039,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (1)<<6|(1)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$3239,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (1)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$3439,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(1)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

 	dc.w	$3639,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$3839,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$3A39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$3C39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$3E39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$4039,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$4239,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$4439,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$4639,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$4839,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$4A39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(6)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$4C39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$4E39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(6)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$5039,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(7)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

  ;
  ; Enable 5 bitplanes
  ;

	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$200

	dc.w	$7039,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (1)<<6|(1)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$7239,$FFFE ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (1)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$7439,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (2)<<6|(1)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

 	dc.w	$7639,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (2)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$7839,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (2)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$7A39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (3)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$7C39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (3)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$7E39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (3)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$8039,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (4)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$8239,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (4)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$8439,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (4)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$8639,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (5)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$8839,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (5)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$8A39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (5)<<6|(6)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$8C39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (6)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$8E39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (6)<<6|(6)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$9039,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (6)<<6|(7)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000


	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe	

bitplanes:
	ds.b    51200,$00

emoji:
	incbin	"out/emoji.bin"
	ds.b    128,$00

emojiMask:	
	incbin	"out/emoji-mask.bin"
	ds.b    128,$00