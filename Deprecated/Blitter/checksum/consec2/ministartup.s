***************************************************************************
* v2.26       /                                                           *
*       _____.__ _                                         .___.          *
*      /    /_____________.  _________.__________.________ |   |________  *
*  ___/____      /    ____|_/         |         /|        \|   ._      /  *
*  \     \/      \    \     \    /    |    :___/�|    \    \   |/     /   *
*   \_____________\___/_____/___/_____|____|     |____|\_____________/    *
*     -========================/===========|______\================-      *
*                                                                         *
*   .---.----(*(             [S]carab Demo System           )*)---.---.   *
*   `-./                                                           \.-'   *
*			   Non-System StartUp Code			  *
*			   -----------------------			  *
*									  *
* 		This is the short version, no FX-Lib required		  *
*									  *
*      Part of FX-Lib (c) 1998-2oo5 by StingRay/[S]carab^Scoopex   	  *
*                                                                         *
***************************************************************************

INTENASET	= %1100000000100000
;		   ab-------cdefg--
;	a: SET/CLR Bit
;	b: Master Bit
;	c: Blitter Int
;	d: Vert Blank Int
;	e: Copper Int
;	f: IO Ports/Timers
;	g: Software Int

DMASET		= %1000001111100000
;		   a----bcdefghi--j
;	a: SET/CLR Bit
;	b: Blitter Priority
;	c: Enable DMA
;	d: Bit Plane DMA
;	e: Copper DMA
;	f: Blitter DMA
;	g: Sprite DMA
;	h: Disk DMA
;	i..j: Audio Channel 0-3

;	PRINTT
;	PRINTT	"MINI STARTUP BY STINGRAY/[S]CARAB^SCOOPEX"
;	PRINTT	"             .oO LAST CHANGE: THU, 2o-AUG-2oo5 Oo."
;	PRINTT


***************************************************
*** MACRO DEFINITION				***
***************************************************

WAITBLIT	MACRO
		tst.b	$02(a6)
.\@		btst	#6,$02(a6)
		bne.b	.\@
		ENDM
		

***************************************************
*** CLOSE DOWN SYSTEM - INIT PROGRAM		***
***************************************************

START	movem.l	d0-a6,-(a7)

	move.l	$4.w,a6
	lea	.VARS_HW(pc),a5
	lea	.GFXname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)			; OpenLibrary()
	move.l	d0,.GFXbase-.VARS_HW(a5)
	beq.b	.END
	move.l	d0,a6
	move.l	34(a6),.OldView-.VARS_HW(a5)
	sub.l	a1,a1
	bsr.w	.DoView
	move.l	$26(a6),.OldCop1-.VARS_HW(a5)	; Store old CL 1
	move.l	$32(a6),.OldCop2-.VARS_HW(a5)	; Store old CL 2
	bsr	.GetVBR
	move.l	d0,.VBRptr-.VARS_HW(a5)
	move.l	d0,a0

	***	Store Custom Regs	***

	lea	$dff000,a6			; base address
	move.w	$10(a6),.ADK-.VARS_HW(a5)	; Store old ADKCON
	move.w	$1C(a6),.INTENA-.VARS_HW(a5)	; Store old INTENA
	move.w	$02(a6),.DMA-.VARS_HW(a5)	; Store old DMA
	move.w	#$7FFF,d0
	bsr	WaitRaster
	move.w	d0,$9A(a6)			; Disable Interrupts
	move.w	d0,$96(a6)			; Clear all DMA channels
	move.w	d0,$9C(a6)			; Clear all INT requests

	move.l	$6c(a0),.OldVBI-.VARS_HW(a5)
	lea	.NewVBI(pc),a1
	move.l	a1,$6c(a0)

	move.w	#INTENASET!$C000,$9A(a6)	; set Interrupts+ BIT 14/15
	move.w	#DMASET!$8200,$96(a6)		; set DMA	+ BIT 09/15
	bsr	MAIN

	
***************************************************
*** Restore Sytem Parameter etc.		***
***************************************************

.END	lea	.VARS_HW(pc),a5
	lea	$dff000,a6
	clr.l	VBIptr-.VARS_HW(a5)

	move.w	#$8000,d0
	or.w	d0,.INTENA-.VARS_HW(a5)		; SET/CLR-Bit to 1
	or.w	d0,.DMA-.VARS_HW(a5)		; SET/CLR-Bit to 1
	or.w	d0,.ADK-.VARS_HW(a5)		; SET/CLR-Bit to 1
	subq.w	#1,d0
	bsr	WaitRaster
	move.w	d0,$9A(a6)			; Clear all INT bits
	move.w	d0,$96(a6)			; Clear all DMA channels
	move.w	d0,$9C(a6)			; Clear all INT requests

	move.l	.VBRptr(pc),a0
	move.l	.OldVBI(pc),$6c(a0)

	move.l	.OldCop1(pc),$80(a6)		; Restore old CL 1
	move.l	.OldCop2(pc),$84(a6)		; Restore old CL 2
	move.w	d0,$88(a6)			; start copper1
	move.w	.INTENA(pc),$9A(a6)		; Restore INTENA
	move.w	.DMA(pc),$96(a6)		; Restore DMAcon
	move.w	.ADK(pc),$9E(a6)		; Restore ADKcon

	move.l	.GFXbase(pc),a6
	move.l	.OldView(pc),a1			; restore old viewport
	bsr.b	.DoView

	move.l	a6,a1
	move.l	$4.w,a6
	jsr	-414(a6)			; Closelibrary()
	movem.l	(a7)+,d0-a6
	moveq	#0,d0
	rts


.DoView	jsr	-222(a6)			; LoadView()
	jsr	-270(a6)			; WaitTOF()
	jmp	-270(a6)


*******************************************
*** Get Address of the VBR		***
*******************************************

.GetVBR	move.l	a5,-(a7)
	moveq	#0,d0			; default at $0
	move.l	$4.w,a6
	btst	#0,296+1(a6)		; 68010+?
	beq.b	.is68k			; nope.
	lea	.getit(pc),a5
	jsr	-30(a6)			; SuperVisor()
.is68k	move.l	(a7)+,a5
	rts

.getit	; movec   vbr,d0
	rte				; back to user state code
	

*******************************************
*** VERTICAL BLANK (VBI)		***
*******************************************

.NewVBI	movem.l	d0-a6,-(a7)
	move.l	VBIptr(pc),d0
	beq.b	.noVBI
	move.l	d0,a0
	jsr	(a0)
.noVBI	lea	$dff09c,a6
	moveq	#$20,d0
	move.w	d0,(a6)
	move.w	d0,(a6)			; twice to avoid a4k hw bug
	movem.l	(a7)+,d0-a6
	rte

*******************************************
*** DATA AREA		FAST		***
*******************************************

.VARS_HW
.GFXname	dc.b	'graphics.library',0,0
.GFXbase	dc.l	0
.OldView	dc.l	0
.OldCop1	dc.l	0
.OldCop2	dc.l	0
.VBRptr		dc.l	0
.OldVBI		dc.l	0
.ADK		dc.w	0
.INTENA		dc.w	0
.DMA		dc.w	0

VBIptr		dc.l	0

WaitRaster
	move.l	d0,-(a7)
.loop	move.l	$dff004,d0
	and.l	#$1ff00,d0
	cmp.l	#303<<8,d0
	bne.b	.loop
	move.l	(a7)+,d0
	rts

WaitRasterEnd
	move.l	d0,-(a7)
.loop	move.l	$dff004,d0
	and.l	#$1ff00,d0
	cmp.l	#303<<8,d0
	beq.b	.loop
	move.l	(a7)+,d0
	rts


