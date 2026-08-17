
; brdcop.s -- the window edge drawn twice, by Denise and by the Copper.
;
; Every test in this suite that measures the left edge of the picture ends up
; measuring the same thing: the position at which Denise stops emitting border
; and lets the display window through. That position is fitted off a
; photograph against a Copper ruler, which means the answer always arrives
; with a calibration attached to it -- an affine map, a blur estimate, an
; erf fit, and a residual of a few tenths of a column.
;
; This test asks the same question without any of that. The picture is bands
; of two kinds, alternating down each section:
;
;   reference band    BRDRBLNK set and one bitplane whose data is all zeros.
;                     The border is forced to pure black; the window shows
;                     index 0, which is COLOR00, which is grey. So the line
;                     is black up to the window edge and grey after it, and
;                     the edge is placed by Denise's data gate.
;
;   Copper band       BRDRBLNK clear and BPU = 0, so there is no window at
;                     all and the whole line is border, taking COLOR00.
;                     COLOR00 starts the line black; one Copper MOVE turns it
;                     grey. Same black to grey step, placed by the Copper.
;
; If Denise's gate and the Copper agree, the step runs straight through every
; band boundary and the Copper bands cannot be picked out. That is the whole
; measurement: not a position, but whether a vertical edge is straight. A
; photograph of a real monitor answers it without any calibration, because
; bleeding blurs both bands identically and a step survives blurring.
;
; The Copper's granularity is one colour clock, four screen columns, and the
; data gate does not in general land on that grid. The offsets below are
; therefore tuned to the nearest colour clock and a residual of one or two
; columns is left in; the README lists it per section. That residual is a
; constant of the instrument, not a defect -- what a photograph decides is
; whether the residual it shows is the one vAmiga shows.
;
; The Copper bands carry a marker: COLOR00 goes to red for eight colour clocks
; in the middle of the line and back to grey afterwards. Without it a correct
; picture would be indistinguishable from a picture in which the Copper list
; never ran.
;
; Both bands also return to black near DIWSTOP -- the reference band because
; the window closes, the Copper band because a MOVE puts it back. So the right
; edge is a second, independent instance of the same comparison.
;
; Two Copper ruler lines sit at the top of each section for absolute
; calibration, on lines with no bitplanes so nothing steals Copper slots.
;
	include "../../../../include/registers.i"
	include "../../../../include/ministartup.i"

LVL3_INT_VECTOR     equ $6C
BPLCON3             equ $106
FMODEREG            equ $1FC
BPLCON4             equ $10C

BRDRBLNK            equ $0020          ; BPLCON3 bit 5

BPLCON0_OFF         equ $0201          ; ECSENA, no bitplanes
LORES_BITS          equ $1201          ; one bitplane, lores
HIRES_BITS          equ $9201          ; one bitplane, hires
SHRES_BITS          equ $1241          ; one bitplane, super hires

DIW_START           equ $2C71          ; left of the data, so the data gate wins
DIW_STOP            equ $2CC1

COL_BLACK           equ $000
COL_GREY            equ $888           ; the background, and the window
COL_MARK            equ $F00           ; proof that the Copper band is drawn

RULER_A             equ $FFF
RULER_B             equ $00A
RULER_5             equ $FF0
RULER_0             equ $F00
RULER_9             equ $0F0

BUF_SIZE            equ 128


MAIN:
	lea     CUSTOM,a1
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #BPLCON0_OFF,BPLCON0(a1)
	move.w  #$0000,BPLCON3(a1)
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01
	lea     irq3(pc),a3
	move.l  a3,LVL3_INT_VECTOR

	; The bitplane holds zeros, so every pixel of the window is index 0.
	; Nothing else is needed: the reference band is about where the window
	; starts, not about what is in it.
	lea     bitBuf(pc),a2
	move.w  #(BUF_SIZE/2)-1,d0
.clrLoop:
	clr.w   (a2)+
	dbra    d0,.clrLoop

	lea     bitBuf(pc),a3
	move.l  a3,d3
	lea     bplPtr(pc),a2
	move.l  d3,d4
	swap    d4
	move.w  d4,2(a2)
	move.w  d3,6(a2)

	lea     CUSTOM,a1
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
	movem.l (sp)+,d0-a6
	rte


copper:
	dc.w    FMODEREG,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024
	dc.w    BPLCON3,$0000
	dc.w    DDFSTRT,$0038
	dc.w    DDFSTOP,$00D0
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    BPL1MOD,$FFD8           ; -40: every line refetches
	dc.w    COLOR00,COL_BLACK
	dc.w    COLOR01,COL_GREY
bplPtr:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000

	;
	; LORES section, lines $2C-$78. Copper step at HP $3F.
	;
	dc.w    $2C01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.w    $2C31,$FFFE
	dc.w    COLOR00,RULER_0
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_9
	dc.w    $2D01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.w    $2D31,$FFFE
	dc.w    COLOR00,RULER_0
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_9
	dc.w    $2E01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $2E3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $2E81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $2E89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $2EDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $2F01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $2F3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $2F81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $2F89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $2FDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $3001,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $303F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $3081,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $3089,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $30DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $3101,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $313F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $3181,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $3189,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $31DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $3201,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $323F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $3281,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $3289,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $32DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $3301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $3401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $3501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $3601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $3701,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $3801,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $3901,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $3A01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $3B01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $3C01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $3D01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $3D3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $3D81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $3D89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $3DDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $3E01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $3E3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $3E81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $3E89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $3EDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $3F01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $3F3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $3F81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $3F89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $3FDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $4001,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $403F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $4081,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $4089,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $40DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $4101,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $413F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $4181,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $4189,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $41DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $4201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $4301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $4401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $4501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $4601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $4701,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $4801,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $4901,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $4A01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $4B01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $4C01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $4C3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $4C81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $4C89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $4CDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $4D01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $4D3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $4D81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $4D89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $4DDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $4E01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $4E3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $4E81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $4E89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $4EDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $4F01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $4F3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $4F81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $4F89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $4FDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $5001,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $503F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $5081,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $5089,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $50DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $5101,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $5201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $5301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $5401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $5501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $5601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $5701,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $5801,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $5901,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $5A01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $5B01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $5B3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $5B81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $5B89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $5BDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $5C01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $5C3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $5C81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $5C89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $5CDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $5D01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $5D3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $5D81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $5D89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $5DDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $5E01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $5E3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $5E81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $5E89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $5EDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $5F01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $5F3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $5F81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $5F89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $5FDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $6001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $6101,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $6201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $6301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $6401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $6501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $6601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $6701,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $6801,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $6901,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $6A01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $6A3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $6A81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $6A89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $6ADF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $6B01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $6B3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $6B81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $6B89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $6BDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $6C01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $6C3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $6C81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $6C89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $6CDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $6D01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $6D3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $6D81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $6D89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $6DDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $6E01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $6E3F,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $6E81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $6E89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $6EDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $6F01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $7001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $7101,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $7201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $7301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C81
	dc.w    BPLCON0,LORES_BITS
	dc.w    $7401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $7501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $7601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $7701,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $7801,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,LORES_BITS
	dc.w    $78E1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	;
	; HIRES section, lines $79-$C5. Copper step at HP $3B.
	;
	dc.w    $7901,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.w    $7931,$FFFE
	dc.w    COLOR00,RULER_0
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_9
	dc.w    $7A01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.w    $7A31,$FFFE
	dc.w    COLOR00,RULER_0
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_9
	dc.w    $7B01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $7B3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $7B81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $7B89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $7BDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $7C01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $7C3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $7C81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $7C89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $7CDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $7D01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $7D3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $7D81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $7D89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $7DDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $7E01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $7E3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $7E81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $7E89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $7EDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $7F01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $7F3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $7F81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $7F89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $7FDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $8001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $8101,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $8201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $8301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $8401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $8501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $8601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $8701,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $8801,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $8901,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $8A01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $8A3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $8A81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $8A89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $8ADF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $8B01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $8B3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $8B81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $8B89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $8BDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $8C01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $8C3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $8C81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $8C89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $8CDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $8D01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $8D3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $8D81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $8D89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $8DDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $8E01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $8E3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $8E81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $8E89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $8EDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $8F01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $9001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $9101,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $9201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $9301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $9401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $9501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $9601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $9701,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $9801,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $9901,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $993B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $9981,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $9989,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $99DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $9A01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $9A3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $9A81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $9A89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $9ADF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $9B01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $9B3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $9B81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $9B89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $9BDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $9C01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $9C3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $9C81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $9C89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $9CDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $9D01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $9D3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $9D81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $9D89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $9DDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $9E01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $9F01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $A001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $A101,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $A201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $A301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $A401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $A501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $A601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $A701,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $A801,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $A83B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $A881,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $A889,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $A8DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $A901,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $A93B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $A981,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $A989,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $A9DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $AA01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $AA3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $AA81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $AA89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $AADF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $AB01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $AB3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $AB81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $AB89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $ABDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $AC01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $AC3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $AC81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $AC89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $ACDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $AD01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $AE01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $AF01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $B001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $B101,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $B201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $B301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $B401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $B501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $B601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $B701,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $B73B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $B781,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $B789,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $B7DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $B801,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $B83B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $B881,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $B889,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $B8DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $B901,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $B93B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $B981,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $B989,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $B9DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $BA01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $BA3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $BA81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $BA89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $BADF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $BB01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $BB3B,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $BB81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $BB89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $BBDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $BC01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $BD01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $BE01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $BF01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $C001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C79
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $C101,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $C201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $C301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $C401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $C501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,HIRES_BITS
	dc.w    $C5E1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	;
	; SHRES section, lines $C6-$112. Copper step at HP $39.
	;
	dc.w    $C601,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.w    $C631,$FFFE
	dc.w    COLOR00,RULER_0
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_9
	dc.w    $C701,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.w    $C731,$FFFE
	dc.w    COLOR00,RULER_0
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_5
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_9
	dc.w    $C801,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $C839,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $C881,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $C889,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $C8DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $C901,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $C939,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $C981,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $C989,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $C9DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $CA01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $CA39,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $CA81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $CA89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $CADF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $CB01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $CB39,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $CB81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $CB89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $CBDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $CC01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $CC39,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $CC81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $CC89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $CCDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $CD01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $CE01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $CF01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $D001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $D101,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $D201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $D301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $D401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $D501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $D601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $D701,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $D739,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $D781,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $D789,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $D7DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $D801,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $D839,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $D881,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $D889,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $D8DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $D901,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $D939,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $D981,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $D989,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $D9DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $DA01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $DA39,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $DA81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $DA89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $DADF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $DB01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $DB39,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $DB81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $DB89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $DBDF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $DC01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $DD01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $DE01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $DF01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $E001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $E101,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $E201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $E301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $E401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $E501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $E601,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $E639,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $E681,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $E689,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $E6DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $E701,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $E739,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $E781,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $E789,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $E7DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $E801,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $E839,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $E881,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $E889,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $E8DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $E901,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $E939,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $E981,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $E989,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $E9DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $EA01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $EA39,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $EA81,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $EA89,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $EADF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $EB01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $EC01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $ED01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $EE01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $EF01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $F001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $F101,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $F201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $F301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $F401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $F501,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $F539,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $F581,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $F589,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $F5DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $F601,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $F639,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $F681,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $F689,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $F6DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $F701,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $F739,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $F781,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $F789,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $F7DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $F801,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $F839,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $F881,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $F889,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $F8DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $F901,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $F939,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $F981,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $F989,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $F9DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $FA01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $FB01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $FC01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $FD01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $FE01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $FF01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $FFDF,$FFFE             ; cross the 8 bit vertical boundary
	dc.w    $0001,$FFFE             ; re-sync at the start of line 256
	dc.w    $0001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $0101,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $0201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $0301,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $0401,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $0439,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $0481,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $0489,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $04DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $0501,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $0539,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $0581,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $0589,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $05DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $0601,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $0639,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $0681,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $0689,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $06DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $0701,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $0739,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $0781,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $0789,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $07DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $0801,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,COL_BLACK
	dc.w    $0839,$FFFE
	dc.w    COLOR00,COL_GREY       ; the step under test
	dc.w    $0881,$FFFE
	dc.w    COLOR00,COL_MARK       ; proof the band is drawn
	dc.w    $0889,$FFFE
	dc.w    COLOR00,COL_GREY
	dc.w    $08DF,$FFFE
	dc.w    COLOR00,COL_BLACK      ; matches the window closing
	dc.w    $0901,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $0A01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $0B01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $0C01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $0D01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C75
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $0E01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $0F01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $1001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $1101,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $1201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    COLOR00,COL_GREY
	dc.w    DIWSTRT,$2C71
	dc.w    BPLCON0,SHRES_BITS
	dc.w    $12E1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    $1301,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.w    COLOR00,COL_BLACK
	dc.l    $FFFFFFFE

	cnop    0,8
bitBuf:
	ds.b    BUF_SIZE
