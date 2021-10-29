	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Configuring the test case
BLIT_ABCD           equ 6

BLIT_LF_MINTERM		equ $ca
BLIT_A_SOURCE_SHIFT	equ 0
BLIT_DEST		    equ $100
BLIT_SRCC	    	equ $200
BLIT_SRCB	    	equ $400
BLIT_SRCA	    	equ $800
BLIT_ASHIFTSHIFT	equ 12
BLIT_BLTCON1		equ 0

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR	    equ $68
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

MAIN:	
	; Load OCS base address
	lea CUSTOM,a1

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
	
	; Set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a1)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a1)

	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a1)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a1)
	
	move.w	#(SCREEN_BIT_DEPTH<<12)|$200,BPLCON0(a1)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL1MOD(a1)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL2MOD(a1)

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
	move.w #(BLIT_ABCD<<8|BLIT_LF_MINTERM|BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT),BLTCON0(A6)
	move.w #BLIT_BLTCON1,BLTCON1(a1) 
	move.l #$ffffffff,BLTAFWM(a1)   	; no masking of first/last word
	move.w #0,BLTAMOD(a1)	        	; A modulo=bytes to skip between lines
	move.w #0,BLTBMOD(a1)	        	; B modulo=bytes to skip between lines
	move.w #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTCMOD(a1)	; C modulo
	move.w #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTDMOD(a1)	; D modulo
	move.l #emojiMask,BLTAPTH(a1)	    ; mask bitplane
	move.l #emoji,BLTBPTH(a1)	        ; bob bitplane
	move.l #bitplanes+BOB_XPOS_BYTES+(SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*BOB_YPOS),BLTCPTH(a1) ; background top left corner
	move.l #emoji,BLTDPTH(a1) ; destination top left corner
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

    ;
    ; Perform blits with different sizes
	;

	dc.w    $2939,$FFFE
	dc.w    BPLCON0, (0<<12)|$200

	dc.w	$3039,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (1)<<6|(1)

	dc.w	$3239,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (1)<<6|(2)

	dc.w	$3439,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(1)

 	dc.w	$3639,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(2)
	
	dc.w	$3839,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(3)
	
	dc.w	$3A39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(2)

	dc.w	$3C39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(3)

	dc.w	$3E39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(4)
	
	dc.w	$4039,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(3)

	dc.w	$4239,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(4)

	dc.w	$4439,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(5)

	dc.w	$4639,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(4)

	dc.w	$4839,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(5)

	dc.w	$4A39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(6)

	dc.w	$4C39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(5)

	dc.w	$4E39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(6)

	dc.w	$5039,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(7)

  ;
  ; Enable 2 bitplanes
  ;

	dc.w    $5939,$FFFE
	dc.w    BPLCON0, (2<<12)|$200

	dc.w	$6039,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (1)<<6|(1)

	dc.w	$6239,$FFFE ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (1)<<6|(2)

	dc.w	$6439,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (2)<<6|(1)

 	dc.w	$6639,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (2)<<6|(2)

	dc.w	$6839,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (2)<<6|(3)

	dc.w	$6A39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (3)<<6|(2)

	dc.w	$6C39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (3)<<6|(3)

	dc.w	$6E39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (3)<<6|(4)

	dc.w	$7039,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (4)<<6|(3)

	dc.w	$7239,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (4)<<6|(4)

	dc.w	$7439,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (4)<<6|(5)

	dc.w	$7639,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (5)<<6|(4)

	dc.w	$7839,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (5)<<6|(5)

	dc.w	$7A39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (5)<<6|(6)

	dc.w	$7C39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (6)<<6|(5)

	dc.w	$7E39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (6)<<6|(6)

	dc.w	$8039,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (6)<<6|(7)

   ;
   ; Enable 3 bitplanes
   ;

	dc.w	$8939,$FFFE  ; WAIT 
	dc.w    BPLCON0, (3<<12)|$200

	dc.w	$9039,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (1)<<6|(1)

	dc.w	$9239,$FFFE ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (1)<<6|(2)

	dc.w	$9439,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (2)<<6|(1)

 	dc.w	$9639,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (2)<<6|(2)

	dc.w	$9839,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (2)<<6|(3)

	dc.w	$9A39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (3)<<6|(2)

	dc.w	$9C39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (3)<<6|(3)

	dc.w	$9E39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (3)<<6|(4)

	dc.w	$A039,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (4)<<6|(3)

	dc.w	$A239,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (4)<<6|(4)

	dc.w	$A439,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (4)<<6|(5)

	dc.w	$A639,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (5)<<6|(4)

	dc.w	$A839,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (5)<<6|(5)

	dc.w	$AA39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (5)<<6|(6)

	dc.w	$AC39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (6)<<6|(5)

	dc.w	$AE39,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (6)<<6|(6)
	
	dc.w	$B039,$FFFE  ; WAIT 
	dc.w	COLOR00, $F0F
	dc.w    BLTSIZE, (6)<<6|(7)

   ;
   ; Enable some bitplanes
   ;

	dc.w	$B939,$FFFE  ; WAIT 
	dc.w    BPLCON0, (5<<12)|$200

	dc.w	$C039,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (1)<<6|(1)

	dc.w	$C239,$FFFE ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (1)<<6|(2)

	dc.w	$C439,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (2)<<6|(1)

 	dc.w	$C639,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (2)<<6|(2)
	
	dc.w	$C839,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (2)<<6|(3)
	
	dc.w	$CA39,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (3)<<6|(2)

	dc.w	$CC39,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (3)<<6|(3)

	dc.w	$CE39,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (3)<<6|(4)
	
	dc.w	$D039,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (4)<<6|(3)

	dc.w	$D239,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (4)<<6|(4)

	dc.w	$D439,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (4)<<6|(5)

	dc.w	$D639,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (5)<<6|(4)

	dc.w	$D839,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (5)<<6|(5)

	dc.w	$DA39,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (5)<<6|(6)

	dc.w	$DC39,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (6)<<6|(5)

	dc.w	$DE39,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (6)<<6|(6)

	dc.w	$E039,$FFFE  ; WAIT 
	dc.w	COLOR00, $0FF
	dc.w    BLTSIZE, (6)<<6|(7)

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe	

bitplanes:
	ds.b    51200,$00

emoji:
;	incbin	"out/emoji.bin"
	ds.b    128,$00

emojiMask:	
;	incbin	"out/emoji-mask.bin"
	ds.b    128,$00
