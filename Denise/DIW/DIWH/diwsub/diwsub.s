;
; diwsub -- sub-lores positioning of the display window (DIWHIGH, AGA)
;
; DIWSTRT and DIWSTOP hold their horizontal coordinate in LORES pixels, so
; on OCS the display window can only be placed on even hires pixels and on
; multiples of four in super hires. AGA adds two two-bit fields to DIWHIGH
; that supply the missing low bits:
;
;   DIWHIGH bits  4  3    the two low bits of the DIWSTRT coordinate
;   DIWHIGH bits 12 11    the two low bits of the DIWSTOP coordinate
;   DIWHIGH bit   5       DIWSTRT bit 8   (ECS and AGA)
;   DIWHIGH bit  13       DIWSTOP bit 8   (ECS and AGA)
;
; The two high bits are what minmax3 in this directory exercises. The four
; low ones are what this test is about, and nothing in the suite has ever
; touched them.
;
;
; WHAT TO EXPECT
; --------------
;
; Both window edges are compared in super hires units, but the comparison
; is masked down to the resolution actually being displayed. The added bits
; therefore survive only as far as the current mode can resolve them:
;
;   lores         all four settings identical, no edge movement at all
;   hires         0 and 1 identical, 2 and 3 identical, one hires pixel
;                 apart from each other
;   super hires   four distinct positions, one super hires pixel apart
;
; The lores section is the control: an edge that moves there means the bits
; are being applied where the hardware masks them off.
;
; The regression reference cannot show the whole of the super hires case.
; A screenshot texel covers one hires pixel, so an odd super hires step is
; half a texel and lands on the same column; the section reads as two pairs
; there rather than four distinct positions. The four are visible on a real
; machine, which is what the A1200 photograph is for.
;
; On OCS and ECS no edge moves anywhere, because these are AGA fields. That
; makes both recorded references negative controls: any movement in them
; would mean the emulation has begun honouring AGA bits on a chipset that
; does not have them.
;
;
; READING THE PICTURE
; -------------------
;
; One bitplane, its buffer filled with $FFFF, so the window interior is a
; flat hue and its edges are hue against the black of COLOR00. There is no
; BRDRBLNK anywhere in this test, deliberately: the border and COLOR00 are
; both black, the test runs unchanged on OCS, and the edges stay readable
; because the bitplane data covers the window from end to end.
;
; DIWSTRT sits at lores $90, well RIGHT of the first bitplane pixel. That
; matters. The display window does not open at DIWSTRT but at the first
; BPL1DAT write, so a DIWSTRT left of the data would be invisible and the
; test would measure nothing (see Denise/Sprites/clip/diwclip). Placing it
; inside the data makes DIWSTRT the edge that shows.
;
; Three sections of eight six-line blocks. The first four blocks of each
; section step the DIWSTRT field through 0, 1, 2, 3 with the DIWSTOP field
; held at zero; the last four do the reverse. Every block opens with one
; line in dark red to separate it from its neighbour.
;

	include "../../../../include/registers.i"
	include "../../../../include/ministartup.i"

LVL3_INT_VECTOR     equ $6C
DIWHIGH             equ $1E4           ; ECS and AGA

BPLCON0_OFF         equ $0201
LORES_BITS          equ $0201
HIRES_BITS          equ $8201
SHRES_BITS          equ $0241          ; bit 6 alone selects super hires

; DIWSTRT is placed inside the bitplane data on purpose, see the notes
; above. DIWSTOP keeps its bit 8, which DIWHIGH has to supply once it
; has been written.
DIW_START           equ $2C90
DIW_STOP            equ $2C80          ; horizontal stop $180

BLACK               equ $000
MARKER              equ $600           ; first line of each block
HUE_LORES           equ $66F
HUE_HIRES           equ $B6F
HUE_SHRES           equ $F6F

BUF_SIZE            equ 16384

MAIN:
	lea     CUSTOM,a1
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #BPLCON0_OFF,BPLCON0(a1)
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01
	lea     irq3(pc),a3
	move.l  a3,LVL3_INT_VECTOR

	; Solid bitplane data, so the window interior is a flat hue
	lea     bitplanes(pc),a0
	move.w  #(BUF_SIZE/2)-1,d0
.fill:
	move.w  #$FFFF,(a0)+
	dbra    d0,.fill

	; Fill in the bitplane pointer reloads in the Copper list
	lea     bitplanes(pc),a0
	move.l  a0,d0
	lea     bplptr_lores(pc),a2
	move.w  d0,6(a2)
	swap    d0
	move.w  d0,2(a2)
	move.l  a0,d0
	lea     bplptr_hires(pc),a2
	move.w  d0,6(a2)
	swap    d0
	move.w  d0,2(a2)
	move.l  a0,d0
	lea     bplptr_shres(pc),a2
	move.w  d0,6(a2)
	swap    d0
	move.w  d0,2(a2)

	lea     copper(pc),a0
	move.l  a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	move.w  #$8080,DMACON(a1)   ; Copper DMA
	move.w  #$8100,DMACON(a1)   ; Bitplane DMA
	move.w  #$8200,DMACON(a1)   ; DMAEN
	move.w  #$C020,INTENA(a1)
.mainLoop:
	bra.b   .mainLoop

irq3:
	movem.l d0-a6,-(sp)
	move.w  #$3FFF,INTREQ(a1)
	lea     bitplanes(pc),a2
	lea     BPL1PTH(a1),a3
	move.l  a2,(a3)
	movem.l (sp)+,d0-a6
	rte

copper:
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0000
	dc.w    DDFSTRT,$0038
	dc.w    DDFSTOP,$00D0
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000
	dc.w    COLOR00,BLACK

	;
	; LORES section, lines $30-$5F
	;
	dc.w    $3001,$FFFE
	dc.w    BPLCON0,(1<<12)|LORES_BITS
bplptr_lores:
	dc.w    BPL1PTH,$0000       ; filled in by MAIN
	dc.w    BPL1PTL,$0000

	dc.w    $3001,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2000       ; DIWSTRT +0, DIWSTOP +0
	dc.w    $3101,$FFFE
	dc.w    COLOR01,HUE_LORES
	dc.w    $3601,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2008       ; DIWSTRT +1, DIWSTOP +0
	dc.w    $3701,$FFFE
	dc.w    COLOR01,HUE_LORES
	dc.w    $3C01,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2010       ; DIWSTRT +2, DIWSTOP +0
	dc.w    $3D01,$FFFE
	dc.w    COLOR01,HUE_LORES
	dc.w    $4201,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2018       ; DIWSTRT +3, DIWSTOP +0
	dc.w    $4301,$FFFE
	dc.w    COLOR01,HUE_LORES
	dc.w    $4801,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2000       ; DIWSTRT +0, DIWSTOP +0
	dc.w    $4901,$FFFE
	dc.w    COLOR01,HUE_LORES
	dc.w    $4E01,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2800       ; DIWSTRT +0, DIWSTOP +1
	dc.w    $4F01,$FFFE
	dc.w    COLOR01,HUE_LORES
	dc.w    $5401,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$3000       ; DIWSTRT +0, DIWSTOP +2
	dc.w    $5501,$FFFE
	dc.w    COLOR01,HUE_LORES
	dc.w    $5A01,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$3800       ; DIWSTRT +0, DIWSTOP +3
	dc.w    $5B01,$FFFE
	dc.w    COLOR01,HUE_LORES

	;
	; HIRES section, lines $60-$8F
	;
	dc.w    $6001,$FFFE
	dc.w    BPLCON0,(1<<12)|HIRES_BITS
bplptr_hires:
	dc.w    BPL1PTH,$0000       ; filled in by MAIN
	dc.w    BPL1PTL,$0000

	dc.w    $6001,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2000       ; DIWSTRT +0, DIWSTOP +0
	dc.w    $6101,$FFFE
	dc.w    COLOR01,HUE_HIRES
	dc.w    $6601,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2008       ; DIWSTRT +1, DIWSTOP +0
	dc.w    $6701,$FFFE
	dc.w    COLOR01,HUE_HIRES
	dc.w    $6C01,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2010       ; DIWSTRT +2, DIWSTOP +0
	dc.w    $6D01,$FFFE
	dc.w    COLOR01,HUE_HIRES
	dc.w    $7201,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2018       ; DIWSTRT +3, DIWSTOP +0
	dc.w    $7301,$FFFE
	dc.w    COLOR01,HUE_HIRES
	dc.w    $7801,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2000       ; DIWSTRT +0, DIWSTOP +0
	dc.w    $7901,$FFFE
	dc.w    COLOR01,HUE_HIRES
	dc.w    $7E01,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2800       ; DIWSTRT +0, DIWSTOP +1
	dc.w    $7F01,$FFFE
	dc.w    COLOR01,HUE_HIRES
	dc.w    $8401,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$3000       ; DIWSTRT +0, DIWSTOP +2
	dc.w    $8501,$FFFE
	dc.w    COLOR01,HUE_HIRES
	dc.w    $8A01,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$3800       ; DIWSTRT +0, DIWSTOP +3
	dc.w    $8B01,$FFFE
	dc.w    COLOR01,HUE_HIRES

	;
	; SHRES section, lines $90-$BF
	;
	dc.w    $9001,$FFFE
	dc.w    BPLCON0,(1<<12)|SHRES_BITS
bplptr_shres:
	dc.w    BPL1PTH,$0000       ; filled in by MAIN
	dc.w    BPL1PTL,$0000

	dc.w    $9001,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2000       ; DIWSTRT +0, DIWSTOP +0
	dc.w    $9101,$FFFE
	dc.w    COLOR01,HUE_SHRES
	dc.w    $9601,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2008       ; DIWSTRT +1, DIWSTOP +0
	dc.w    $9701,$FFFE
	dc.w    COLOR01,HUE_SHRES
	dc.w    $9C01,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2010       ; DIWSTRT +2, DIWSTOP +0
	dc.w    $9D01,$FFFE
	dc.w    COLOR01,HUE_SHRES
	dc.w    $A201,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2018       ; DIWSTRT +3, DIWSTOP +0
	dc.w    $A301,$FFFE
	dc.w    COLOR01,HUE_SHRES
	dc.w    $A801,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2000       ; DIWSTRT +0, DIWSTOP +0
	dc.w    $A901,$FFFE
	dc.w    COLOR01,HUE_SHRES
	dc.w    $AE01,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$2800       ; DIWSTRT +0, DIWSTOP +1
	dc.w    $AF01,$FFFE
	dc.w    COLOR01,HUE_SHRES
	dc.w    $B401,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$3000       ; DIWSTRT +0, DIWSTOP +2
	dc.w    $B501,$FFFE
	dc.w    COLOR01,HUE_SHRES
	dc.w    $BA01,$FFFE
	dc.w    COLOR01,MARKER
	dc.w    DIWHIGH,$3800       ; DIWSTRT +0, DIWSTOP +3
	dc.w    $BB01,$FFFE
	dc.w    COLOR01,HUE_SHRES

	dc.w    $C001,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.l    $FFFFFFFE

bitplanes:
	ds.b    BUF_SIZE

