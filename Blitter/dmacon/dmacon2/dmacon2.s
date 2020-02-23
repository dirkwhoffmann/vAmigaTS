	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
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

	lea	level3IrqHandler(pc),a3 ; Install handler for level 3 IRQs
 	move.l	a3,LVL3_INT_VECTOR
	lea	level4IrqHandler(pc),a3 ; Install handler for level 4 IRQs
 	move.l	a3,LVL4_INT_VECTOR
	lea	level5IrqHandler(pc),a3 ; Install handler for level 5 IRQs
 	move.l	a3,LVL5_INT_VECTOR

	;; Interrupts
	move.w	#$C8A0,INTENA(a6)   ; Enable RBF (5), AUD0 (4), VERTB (3) IRQ

	;; Copper
	lea	copper(pc),a0           ; Get pointer to Copper list
	move.l	a0,COP1LC(a6)       ; Write pointer to Copper location register 1
 	move.w  COPJMP1(a6),d0      ; Jump to the first Copper list

	;; DMA
	move.w	#$7FFF,DMACON(a6)   ; Disable all DMA
	move.w	#$83C0,DMACON(a6)   ; Set DMAEN, BPLEN, COPEN, BLTEN
	; move.w	#$87C0,DMACON(a6)   ; Set BLTPRI, DMAEN, BPLEN, COPEN, BLTEN

.mainLoop:
	bra.b	.mainLoop

level3IrqHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	bne.s	.verticalBlank
	jmp .checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; Clear interrupt bit	

	move.w regvalue,d0              ; Read stored value of test register

.test0:
	lea	bit0(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #0,d0
	beq.s .test1
	move.w #$CCC,(a0)

.test1:
	lea	bit1(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #1,d0
	beq.s .test2
	move.w #$CCC,(a0)

.test2:
	lea	bit2(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #2,d0
	beq.s .test3
	move.w #$CCC,(a0)

.test3:
	lea	bit3(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #3,d0
	beq.s .test4
	move.w #$CCC,(a0)

.test4:
	lea	bit4(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #4,d0
	beq.s .test5
	move.w #$CCC,(a0)

.test5:
	lea	bit5(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #5,d0
	beq.s .test6
	move.w #$CCC,(a0)

.test6:
	lea	bit6(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #6,d0
	beq.s .test7
	move.w #$CCC,(a0)

.test7:
	lea	bit7(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #7,d0
	beq.s .test8
	move.w #$CCC,(a0)

.test8:
	lea	bit8(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #8,d0
	beq.s .test9
	move.w #$CCC,(a0)

.test9:
	lea	bit9(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #9,d0
	beq.s .test10
	move.w #$CCC,(a0)

.test10:
	lea	bit10(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #10,d0
	beq.s .test11
	move.w #$CCC,(a0)

.test11:
	lea	bit11(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #11,d0
	beq.s .test12
	move.w #$CCC,(a0)

.test12:
	lea	bit12(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #12,d0
	beq.s .test13
	move.w #$CCC,(a0)

.test13:
	lea	bit13(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #13,d0
	beq.s .test14
	move.w #$CCC,(a0)

.test14:
	lea	bit14(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #14,d0
	beq.s .test15
	move.w #$CCC,(a0)

.test15:
	lea	bit15(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #15,d0
	beq.s .resetBitplanePointers
	move.w #$CCC,(a0)

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
	movem.l	(sp)+,d0-a6
	rte

blitWait:
	tst DMACONR(a6)		;for compatibility
.waitblit:
	btst #6,DMACONR(a6)
	bne.s .waitblit
	rts

;; Perform blit
level4IrqHandler:
	movem.l	d0-a6,-(sp)

	lea	CUSTOM,a6
	bsr blitWait
	move.w #$FF0,COLOR00(a6)
	move.w #(BLIT_ABCD<<8|BLIT_LF_MINTERM|BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT),BLTCON0(A6)
	move.w #BLIT_BLTCON1,BLTCON1(a6) 
	move.l #$ffffffff,BLTAFWM(a6)   	; no masking of first/last word
	move.w #0,BLTAMOD(a6)	        	; A modulo=bytes to skip between lines
	move.w #0,BLTBMOD(a6)	        	; B modulo=bytes to skip between lines
	move.w #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTCMOD(a6)	; C modulo
	move.w #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTDMOD(a6)	; D modulo
	move.l #bitplanes,BLTAPTH(a6)	    ; mask bitplane
	move.l #bitplanes,BLTBPTH(a6)	    ; bob bitplane
	move.l #bitplanes+BOB_XPOS_BYTES+(SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*BOB_YPOS),BLTCPTH(a6) ; background top left corner
	move.l #bitplanes+BOB_XPOS_BYTES+(SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*BOB_YPOS),BLTDPTH(a6) ; destination top left corner
	move.w #(BOB_HEIGHT*SCREEN_BIT_DEPTH)<<6|(BOB_WIDTH_WORDS),BLTSIZE(a6) ; Start Blitter

	move.w	#$0080,INTREQ(a6)	; clear interrupt bit	

	movem.l	(sp)+,d0-a6
	rte

;; Record register value
level5IrqHandler:
	;movem.l	d0-a6,-(sp)

	;lea	CUSTOM,a6

	move.w DMACONR(a6),a0       ; Read DMACONR 
	move.w a0,regvalue          ; Store it for the VBLANK handler
	move.w	#$0800,INTREQ(a6)	; clear interrupt bit	

	move.w #$00F,COLOR00(a6)
	;movem.l	(sp)+,d0-a6
	rte

regvalue: 
	dc.w    $0000

copper:
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPLCON0,$1200
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"copper-colors.s"

	; dc.w    BPLCON2, $0B
	
	; First color block

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$30D9,$FFFE  ; WAIT 
bit15:
	dc.w	COLOR00, $000

	dc.w	$3401,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$34D9,$FFFE  ; WAIT 
bit14:
	dc.w	COLOR00, $000

	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$38D9,$FFFE  ; WAIT 
bit13:
	dc.w	COLOR00, $000

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$3CD9,$FFFE  ; WAIT 
bit12:
	dc.w	COLOR00, $000

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$40D9,$FFFE  ; WAIT 
bit11:
	dc.w	COLOR00, $000

	dc.w	$4401,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$44D9,$FFFE  ; WAIT 
bit10:
	dc.w	COLOR00, $000

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$48D9,$FFFE  ; WAIT 
bit9:
	dc.w	COLOR00, $000

	dc.w	$4C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$4CD9,$FFFE  ; WAIT 
bit8:
	dc.w	COLOR00, $000

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$50D9,$FFFE  ; WAIT 
bit7:
	dc.w	COLOR00, $000

	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$54D9,$FFFE  ; WAIT 
bit6:
	dc.w	COLOR00, $000

	dc.w	$5801,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$58D9,$FFFE  ; WAIT 
bit5:
	dc.w	COLOR00, $000

	dc.w	$5C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$5CD9,$FFFE  ; WAIT 
bit4:
	dc.w	COLOR00, $000

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$60D9,$FFFE  ; WAIT 
bit3:
	dc.w	COLOR00, $000

	dc.w	$6401,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$64D9,$FFFE  ; WAIT 
bit2:
	dc.w	COLOR00, $000

	dc.w	$6801,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$68D9,$FFFE  ; WAIT 
bit1:
	dc.w	COLOR00, $000

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$6CD9,$FFFE  ; WAIT 
bit0:
	dc.w	COLOR00, $000

	dc.w	$7001,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$70D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

    ; Trigger Blitter operation
	dc.w    $A201,$FFFE  ; WAIT
	dc.w	COLOR00, $0F0
	dc.w    INTREQ, $8080 ; Level 4 interrupt

	; Record contents of DMACON0 after the blit has been finished
	dc.w    $F401,$FFFE
	dc.w	COLOR00, $F00
	dc.w    INTREQ, $8800 ; Level 5 interrupt

	; WAIT until Blitter is finished (BFD = 0)
	dc.w    $A401,$7FFE  
	dc.w	COLOR00, $000

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,0
	