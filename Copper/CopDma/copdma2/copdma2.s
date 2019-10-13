	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	;;  Copy the first Copper list to $25000
	MOVE.L  #$25000,a1 ;Point A1 at destination
	LEA     copper(pc),a2 ;Point A2 at source
COPLOOP1:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of list
	BNE     COPLOOP1	 ;Loop until entire list is moved

	;;  Copy the second Copper list to $26000
	MOVE.L  #$26000,a1 ;Point A1 at destination
	LEA     copper2(pc),a2 ;Point A2 at source
COPLOOP2:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of list
	BNE     COPLOOP2	 ;Loop until entire list is moved

	;; install copper list and enable DMA
	lea 	CUSTOM,a1
	;lea	copper2(pc),a0
	;move.l	a0,COP2LC(a1)
	; lea	copper(pc),a0
	move.w	#$0002,COP1LCH(a1)
	move.w	#$5000,COP1LCL(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	
	; Enable Copper interrupt
	move.w	#$8010,INTENA(a1)

.mainLoop:
	bra.b	.mainLoop

level3InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.s	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; clear interrupt bit	

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
	move.w	#$0FF0,COLOR00(a5)
	move.w	#$0080,DMACON(a1) ; Disable Copper DMA

	; Modify the location pointer of the first Copper list
	move.w	#$6000,COP1LCL(a1)
	move.w	#$0002,COP1LCH(a1)

	move.w	#$8080,DMACON(a1) ; Reenable Copper DMA

	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte
	
copper:
	dc.w	COLOR00, $000

	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"


    ; Set number of bitplanes
	dc.w	BPLCON0,(4<<12)|$200

    ; First color block
	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$38D9,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$40D9,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$50D9,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000
	dc.w	$5101,$FFFE  ; WAIT 

	dc.w	$5801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$58D9,$FFFE  ; WAIT 
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w	COLOR00, $000

	; Between first and second block
	dc.w	$6241,$FFFE  ; WAIT 

	; Modify the location pointer of the first Copper list
	;dc.w	COP1LCL, $6000
	;dc.w    COP1LCH, $0002

	dc.w	COLOR00, $00F

	dc.w 	INTREQ,$8010         ; Trigger Copper interrupt 

	dc.w    $ffdf,$fffe ; Cross vertical boundary
	dc.w	COLOR00, $0FF
	dc.w	COP1LCL, $5000
	dc.w    COP1LCH, $0002

    ; End of Copper list
	dc.l	$fffffffe

copper2:

	dc.w	COLOR00, $F00

	dc.w    $ffdf,$fffe ; Cross vertical boundary
	dc.w	COP1LCL, $5000
	dc.w    COP1LCH, $0002

	; End of Copper list
	dc.l	$fffffffe

	; dc.w    $ffdf,$fffe ; Cross vertical boundary
	; dc.l	$fffffffe

	dc.w    $0,$0  ; Marker for the copy code (see above)

bitplanes:
	incbin	"out/image.bin"
	