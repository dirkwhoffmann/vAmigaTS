	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
BLIT_ABCD           equ $7

BLIT_LF_MINTERM		equ $ca
BLIT_A_SOURCE_SHIFT	equ 0
BLIT_DEST		    equ $100
BLIT_SRCC	    	equ $200
BLIT_SRCB	    	equ $400
BLIT_SRCA	    	equ $800
BLIT_ASHIFTSHIFT	equ 12
BLIT_BLTCON1		equ 0

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
	lea	irq1(pc),a2
 	move.l	a2,LVL1_INT_VECTOR
	lea	irq2(pc),a2
 	move.l	a2,LVL2_INT_VECTOR
	lea	irq3(pc),a2
 	move.l	a2,LVL3_INT_VECTOR
	lea	irq4(pc),a2
 	move.l	a2,LVL4_INT_VECTOR
	lea	irq5(pc),a2
 	move.l	a2,LVL5_INT_VECTOR
	lea	irq6(pc),a2
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
	move.w  #$8003,COPCON(a6)   ; Allow Copper to write Blitter registers

	; Enable Copper DMA
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),DMACON(a1)
	; move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),DMACON(a1)

	; Set BLTPRI bit
	move.w  #$8400,DMACON(a1)

	; Enable interrupts 
	move.w	#$E8AC,INTENA(a1) 
	; move.w	#$C020,INTENA(a1) 

;
; Main loop
;

main: 
	jsr     synccpu

   	move.w  #700,d3
loop1:
	dbra    d3,loop1
   	move.w  #1000,d3
	move.w  #$88F,d4
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
	tst     DMACONR(a1)		; for compatibility
.waitblit:
	btst    #6,DMACONR(a1)
	bne.s   .waitblit
	rts
	
prepareblit:	
	movem.l d0-a6,-(sp)
	bsr     blitWait
	move.w  #(BLIT_ABCD<<8|BLIT_LF_MINTERM|BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT),BLTCON0(a1)
	move.w  #BLIT_BLTCON1,BLTCON1(a1) 
	move.l  #$ffffffff,BLTAFWM(a1) 
	move.w #0,BLTAMOD(a1)
	move.w #0,BLTBMOD(a1)
	move.w #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTCMOD(a1)
	move.w #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTDMOD(a1)
	move.l #emojiMask,BLTAPTH(a1)
	move.l #emoji,BLTBPTH(a1)
	move.l #bitplanes+BOB_XPOS_BYTES+(SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*BOB_YPOS),BLTCPTH(a1)
	move.l #emoji,BLTDPTH(a1)
	movem.l (sp)+,d0-a6
	rts

;
; IRQ handlers
;

irq1:
	move.w  #$0004,INTREQ(a1)
	move.w  #$888,COLOR00(a1)
	move.w  #5<<6|5,BLTSIZE(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

irq2:
	move.w  #$0008,INTREQ(a1)
	move.w  #$888,COLOR00(a1)
	move.w  #5<<6|6,BLTSIZE(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

irq3:
	move.w  #$0020,INTREQ(a1)
	jsr prepareblit
	rte

irq4:
	move.w  #$0080,INTREQ(a1)
	move.w  #$888,COLOR00(a1)
	move.w  #5<<6|7,BLTSIZE(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

irq5:
	move.w  #$0800,INTREQ(a1)
	move.w  #$888,COLOR00(a1)
	move.w  #6<<6|7,BLTSIZE(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

irq6:
	move.w  #$2000,INTREQ(a1)
	move.w  #$888,COLOR00(a1)
	move.w  #7<<6|7,BLTSIZE(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached the top of a frame
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
	; dc.w    BPLCON0, $200 ; Disable all bitplanes again

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

   ;
    ; Perform blits with different sizes
	;
	dc.w	$5539,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (1)<<6|(1)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$5739,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (1)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$5939,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(1)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

 	dc.w	$5B39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00
	
	dc.w	$5D39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00
	
	dc.w	$5F39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$6139,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$6339,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00
	
	dc.w	$6539,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$6739,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$6939,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$6B39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$6D39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$6F39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(6)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$7139,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$7339,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(6)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$7539,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(7)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00
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