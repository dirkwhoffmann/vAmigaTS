	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Configuring the test case
BLIT_ABCD           equ 15

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

	; bsr.s 	prepareblit         ; Prepare the Blitter

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
	move.w	#$8040,DMACON(a1)   ; Blitter DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA
	move.w	#$8200,DMACON(a1)   ; DMA enable
	move.w	#$8400,DMACON(a1)   ; BLTPRI

	; Enable interrupts
	move.w	#$C024,INTENA(a1)  

.mainLoop:
	btst    #$6,DMACONR(a1)
	bne     .mainLoop           ; Branch if bit is 1 (Blitter busy)
    move.w  #$000,COLOR00(a1)
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
	move.w	#$04,INTREQ(a1)   ; Acknowledge
	jsr     prepareblit
	rte

irq3:
	move.w  #$000,COLOR00(a1)
	move.w	#$20,INTREQ(a1)   ; Acknowledge

synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached the middle of a frame
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$1000,d2
	bne     .loop
	and     #1,VPOSR(a1)
	bne     .loop

	; Sync horizontally
	move.w  #$F0F,COLOR00(a1)
.synccpu1:
	andi.w  #$F,(a3)          ; 16 cycles
	bne     .synccpu1         ; 10 cycles
	move.w  #$606,COLOR00(a1)
.synccpu2:
	andi.w  #$1F,(a3)         ; 16 cycles
	bne     .synccpu2         ; 10 cycles
	move.w  #$A0A,COLOR00(a1)
.synccpu3:
	andi.w  #$FF,(a3)         ; 16 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	bne     .synccpu3         ; 10 cycles (if taken)

	; Adust horizontally
  	moveq #10,d2
.adjust:
    dbra d2,.adjust

	; Sync vertically
.synccpu4:
	nop 
	move.w  #$404,COLOR00(a1)
	ds.w    96,$4E71          ; NOPs to keep the horizontal position in each iteration
	move.w  (a3),d2     
	move.w  #$F0F,COLOR00(a1)  
	and     #$FF00,d2
	cmp.w   #$2000,d2
	bne     .synccpu4
	move.w  #$000,COLOR00(a1)  


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
	
  	dc.w    $4039, $FFFE         ; WAIT
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

	dc.w    $4939,$FFFE
	dc.w    BPLCON0, (0<<12)|$200

	dc.w	$5039,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (1)<<6|(1)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

	dc.w	$5239,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (1)<<6|(2)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

	dc.w	$5439,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (2)<<6|(1)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

 	dc.w	$5639,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (2)<<6|(2)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	
	dc.w	$5839,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (2)<<6|(3)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	
	dc.w	$5A39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (3)<<6|(2)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

	dc.w	$5C39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (3)<<6|(3)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

	dc.w	$5E39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (3)<<6|(4)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00
	
	dc.w	$6039,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (4)<<6|(3)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

	dc.w	$6239,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (4)<<6|(4)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

	dc.w	$6439,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (4)<<6|(5)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

	dc.w	$6639,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (5)<<6|(4)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

	dc.w	$6839,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (5)<<6|(5)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

	dc.w	$6A39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (5)<<6|(6)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

	dc.w	$6C39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (6)<<6|(5)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

	dc.w	$6E39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (6)<<6|(6)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

	dc.w	$7039,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (6)<<6|(7)
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $F00

  ;
  ; Enable 2 bitplanes
  ;

	dc.w    $7939,$FFFE
	dc.w    BPLCON0, (2<<12)|$200

	dc.w	$8039,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (1)<<6|(1)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$8239,$FFFE ; WAIT 
	dc.w    BLTSIZE, (1)<<6|(2)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$8439,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (2)<<6|(1)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

 	dc.w	$8639,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (2)<<6|(2)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$8839,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (2)<<6|(3)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$8A39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (3)<<6|(2)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$8C39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (3)<<6|(3)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$8E39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (3)<<6|(4)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$9039,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (4)<<6|(3)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$9239,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (4)<<6|(4)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$9439,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (4)<<6|(5)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$9639,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (5)<<6|(4)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$9839,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (5)<<6|(5)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$9A39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (5)<<6|(6)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$9C39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (6)<<6|(5)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$9E39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (6)<<6|(6)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

	dc.w	$A039,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (6)<<6|(7)
	dc.w	COLOR00, $F00
	dc.w	COLOR00, $FF0

   ;
   ; Enable 3 bitplanes
   ;

	dc.w	$A939,$FFFE  ; WAIT 
	dc.w    BPLCON0, (3<<12)|$200

	dc.w	$B039,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (1)<<6|(1)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$B239,$FFFE ; WAIT 
	dc.w    BLTSIZE, (1)<<6|(2)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$B439,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (2)<<6|(1)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

 	dc.w	$B639,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (2)<<6|(2)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$B839,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (2)<<6|(3)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$BA39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (3)<<6|(2)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$BC39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (3)<<6|(3)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$BE39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (3)<<6|(4)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$C039,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (4)<<6|(3)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$C239,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (4)<<6|(4)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$C439,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (4)<<6|(5)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$C639,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (5)<<6|(4)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$C839,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (5)<<6|(5)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$CA39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (5)<<6|(6)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$CC39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (6)<<6|(5)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

	dc.w	$CE39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (6)<<6|(6)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF
	
	dc.w	$D039,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (6)<<6|(7)
	dc.w	COLOR00, $F0F
	dc.w	COLOR00, $0FF

   ;
   ; Enable some bitplanes
   ;

	dc.w	$D939,$FFFE  ; WAIT 
	dc.w    BPLCON0, (5<<12)|$200

	dc.w	$E039,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (1)<<6|(1)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

	dc.w	$E239,$FFFE ; WAIT 
	dc.w    BLTSIZE, (1)<<6|(2)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

	dc.w	$E439,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (2)<<6|(1)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

 	dc.w	$E639,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (2)<<6|(2)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA
	
	dc.w	$E839,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (2)<<6|(3)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA
	
	dc.w	$EA39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (3)<<6|(2)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

	dc.w	$EC39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (3)<<6|(3)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

	dc.w	$EE39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (3)<<6|(4)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA
	
	dc.w	$F039,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (4)<<6|(3)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

	dc.w	$F239,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (4)<<6|(4)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

	dc.w	$F439,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (4)<<6|(5)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

	dc.w	$F639,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (5)<<6|(4)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

	dc.w	$F839,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (5)<<6|(5)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

	dc.w	$FA39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (5)<<6|(6)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

	dc.w	$FC39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (6)<<6|(5)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

	dc.w	$FE39,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (6)<<6|(6)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.w	$0039,$FFFE  ; WAIT 
	dc.w    BLTSIZE, (6)<<6|(7)
	dc.w	COLOR00, $0FF
	dc.w	COLOR00, $AAA

	dc.w    BPLCON0, (0<<12)|$200

	dc.l    $fffffffe	

bitplanes:
	ds.b    51200,$00

emoji:
;	incbin	"out/emoji.bin"
	ds.b    128,$00

emojiMask:	
;	incbin	"out/emoji-mask.bin"
	ds.b    128,$00
