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

	; Enable Copper DMA
	; move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),DMACON(a1)

	; Set BLTPRI bit
	move.w  #$8400,DMACON(a1)

	; Enable interrupts 
	; move.w	#$E8AC,INTENA(a1) 

;
; Main loop
;

main: 

	; Wait until the VERTB bit is set in INTREQ
	move.w  #565,d3
.wait:
	move.w  INTREQR(a1),d4
	and.w   #$20,d4
	beq     .wait

	; Draw color stripes
.loop:
	move    #$FF0,COLOR00(a1)
	move    #$00F,COLOR00(a1)
	dbra    d3,.loop

	; Acknowledge 
	move    #$F00,COLOR00(a1)
	move    #$000,COLOR00(a1)
	move.w  #$20,INTREQ(a1)

	; Start Copper
	move.w  #(DMAF_SETCLR!DMAF_COPPER),DMACON(a1)
	move.w  COPJMP1(a1),d0

	; Sync CPU
	jsr     synccpu 

	; Disable Copper during VBLANK
	move.w  #DMAF_COPPER,DMACON(a1)

	bra     main  

;
; IRQ handlers
;

irq1:
	move.w  #$0004,INTREQ(a1)
	move.w  #$888,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

irq2:
	move.w  #$0008,INTREQ(a1)
	move.w  #$888,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

irq3:
	move.w  #$0020,INTREQ(a1)
	move.w  #$F0F,COLOR00(a1)
	move.w  #$0F0,COLOR00(a1)
	rte

irq4:
	move.w  #$0080,INTREQ(a1)
	move.w  #$888,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

irq5:
	move.w  #$0800,INTREQ(a1)
	move.w  #$888,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

irq6:
	move.w  #$2000,INTREQ(a1)
	move.w  #$888,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached the sync start line
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$E000,d2
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
	cmp.w   #$F000,d2
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

	; Draw reference lines
	dc.w    $3839, $FFFE         ; WAIT
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