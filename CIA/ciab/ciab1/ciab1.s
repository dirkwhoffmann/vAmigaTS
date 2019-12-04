	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAAPRA             equ $BFE001	
CIABPRB             equ $BFD100	
CIABASE             equ $BFD000
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	
	lea CUSTOM,a1

	; Disable all interrupts except VBLANK and CIAB
	move.w	#$7FFF,INTENA(a1)       ; Disable all interrupts
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	lea	level6InterruptHandler(pc),a3
 	move.l	a3,LVL6_INT_VECTOR
	move.w	#$E020,INTENA(a1)       ; Enable VBLANK and CIAB

    ; Configure CIAs
	lea CIABASE,a0    
	move.b #$08,$E00(a0)            ; CRA (Start timer in one shot mode)
	move.b #$08,$F00(a0)            ; CRB (Start timer in one shot mode)
	move.b #$83,$D00(a0)            ; Enable CIA timer interrupt

	; install copper list and enable DMA
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	;move.w  #(DMAF_SETCLR!DMAF_RASTER!DMAF_MASTER),dmacon(a1)

.mainLoop:
	bra.b	.mainLoop

level6InterruptHandler:
	movem.l	d0-a6,-(sp)

	lea	CUSTOM,a5
	lea CIABASE,a6
	move.w  #$AA0,COLOR00(a5) 
	move.b  $D00(a6),d0       ; Acknowledge the IRQ by reading the CIA ICR reg
	move.w	#$2000,INTREQ(a5) ; Acknowledge the IRQ by clearing the IRQ bit in INTREQ
	
	movem.l	(sp)+,d0-a6
	rte

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

	;; Perform a timer test
	lea CIABASE,a0                 
	move.b #$60,$400(a0)            ; TBLO   
	move.b #$10,$500(a0)            ; TBHI 
	move.b #$50,$600(a0)            ; TBLO   
	move.b #$20,$700(a0)            ; TBHI 
	;move.b #$83,$D00(a0)            ; Enable CIA timer interrupt
	;move.b #$09,$E00(a0)            ; CRA (Start timer in one shot mode)
	;move.b #$09,$F00(a0)            ; CRB (Start timer in one shot mode)
	bra.s	.interruptComplete

.checkCopper:
	lea	CUSTOM,a5
	move.w  #$123,COLOR00(a5)
	move.w	INTREQR(a5),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete

.copperInterrupt:
	move.w  #$456,COLOR00(a5)
	move.w	#INTF_COPER,INTREQ(a5)	; clear interrupt bit	
	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte

copper:

    ; Enable 0 bitplanes
	dc.w    BPLCON0, (0<<12)|$200

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

	dc.w    $5C39, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
 	dc.w    $5D01, $FFFE         ; WAIT
	dc.w    COLOR00,$000

	dc.w    $6C39, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
 	dc.w    $6D01, $FFFE         ; WAIT
	dc.w    COLOR00,$000

 	dc.w    $B639, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
 	dc.w    $B701, $FFFE         ; WAIT
	dc.w    COLOR00,$000

	dc.w    $C639, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
 	dc.w    $C701, $FFFE         ; WAIT
	dc.w    COLOR00,$000

	dc.w	$ffdf,$fffe ; Cross vertical boundary
	dc.l	$fffffffe

bitplanes:
	ds.b    51200,$00
	