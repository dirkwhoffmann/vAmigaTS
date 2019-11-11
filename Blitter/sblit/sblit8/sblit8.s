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

BOB_WIDTH 		equ 64
BOB_HEIGHT		equ 64
BOB_WIDTH_BYTES		equ BOB_WIDTH/8
BOB_WIDTH_WORDS		equ BOB_WIDTH/16
BOB_XPOS		equ 64
BOB_YPOS		equ 8	
BOB_XPOS_BYTES		equ (BOB_XPOS)/8	
	
entry:
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	;; custom chip base globally in a6
	lea 	CUSTOM,a6

	move	#$7ff,DMACON(a6)	; disable all dma
	move	#$7fff,INTENA(a6)	; disable all interrupts
	move.b  #$7F,$BFDD00  ; Disable CIA B interrupts
	move.b  #$7F,$BFED01  ; Disable CIA A interrupts


	include "out/image-palette.s"
	
	;; set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a6)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a6)

	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a6)
	
	move.w	#(SCREEN_BIT_DEPTH<<12)|$200,BPLCON0(a6)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL1MOD(a6)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL2MOD(a6)

	;; install copper list, then enable dma and selected interrupts
	lea	copper(pc),a0
	move.w  #$8003,COPCON(a6) ; Allow Copper to write Blitter registers
	move.l	a0,COP1LC(a6)
 	move.w  COPJMP1(a6),d0
	; move.w	#(DMAF_BLITTER|DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)
	move.w	#$87C0,DMACON(a6) ; Set BLTPRI, DMAEN, BPLEN, COPEN, BLTEN
	move.w	#(INTF_SETCLR|INTF_INTEN|INTF_VERTB|INTF_COPER|INTF_EXTER),INTENA(a6)

	bsr.s 	doblit
	
.mainLoop:
	move.w 	#$02a,d0		;wait for EOFrame
	bsr.s	 waitRaster
	bra.s	.mainLoop

waitRaster:	;wait for rasterline d0.w. Modifies d0-d2/a0.
	move.l #$1ff00,d2
	lsl.l #8,d0
	and.l d2,d0
	lea $dff004,a0
.wr:	move.l (a0),d1
	and.l d2,d1
	cmp.l d1,d0
	bne.s .wr
	rts	

blitWait:
	tst DMACONR(a6)		;for compatibility
.waitblit:
	btst #6,DMACONR(a6)
	bne.s .waitblit
	rts

;; BLTCON? configuration
;; http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node011C.html
;; blitter logic function minterm truth table
;; fill in D column for desired function
;;       A(mask) B(bob)  C(bg)   D(dest)
;;       -       -       -       - 
;;       0       0       0       0 
;;       0       0       1       1 
;;       0       1       0       0 
;;       0       1       1       1 
;;       1       0       0       0 
;;       1       0       1       0 
;;       1       1       0       1 
;;       1       1       1       1
;; read D column from bottom up = 11001010 = $ca
;; this is used in the LF? bits
BLIT_LF_MINTERM		equ $ca
BLIT_A_SOURCE_SHIFT	equ 0
BLIT_DEST		    equ $100
BLIT_SRCC	    	equ $200
BLIT_SRCB	    	equ $400
BLIT_SRCA	    	equ $800
BLIT_ASHIFTSHIFT	equ 12   ;Bit index of ASH? bits
BLIT_BLTCON1		equ 0    ;BSH?=0, DOFF=0, EFE=0, IFE=0, FCI=0, DESC=0, LINE=0
	
BLIT_ABCD            equ 8
doblit:	
	movem.l d0-a6,-(sp)
	; bsr blitWait
	; move.w #(BLIT_SRCA|BLIT_SRCB|BLIT_SRCC|BLIT_DEST|BLIT_LF_MINTERM|BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT),BLTCON0(A6)
	move.w #(BLIT_ABCD<<8|BLIT_LF_MINTERM|BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT),BLTCON0(A6)
	move.w #BLIT_BLTCON1,BLTCON1(a6) 
	move.l #$ffffffff,BLTAFWM(a6) 	; no masking of first/last word
	move.w #0,BLTAMOD(a6)	      	; A modulo=bytes to skip between lines
	move.w #0,BLTBMOD(a6)	      	; B modulo=bytes to skip between lines
	move.w #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTCMOD(a6)	;C modulo
	move.w #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTDMOD(a6)	;D modulo
	move.l #emojiMask,BLTAPTH(a6)	; mask bitplane
	move.l #emoji,BLTBPTH(a6)	; bob bitplane
	move.l #bitplanes+BOB_XPOS_BYTES+(SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*BOB_YPOS),BLTCPTH(a6) ;background top left corner
	move.l #bitplanes+BOB_XPOS_BYTES+(SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*BOB_YPOS),BLTDPTH(a6) ;destination top left corner
	; move.w #(BOB_HEIGHT*SCREEN_BIT_DEPTH)<<6|(BOB_WIDTH_WORDS),BLTSIZE(a6)	;rectangle size, starts blit
	movem.l (sp)+,d0-a6
	rts

;.bltcount:
;	dc.w $0

level3InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.w	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; Clear interrupt bit	
	move.w  #$000,COLOR00(a5)       ; Clear background color
	jsr doblit

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
	dc.w	BPLCON0, $200

    ; Perform blit (emoji)
	dc.w	$3051,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (BOB_HEIGHT*SCREEN_BIT_DEPTH)<<6|(BOB_WIDTH_WORDS)
	dc.w    COLOR00, $0F0
	dc.w    $3051,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000

    ; Perform blit again with smallest size 1x1
	dc.w	$B051,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (1)<<6|(1)
	dc.w    COLOR00, $0F0
	dc.w    $B051,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000

  ; Perform blit again with size 1x2
	dc.w	$B251,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (1)<<6|(2)
	dc.w    COLOR00, $0F0
	dc.w    $B251,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000

 ; Perform blit again with size 1x2
	dc.w	$B451,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (2)<<6|(1)
	dc.w    COLOR00, $0F0
	dc.w    $B451,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000
	
	; Perform blit again with size 2x2
	dc.w	$B651,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BLTSIZE, (2)<<6|(2)
	dc.w    COLOR00, $0F0
	dc.w    $B651,$7FFE  ; WAIT until Blitter is finished (BFD = 0)
	dc.w    COLOR00, $F00
	dc.w    COLOR00, $000
	
    ; Enable all bitplanes (to show the emoji)
	dc.w    $C001,$FFFE ; WAIT
	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$200

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe	

bitplanes:
	incbin	"out/image.bin"
	ds.b    128,$00

emoji:
	incbin	"out/emoji.bin"
	ds.b    128,$00

emojiMask:	
	incbin	"out/emoji-mask.bin"
	ds.b    128,$00