	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

BLIT1COLOR          equ $808
BLIT2COLOR          equ $B0B

BLIT_LF_MINTERM		equ $ca
BLIT_A_SOURCE_SHIFT	equ 0
BLIT_DEST		    equ $100
BLIT_SRCC	    	equ $200
BLIT_SRCB	    	equ $400
BLIT_SRCA	    	equ $800
BLIT_ASHIFTSHIFT	equ 12
BLIT_BLTCON1		equ 0

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

	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable DMA and interrupts
	move.w  #$7FFF,DMACON(a1)
	move.w  #$7FFF,INTENA(a1)

	bsr blitWait 	            ; Wait until the Blitter is ready

	; Install interrupt handlers
	lea	irq1(pc),a3 
 	move.l	a3,LVL1_INT_VECTOR
	lea	irq3(pc),a3 
 	move.l	a3,LVL3_INT_VECTOR
	lea	irq4(pc),a3 
 	move.l	a3,LVL4_INT_VECTOR
	lea	irq5(pc),a3
 	move.l	a3,LVL5_INT_VECTOR

	; Enable Interrupts
	move.w	#$8004,INTENA(a1)   ; SOFT (1)
	move.w	#$8020,INTENA(a1)   ; VERTB (3)
	move.w	#$8080,INTENA(a1)   ; AUD0 (4)
	move.w	#$8800,INTENA(a1)   ; RBF (5)
	move.w	#$C000,INTENA(a1)   ; Enable

	; Setup Copper
	lea	copper(pc),a0           ; Get pointer to Copper list
	move.l	a0,COP1LC(a1)       ; Write pointer to Copper location register 1
 	move.w  COPJMP1(a1),d0      ; Jump to the first Copper list

	; Enable DMA
	move.w	#$8040,DMACON(a1)   ; Blitter DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA
	move.w	#$8200,DMACON(a1)   ; DMA enable
	; move.w	#$8400,DMACON(a1)   ; BLTPRI

.mainLoop:
	bra.b	.mainLoop

irq1: 
	move.w	#$0004,INTREQ(a1)	        ; Acknowledge
	move.w  DMACONR(a1),d5              ; Record DMACON
	rte

irq3:
	movem.l	d0-a6,-(sp)
	move.w	#$0020,INTREQ(a1)	        ; Acknowledge
	move.w d5,d0                        ; Visualize d5

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
	lea     bitplanes(pc),a1
	lea     BPL1PTH(a1),a2
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l	a1,(a2)
	lea	    SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#4,a2
	dbra	d0,.bitplaneloop
	
	movem.l	(sp)+,d0-a6
	rte

blitWait:
	tst DMACONR(a1)		;for compatibility
.waitblit:
	btst #6,DMACONR(a1)
	bne.s .waitblit
	rts

prepareBlitter:
	move.w  #$888,COLOR00(a1)
	move.w  #BLIT_BLTCON1,BLTCON1(a1) 
	move.l  #$ffffffff,BLTAFWM(a1)   	; no masking of first/last word
	move.w  #0,BLTAMOD(a1)	        	; A modulo=bytes to skip between lines
	move.w  #0,BLTBMOD(a1)	        	; B modulo=bytes to skip between lines
	move.w  #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTCMOD(a1)	; C modulo
	move.w  #SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTDMOD(a1)	; D modulo
	move.l  #bitplanes,BLTAPTH(a1)	    ; mask bitplane
	move.l  #bitplanes,BLTBPTH(a1)	    ; bob bitplane
	move.l  #bitplanes+BOB_XPOS_BYTES+(SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*BOB_YPOS),BLTCPTH(a1) ; background top left corner
	move.l  #bitplanes+BOB_XPOS_BYTES+(SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*BOB_YPOS),BLTDPTH(a1) ; destination top left corner
	move.w  #$000,COLOR00(a1)
	rts

; Perform a blit with all zeroes in BLTD (BZERO will be 1)
irq4:
	move.w	#$0080,INTREQ(a1)	        ; Acknowledge

	jsr     prepareBlitter
	move.w  #$0,BLTADAT(a1)
	move.w  #$0,BLTBDAT(a1)
	move.w  #$0,BLTCDAT(a1)
	move.w  #$0,BLTDDAT(a1)
	move.w  #(1<<8|BLIT_LF_MINTERM|BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT),BLTCON0(a1)

	lea     DMACONR(a1),a2
	move.w  #(60)<<6|(60),BLTSIZE(a1)
	move.w  (a2),d5                      ; Record DMACON

	move.w  #BLIT1COLOR,COLOR00(a1)
	rte

; Perform a blit with not all zeroes in BLTD (BZERO will be 0)
irq5:
	move.w	#$0800,INTREQ(a1)	        ; Acknowledge

	jsr     prepareBlitter
	move.w  #$FFFF,BLTADAT(a1)
	move.w  #$FFFF,BLTBDAT(a1)
	move.w  #$FFFF,BLTCDAT(a1)
	move.w  #$FFFF,BLTDDAT(a1)
	move.w  #(1<<8|BLIT_LF_MINTERM|BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT),BLTCON0(a1)
	move.w  #(60)<<6|(60),BLTSIZE(a1)
	move.w  #BLIT2COLOR,COLOR00(a1)
	rte
	
copper:
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 	
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

    ; First Blitter operation
	dc.w    $A001, $FFFE      ; WAIT
	dc.w	COLOR00, $FFF
	dc.w    INTREQ, $8080     ; Level 4 interrupt	
	dc.w    $A401, $7FFE      ; WAIT until Blitter terminates
	dc.w	COLOR00, $000

    ; Second Blitter operation
	dc.w    $D001, $FFFE      ; WAIT
	dc.w	COLOR00, $FFF
	dc.w    INTREQ, $8800     ; Level 5 interrupt
	dc.w    $D401, $7FFE      ; WAIT until Blitter terminates
	dc.w	COLOR00, $000

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,0
