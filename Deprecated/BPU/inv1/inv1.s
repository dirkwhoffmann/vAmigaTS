	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	;; install copper list and enable DMA
	lea 	CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	
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
	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPLCON0,(4<<12)|$200 ; 
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"

	dc.w    $118,$000    ; BPL5DAT
	dc.w    $11A,$000    ; BPL6DAT

	; First color block 
	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$3101,$FFFE  ; WAIT 
	dc.w    $11A,$000    ; BPL6DAT
	dc.w    $118,$000    ; BPL5DAT
	dc.w    $116,$000    ; BPL4DAT
	dc.w    $114,$000    ; BPL3DAT
	dc.w    $112,$000    ; BPL2DAT
	dc.w    $110,$000    ; BPL1DAT
	dc.w    BPLCON0,(7<<12)|$200  ; Enable 7 bitplanes in lores mode

	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$38D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$3981,$FFFE  ; WAIT 
	dc.w    $11A,$AAA    ; BPL6DAT

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$40D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$4181,$FFFE  ; WAIT 
	dc.w    $118,$999    ; BPL5DAT

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$4981,$FFFE  ; WAIT 
	dc.w    $116,$E38    ; BPL4DAT

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$50D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$5181,$FFFE  ; WAIT 
	dc.w    $114,$F0F    ; BPL3DAT

	dc.w	$5801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$58D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$5981,$FFFE  ; WAIT 
	dc.w    $112,$FC0    ; BPL2DAT

  	; Second color block 
	dc.w	$7001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$70D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w    $11A,$000    ; BPL6DAT
	dc.w    $118,$000    ; BPL5DAT
	dc.w    $116,$000    ; BPL4DAT
	dc.w    $114,$000    ; BPL3DAT
	dc.w    $112,$000    ; BPL2DAT
	dc.w    $110,$000    ; BPL1DAT
	dc.w	$7181,$FFFE  ; WAIT 
	dc.w    BPLCON0, (15<<12)|$200  ; Enable 7 bitplanes in hires mode

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$7981,$FFFE  ; WAIT 
	dc.w    $11A,$AAA    ; BPL6DAT

	dc.w	$8001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$80D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$8181,$FFFE  ; WAIT 
	dc.w    $118,$999    ; BPL5DAT

	dc.w	$8801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$88D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$8881,$FFFE  ; WAIT 
	dc.w    $116,$E38    ; BPL4DAT

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$90D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$9181,$FFFE  ; WAIT 
	dc.w    $114,$F0F    ; BPL3DAT

	dc.w	$9801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$98D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$9981,$FFFE  ; WAIT 
	dc.w    $112,$FC0    ; BPL2DAT

	; Third color block
	dc.w    $B801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $B8D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $B981,$FFFE  ; WAIT
	dc.w    $11A,$000    ; BPL6DAT
	dc.w    $118,$000    ; BPL5DAT
	dc.w    $116,$000    ; BPL4DAT
	dc.w    $114,$000    ; BPL3DAT
	dc.w    $112,$000    ; BPL2DAT
	dc.w    $110,$000    ; BPL1DAT
	dc.w    BPLCON0, (14<<12)|$200  ; Enable 6 bitplanes in hires mode

	dc.w    $C001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C0D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $C181,$FFFE  ; WAIT
	dc.w    $11A,$AAA    ; BPL6DAT

	dc.w    $C801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C8D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $C981,$FFFE  ; WAIT
	dc.w    $118,$999    ; BPL5DAT

	dc.w    $D001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D0D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $D181,$FFFE  ; WAIT
	dc.w    $116,$E38    ; BPL4DAT

	dc.w    $D801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D8D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $D981,$FFFE  ; WAIT
	dc.w    $114,$F0F    ; BPL3DAT

	dc.w    $E001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $E0D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $E181,$FFFE  ; WAIT
	dc.w    $112,$FC0    ; BPL2DAT

	dc.w    $E801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $E8D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w	$ffdf,$fffe ; Cross vertical boundary

	; Fourth color block
	dc.w    $0001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $00D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $0181,$FFFE  ; WAIT
	dc.w    $11A,$000    ; BPL6DAT
	dc.w    $118,$000    ; BPL5DAT
	dc.w    $116,$000    ; BPL4DAT
	dc.w    $114,$000    ; BPL3DAT
	dc.w    $112,$000    ; BPL2DAT
	dc.w    $110,$000    ; BPL1DAT
	dc.w    BPLCON0, (13<<12)|$200 ; Enable 5 bitplanes in hires mode

	dc.w    $0801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $08D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $0981,$FFFE  ; WAIT
	dc.w    $11A,$AAA    ; BPL6DAT

	dc.w    $1001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $10D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $1181,$FFFE  ; WAIT
	dc.w    $118,$999    ; BPL5DAT

	dc.w    $1801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $18D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $1981,$FFFE  ; WAIT
	dc.w    $116,$E38    ; BPL4DAT

	dc.w    $2001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $20D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $2181,$FFFE  ; WAIT
	dc.w    $114,$F0F    ; BPL3DAT

	dc.w    $2801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $28D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $2981,$FFFE  ; WAIT
	dc.w    $112,$FC0    ; BPL2DAT

	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"
	