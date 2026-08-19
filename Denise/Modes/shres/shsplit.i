; shsplit.i -- shared body for the Denise/Modes shsplit tests.
;
; The including file need not define anything.
;
;
; WHAT IS UNDER TEST
; ------------------
;
; Whether ECS super hires splits a colour register across two sub-pixels.
;
; The index rule itself is settled (see shindex1 to shindex5): a super hires
; pixel reaches COLOR00, COLOR05, COLOR10 or COLOR15, the register number
; being the two bit pixel value replicated, index = 5 * v. What that family
; could NOT answer is whether the register's twelve bits are then shown whole,
; or split so that one sub-pixel gets the high bit pair of each RGB nibble and
; the other the low bit pair. Every palette used there was built from nibbles
; $0/$5/$A/$F, whose two bit pairs are equal, so a split would have been
; invisible by construction.
;
; This test uses nibbles where the two halves differ:
;
;   COLOR05 = $C00    red nibble $C = 1100, high pair set, low pair clear
;   COLOR10 = $300    red nibble $3 = 0011, high pair clear, low pair set
;   COLOR15 = $F00    red nibble $F = 1111, both pairs set
;
; and paints four sections, each a CONSTANT pixel value, so every pixel in a
; section reaches the same register and nothing else can muddy the reading:
;
;   section 0   v = 0   ->  COLOR00
;   section 1   v = 1   ->  COLOR05
;   section 2   v = 2   ->  COLOR10
;   section 3   v = 3   ->  COLOR15
;
; The answer is then read off the brightness of sections 1 and 2:
;
;   no split   section 1 is bright red (4/5), section 2 dark red (1/5),
;              clearly different from each other
;   split      both come out as the same mid red (1/2), because each is an
;              even mix of full red and black
;
; Any register outside the four reachable ones is green, so a stray index
; announces itself rather than hiding among the reds.
;
; Orientation: the bar above section 0 is four lines and the one below
; section 3 is two, every bar between sections is one. Compare thicknesses as
; a RATIO rather than in absolute pixels -- a photograph blurs both markers by
; the same factor, and reading them as absolute line counts is what inverted
; the first reading of the shindex photographs.

	IFND DDF_START
DDF_START           equ $0038
	ENDC
	IFND DDF_STOP
DDF_STOP            equ $00B0
	ENDC

DIW_START           equ $2C00+(DDF_START*2)+9
DIW_STOP            equ $2CC1

PLANE_SIZE          equ 4096

BAR_COLOR           equ $FFF
OTHER_COLOR         equ $0F0                ; unreachable registers: green


MAIN:
	lea     CUSTOM,a1

	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01

	; Two buffers: all zeroes and all ones
	lea     bufZero,a0
	move.w  #$0000,d1
	bsr     .fill
	lea     bufOne,a0
	move.w  #$FFFF,d1
	bsr     .fill

	; Palette: green everywhere, then the four reachable registers
	lea     COLOR00(a1),a2
	moveq   #31,d0
.palLoop:
	move.w  #OTHER_COLOR,(a2)+
	dbra    d0,.palLoop
	move.w  #$0000,COLOR00(a1)      ; index 0  (v = 0)
	move.w  #$0C00,COLOR00+2*5(a1)  ; index 5  (v = 1)  high bit pair only
	move.w  #$0300,COLOR00+2*10(a1) ; index 10 (v = 2)  low bit pair only
	move.w  #$0F00,COLOR00+2*15(a1) ; index 15 (v = 3)  both pairs

	move.w  #$0000,DPL3DATA(a1)
	move.w  #$0000,DPL4DATA(a1)
	move.w  #$0000,DPL5DATA(a1)
	move.w  #$0000,DPL6DATA(a1)

	lea     sectionPtrTable(pc),a4
.ptLoop:
	move.l  (a4)+,d0
	beq.s   .ptDone
	move.l  d0,a2
	move.l  (a4)+,d3
	move.w  d3,6(a2)
	swap    d3
	move.w  d3,2(a2)
	move.l  (a4)+,d3
	move.w  d3,14(a2)
	swap    d3
	move.w  d3,10(a2)
	bra.s   .ptLoop
.ptDone:

	lea     CUSTOM,a1
	lea     copper(pc),a0
	move.l  a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #$8080,DMACON(a1)
	move.w  #$8100,DMACON(a1)
	move.w  #$8200,DMACON(a1)
.mainLoop:
	bra.b   .mainLoop

.fill:
	move.w  #(PLANE_SIZE/2)-1,d0
.fillLoop:
	move.w  d1,(a0)+
	dbra    d0,.fillLoop
	rts

sectionPtrTable:
	dc.l    sec0,bufZero,bufZero    ; v = 0
	dc.l    sec1,bufOne,bufZero     ; v = 1
	dc.l    sec2,bufZero,bufOne     ; v = 2
	dc.l    sec3,bufOne,bufOne      ; v = 3
	dc.l    0

copper:
	dc.w    BPLCON0,$0200
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    DDFSTRT,DDF_START
	dc.w    DDFSTOP,DDF_STOP
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000

	; Four line bar -- marks the TOP
	dc.w    $3001,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $3401,$FFFE
	dc.w    COLOR00,$0000

sec0:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $3501,$FFFE
	dc.w    BPLCON0,$2240
	dc.w    $5201,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $5301,$FFFE
	dc.w    COLOR00,$0000

sec1:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $5401,$FFFE
	dc.w    BPLCON0,$2240
	dc.w    $7101,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $7201,$FFFE
	dc.w    COLOR00,$0000

sec2:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $7301,$FFFE
	dc.w    BPLCON0,$2240
	dc.w    $9001,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $9101,$FFFE
	dc.w    COLOR00,$0000

sec3:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $9201,$FFFE
	dc.w    BPLCON0,$2240

	; Two line bar -- marks the BOTTOM
	dc.w    $AF01,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $B101,$FFFE
	dc.w    COLOR00,$0000

	dc.l    $fffffffe

	cnop    0,8
bufZero: ds.b PLANE_SIZE
	cnop    0,8
bufOne:  ds.b PLANE_SIZE
