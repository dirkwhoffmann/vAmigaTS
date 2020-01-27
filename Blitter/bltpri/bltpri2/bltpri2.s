	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAAPRA             equ $BFE001	
CIABPRB             equ $BFD100	
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

BOB_WIDTH 			equ 64
BOB_HEIGHT			equ 64
BOB_WIDTH_BYTES		equ BOB_WIDTH/8
BOB_WIDTH_WORDS		equ BOB_WIDTH/16
BOB_XPOS			equ 64
BOB_YPOS			equ 8	
BOB_XPOS_BYTES		equ (BOB_XPOS)/8	
	
entry:
	; Load OCS base address into a1
	lea CUSTOM,a1
	lea CUSTOM,a6 

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)

	; Install interrupt handlers
	lea	level4InterruptHandler(pc),a2
 	move.l	a2,LVL4_INT_VECTOR
	lea	level6InterruptHandler(pc),a2
 	move.l	a2,LVL6_INT_VECTOR

	include "out/image-palette.s"
	
	;; Set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a1)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a1)

	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a1)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a1)
	
	move.w	#(SCREEN_BIT_DEPTH<<12)|$200,BPLCON0(a1)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL1MOD(a1)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL2MOD(a1)

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

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable Copper DMA
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a1)
	; move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),DMACON(a1)

	; Set BLTPRI bit
	move.w  #$8400,DMACON(a1)

	; Enable level 4 and level 6 interrupts 
	move.w	#$E080,INTENA(a1) 

;
; Main loop
;

main: 
	jsr     synccpu

   	move.w  #8000,d3
loop1:
	dbra    d3,loop1
   	move.w  #300,d3
	move.w  #$888,d4
	move.w  #$000,d5
loop2:
	move.w  d4,COLOR00(a1)
	move.w  d5,COLOR00(a1)
    dbra    d3,loop2
	bra.s   main

;
; Running the Blitter
;

blitWait:
	tst DMACONR(a6)		; for compatibility
.waitblit:
	btst #6,DMACONR(a6)
	bne.s .waitblit
	rts

waitBlitIdle:
	btst #14,DMACONR(a6)
	bne.s waitBlitIdle
	rts

delayLoop:
	move.l #$010000,D5
.delay:
	subq.l #1,D5
	bne.s .delay
	rts

BLIT_LF_MINTERM		equ $ca
BLIT_A_SOURCE_SHIFT	equ 0
BLIT_DEST		    equ $100
BLIT_SRCC	    	equ $200
BLIT_SRCB	    	equ $400
BLIT_SRCA	    	equ $800
BLIT_ASHIFTSHIFT	equ 12   ;Bit index of ASH? bits
BLIT_BLTCON1		equ 0    ;BSH?=0, DOFF=0, EFE=0, IFE=0, FCI=0, DESC=0, LINE=0
	
BLIT_ABCD           equ 15

doblit:	
	
	bsr blitWait
	move.w  #$F0F,$DFF180 
	move.w #(BLIT_ABCD<<8|BLIT_LF_MINTERM|BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT),BLTCON0(A6)
	move.w  #$333,$DFF180 
	move.w #BLIT_BLTCON1,BLTCON1(a6) 
	move.w  #$F0F,$DFF180 
	move.l #$ffffffff,BLTAFWM(a6) 	; no masking of first/last word
	move.w  #$333,$DFF180 
	move.w #0,BLTAMOD(a6)	      	; A modulo=bytes to skip between lines
	move.w  #$F0F,$DFF180 
	move.w #0,BLTBMOD(a6)	      	; B modulo=bytes to skip between lines
	move.w  #$333,$DFF180 
	move.w #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTCMOD(a6)	;C modulo
	move.w  #$F0F,$DFF180 
	move.w #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTDMOD(a6)	;D modulo
	move.w  #$333,$DFF180 
	move.l #emojiMask,BLTAPTH(a6)	; mask bitplane
	move.w  #$F0F,$DFF180 
	move.l #emoji,BLTBPTH(a6)	; bob bitplane
	move.w  #$333,$DFF180 
	move.l #bitplanes+BOB_XPOS_BYTES+(SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*BOB_YPOS),BLTCPTH(a6) ;background top left corner
	move.w  #$F0F,$DFF180 
	move.l #bitplanes+BOB_XPOS_BYTES+(SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*BOB_YPOS),BLTDPTH(a6) ;destination top left corner
	move.w  #$0FF,COLOR00(a6)
	move.w #12,BLTSIZE(a6)	
	move.w  #$00F,COLOR00(a6)
	rts

;
; IRQ handlers
;

level6InterruptHandler:

	; DEPRECATED
	move.w  #$F0F,$DFF180
	lea     $DFF006,a4
sync:
	andi.w  #$7,(a4)       ; 16 cycles
	bne     sync           ; 10 cycles
	move.w  #$000,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	rte

level4InterruptHandler:
	move.w  #$0080,$DFF09C ; Acknowledge level 4 interrupt
	jsr doblit
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 
	move.w  #$FF0,$DFF180 
	move.w  #$F00,$DFF180 

	move.w  #$000,$DFF180 
	rte

synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached the middle of a frame
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$3000,d2
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
	cmp.w   #$4000,d2
	bne     .synccpu4
	move.w  #$000,COLOR00(a1)  
	rts

copper:
	;; bitplane pointers must be first else poking addresses will be incorrect
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
	dc.w    BPLCON0, $200 ; Disable all bitplanes again

	; Draw reference lines
	dc.w    $4E39, $FFFE         ; WAIT
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

	; Perform the Blit operation
	dc.w    $5051,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00,$0F0
	dc.w    INTREQ, $8080 ; Level 4 interrupt

    ; Enable all bitplanes
	dc.w    $C001,$FFFE ; WAIT
	; dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$200

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe	

bitplanes:
    incbin  "out/image.bin"
     ds.b    128,$00

emoji:
	incbin	"out/emoji.bin"
	ds.b    128,$00

emojiMask:	
	incbin	"out/emoji-mask.bin"
	ds.b    128,$00