
; spredge.s -- the straddling sprite pixel, at both edges of the window.
;
; A sprite pixel is four buffer entries wide in lores and two in hires. The
; left edge of the display window is the first BPL1DAT write plus
; BPLDAT_LATENCY, which lands two entries into a lores pixel; the right edge
; is DIWSTOP, which lands wherever DIWSTOP puts it. Either way a sprite that
; crosses an edge has one pixel straddling it, and that pixel can be drawn in
; part or discarded whole. The difference is up to one screen column.
;
; Both edges are put on the same rasterline, and each is arranged so that the
; answer is a presence or an absence rather than a position:
;
;   left column    Sprite 0, COLOR17 black, and BRDRBLNK makes the border
;                  black too. Sprite and border merge, so the only thing that
;                  can separate them is playfield getting in between -- which
;                  happens exactly when the straddling pixel is discarded and
;                  the sprite starts a grid step late.
;
;   right column   Sprite 2, COLOR21 white, against the same black border.
;                  Beyond DIWSTOP there is only border, so a white pixel out
;                  there can only be a straddling pixel that was drawn whole
;                  instead of being cut at the edge.
;
; Ten bands per section with both sprites one lores pixel further right in
; each, and three sprite-free lines after every band showing where the two
; edges are on their own.
;
; The two edges are handled by different code. The left one is clipped
; against spriteClipBegin in the pixel loop; the right one is bounded by
; hstop, the loop's own limit. They can disagree, and this test says so.
;
	include "../../../../include/registers.i"
	include "../../../../include/ministartup.i"

LVL3_INT_VECTOR     equ $6C
BPLCON3             equ $106

BRDRBLNK            equ $0020

BPLCON0_OFF         equ $0201
LORES_BITS          equ $1201
HIRES_BITS          equ $9201

DIW_START           equ $2C61          ; far left: the data gate decides
DIW_STOP            equ $2CC1          ; lores $1C1

COL_BACK            equ $04C           ; the playfield
COL_LEFT            equ $000           ; sprite 0: the blanked border colour
COL_RIGHT           equ $FFF           ; sprite 2: as loud as possible

RULER_A             equ $FFF
RULER_B             equ $00A
RULER_5             equ $FF0
RULER_0             equ $F00
RULER_9             equ $0F0

SPR_H               equ 5
SPR_BUF_SIZE        equ 488
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

	lea     bitBuf(pc),a2
	move.w  #(BUF_SIZE/2)-1,d0
.clrLoop:
	clr.w   (a2)+
	dbra    d0,.clrLoop

	; Sprite 0 wears the border's colour, sprite 2 the loudest one there is.
	; Colour 1 of a pair is COLOR17 for sprites 0/1 and COLOR21 for 2/3;
	; setting only COLOR17 would leave sprite 2 in whatever it found.
	move.w  #COL_LEFT,COLOR17(a1)
	move.w  #COL_RIGHT,COLOR21(a1)

	lea     sprBuf0(pc),a0
	lea     sprPos0(pc),a4
	bsr     .buildSprite
	lea     sprBuf2(pc),a0
	lea     sprPos2(pc),a4
	bsr     .buildSprite

	lea     bitBuf(pc),a3
	move.l  a3,d3
	lea     bplPtr(pc),a2
	move.l  d3,d4
	swap    d4
	move.w  d4,2(a2)
	move.w  d3,6(a2)

	clr.l   sprNull
	clr.l   sprNull+4
	lea     sprPtrs(pc),a2
	lea     .sprTable(pc),a5
	moveq   #7,d6
.sprPtLoop:
	move.l  (a5)+,d3
	bsr     .patchPtr
	dbra    d6,.sprPtLoop

	lea     CUSTOM,a1
	lea     copper(pc),a0
	move.l  a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	move.w  #$8080,DMACON(a1)
	move.w  #$8100,DMACON(a1)
	move.w  #$8020,DMACON(a1)
	move.w  #$8200,DMACON(a1)
	move.w  #$C020,INTENA(a1)
.mainLoop:
	bra.b   .mainLoop

.patchPtr:
	move.w  d3,6(a2)
	swap    d3
	move.w  d3,2(a2)
	addq.l  #8,a2
	rts

; Builds the list at a0 from the (VSTART, HSTART) table at a4.
.buildSprite:
.bsLoop:
	move.w  (a4)+,d2
	beq.s   .bsDone
	move.w  (a4)+,d1
	move.w  d2,d4
	add.w   #SPR_H,d4

	move.w  d2,d5
	and.w   #$00FF,d5
	lsl.w   #8,d5
	move.w  d1,d6
	lsr.w   #1,d6
	and.w   #$00FF,d6
	or.w    d6,d5
	move.w  d5,(a0)+

	move.w  d4,d5
	and.w   #$00FF,d5
	lsl.w   #8,d5
	btst    #8,d2
	beq.s   .bsNoV8
	or.w    #$0004,d5
.bsNoV8:
	btst    #8,d4
	beq.s   .bsNoV9
	or.w    #$0002,d5
.bsNoV9:
	btst    #0,d1
	beq.s   .bsNoH0
	or.w    #$0001,d5
.bsNoH0:
	move.w  d5,(a0)+

	moveq   #SPR_H-1,d6
.bsImg:
	move.w  #$FFFF,(a0)+
	clr.w   (a0)+
	dbra    d6,.bsImg
	bra.s   .bsLoop
.bsDone:
	clr.l   (a0)+
	rts

.sprTable:
	dc.l    sprBuf0,sprNull
	dc.l    sprBuf2,sprNull
	dc.l    sprNull,sprNull,sprNull,sprNull

irq3:
	movem.l d0-a6,-(sp)
	move.w  #$3FFF,INTREQ(a1)
	movem.l (sp)+,d0-a6
	rte


copper:
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0000
	dc.w    DDFSTRT,$0038
	dc.w    DDFSTOP,$00D0
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    COLOR00,COL_BACK
	dc.w    COLOR01,COL_BACK
bplPtr:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
sprPtrs:
	dc.w    SPR0PTH,$0000
	dc.w    SPR0PTL,$0000
	dc.w    SPR1PTH,$0000
	dc.w    SPR1PTL,$0000
	dc.w    SPR2PTH,$0000
	dc.w    SPR2PTL,$0000
	dc.w    SPR3PTH,$0000
	dc.w    SPR3PTL,$0000
	dc.w    SPR4PTH,$0000
	dc.w    SPR4PTL,$0000
	dc.w    SPR5PTH,$0000
	dc.w    SPR5PTL,$0000
	dc.w    SPR6PTH,$0000
	dc.w    SPR6PTL,$0000
	dc.w    SPR7PTH,$0000
	dc.w    SPR7PTL,$0000

	;
	; LORES section, lines $2C-$7C. Left HSTART $7B.., right $1B5..
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
	dc.w    COLOR00,COL_BACK
	dc.w    BPL1MOD,$FFD8           ; cancels one line of fetches
	dc.w    $2D01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $3501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $3D01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $4501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $4D01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $5501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $5D01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $6501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $6D01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $7501,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $7CE1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	;
	; HIRES section, lines $7D-$CD. Left HSTART $73.., right $1B5..
	;
	dc.w    $7D01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.w    $7D31,$FFFE
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
	dc.w    COLOR00,COL_BACK
	dc.w    BPL1MOD,$FFB0           ; cancels one line of fetches
	dc.w    $7E01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,HIRES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $8601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,HIRES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $8E01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,HIRES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $9601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,HIRES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $9E01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,HIRES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $A601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,HIRES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $AE01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,HIRES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $B601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,HIRES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $BE01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,HIRES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $C601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,HIRES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $CDE1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    $CE01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.l    $FFFFFFFE

sprPos0:
	dc.w    $02D,$07B
	dc.w    $035,$07C
	dc.w    $03D,$07D
	dc.w    $045,$07E
	dc.w    $04D,$07F
	dc.w    $055,$080
	dc.w    $05D,$081
	dc.w    $065,$082
	dc.w    $06D,$083
	dc.w    $075,$084
	dc.w    $07E,$073
	dc.w    $086,$074
	dc.w    $08E,$075
	dc.w    $096,$076
	dc.w    $09E,$077
	dc.w    $0A6,$078
	dc.w    $0AE,$079
	dc.w    $0B6,$07A
	dc.w    $0BE,$07B
	dc.w    $0C6,$07C
	dc.w    0,0
sprPos2:
	dc.w    $02D,$1B5
	dc.w    $035,$1B6
	dc.w    $03D,$1B7
	dc.w    $045,$1B8
	dc.w    $04D,$1B9
	dc.w    $055,$1BA
	dc.w    $05D,$1BB
	dc.w    $065,$1BC
	dc.w    $06D,$1BD
	dc.w    $075,$1BE
	dc.w    $07E,$1B5
	dc.w    $086,$1B6
	dc.w    $08E,$1B7
	dc.w    $096,$1B8
	dc.w    $09E,$1B9
	dc.w    $0A6,$1BA
	dc.w    $0AE,$1BB
	dc.w    $0B6,$1BC
	dc.w    $0BE,$1BD
	dc.w    $0C6,$1BE
	dc.w    0,0

	cnop    0,8
bitBuf:   ds.b BUF_SIZE
	cnop    0,8
sprBuf0:  ds.b SPR_BUF_SIZE
	cnop    0,8
sprBuf2:  ds.b SPR_BUF_SIZE
	cnop    0,8
sprNull:  ds.b 8
