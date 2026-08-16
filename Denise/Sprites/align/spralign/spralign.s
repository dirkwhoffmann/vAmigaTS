;
; spralign -- do the sprite and the bitplane coordinate systems agree?
;
; The same stripe pattern is drawn twice over the same ground: once by one
; bitplane and once by eight sprites, in the same colour and with the same
; period. Where the two coordinate systems agree the sprites cannot be seen
; at all. Where they disagree by even one pixel the sprite stripes sit
; beside the bitplane stripes instead of on top of them, and the overlap
; shows up as a seam.
;
; Reading a position off a photograph of a real monitor is limited by colour
; bleeding between neighbouring pixels. This test does not ask for a
; position to be read: it asks whether something disappears, which survives
; bleeding far better.
;
;
; THE CONTROL
; -----------
;
; A pattern that is invisible when correct is worthless without proof that
; it is being drawn at all. Each section is therefore split in half. The
; upper half sets the sprite colour to the bitplane stripe colour, so a
; correct sprite vanishes. The lower half sets it to red, so the same
; sprites appear in the same places and their alignment with the bitplane
; stripes can be read directly.
;
; A seam in the upper half and red stripes sitting squarely on the white
; ones in the lower half mean the same thing and should be seen together.
;
;
; THE THREE SECTIONS
; ------------------
;
; Lores, hires and super hires, because a sprite pixel is not the same size
; as a bitplane pixel in all of them. A sprite pixel is one lores pixel wide
; in lores and in hires, and half of one in super hires, so the sprite data
; is $F0F0 in the first two sections and $FF00 in the third to
; produce the same stripe on the screen. If the widths were modelled wrongly
; the third section would show stripes of the wrong pitch while the first
; two stayed clean.
;
; The stripe period is eight lores pixels, four on and four off, which is a
; whole number of pixels in every resolution and in every sprite width.
;
;
; BRDRBLNK is set on all data lines, so the border is pure black and the
; left edge of the picture is a hard step. That makes the absolute position
; of the pattern readable against the border as well as against the ruler,
; which is what the two Copper ruler lines at the top of each section are
; for.
;

	include "../../../../include/registers.i"
	include "../../../../include/ministartup.i"

LVL3_INT_VECTOR     equ $6C
BPLCON3             equ $106           ; ECS and AGA
BRDRBLNK            equ $0020          ; BPLCON3 bit 5

BPLCON0_OFF         equ $0201          ; ECSENA set, no bitplanes
LORES_BITS          equ $0201
HIRES_BITS          equ $8201
SHRES_BITS          equ $0241

DIW_START           equ $2C71          ; left of the data, so the data is the edge
DIW_STOP            equ $2CC1

BACKGND             equ $444           ; index 0, the gaps between the stripes
STRIPES             equ $FFF           ; index 1, and the sprite when hidden
SPRSHOW             equ $F00           ; the sprite in the lower half
RULER_A             equ $FFF
RULER_B             equ $00A
RULER_0             equ $F00
RULER_9             equ $0F0

LWORD               equ $F0F0          ; 4 lores pixels on, 4 off
HWORD               equ $FF00          ; the same, in hires pixels
SWORD               equ $FFFF          ; the same, in super hires pixels
SPR_LH              equ $F0F0          ; sprite pixels are lores wide here
SPR_S               equ $FF00          ; and half that in super hires

NSPR                equ 8
SPACING             equ 32           ; lores pixels between sprites
FIRST               equ $80          ; first bitplane pixel, measured

BUF_SIZE            equ 1024
SPR_BUF             equ 1024

MAIN:
	lea     CUSTOM,a1
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #BPLCON0_OFF,BPLCON0(a1)
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01
	lea     irq3(pc),a3
	move.l  a3,LVL3_INT_VECTOR

	; One buffer per section, each filled with the word that draws the
	; same stripe on the screen in that resolution.
	lea     bitL(pc),a2
	move.w  #LWORD,d1
	bsr     .fill
	lea     bitH(pc),a2
	move.w  #HWORD,d1
	bsr     .fill
	lea     bitS(pc),a2
	move.w  #SWORD,d1
	bsr     .fillAlt

	; Patch the bitplane pointer of every line, section by section
	lea     ptrL(pc),a4
	lea     bitL(pc),a3
	bsr     .patchPtrs
	lea     ptrH(pc),a4
	lea     bitH(pc),a3
	bsr     .patchPtrs
	lea     ptrS(pc),a4
	lea     bitS(pc),a3
	bsr     .patchPtrs

	; Build the eight sprite lists and patch their pointers
	bsr     .buildSprites

	lea     CUSTOM,a1
	lea     copper(pc),a0
	move.l  a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	move.w  #$8080,DMACON(a1)   ; Copper DMA
	move.w  #$8100,DMACON(a1)   ; Bitplane DMA
	move.w  #$8020,DMACON(a1)   ; Sprite DMA
	move.w  #$8200,DMACON(a1)   ; DMAEN
	move.w  #$C020,INTENA(a1)
.mainLoop:
	bra.b   .mainLoop

.fill:
	move.w  #(BUF_SIZE/2)-1,d0
.fillLoop:
	move.w  d1,(a2)+
	dbra    d0,.fillLoop
	rts

.fillAlt:
	; An empty word followed by a solid one, which is the same stripe
	; again when a bitplane pixel is a quarter of a lores pixel. The
	; empty word comes first because the super hires data starts eight
	; screen columns left of the other two sections, which would
	; otherwise put this section half a period out of phase with the
	; sprites and drop them into the gaps.
	move.w  #(BUF_SIZE/4)-1,d0
.altLoop:
	clr.w   (a2)+
	move.w  d1,(a2)+
	dbra    d0,.altLoop
	rts

.patchPtrs:
	; a4 = table of copper block addresses, a3 = buffer
	move.l  a3,d3
.ppLoop:
	move.l  (a4)+,d4
	beq.s   .ppDone
	move.l  d4,a2
	move.l  d3,d5
	swap    d5
	move.w  d5,2(a2)            ; high word -> BPL1PTH
	move.w  d3,6(a2)            ; low  word -> BPL1PTL
	bra.s   .ppLoop
.ppDone:
	rts

.buildSprites:
	lea     sprBufs(pc),a0      ; running write pointer
	lea     sprPtrs(pc),a2      ; copper blocks to patch
	moveq   #0,d7               ; sprite index
.bsSprite:
	move.l  a0,d3               ; remember where this list starts
	move.w  #FIRST,d1
	move.w  d7,d0
	mulu    #SPACING,d0
	add.w   d0,d1               ; d1 = HSTART of this sprite

	lea     .sectab(pc),a5
	moveq   #2,d6               ; three sections
.bsSection:
	move.w  (a5)+,d2            ; VSTART
	move.w  (a5)+,d4            ; VSTOP
	move.w  (a5)+,d5            ; the data word for this section

	; SPRxPOS: VSTART bits 7-0, HSTART bits 8-1
	move.w  d2,d0
	lsl.w   #8,d0
	move.w  d1,-(sp)
	lsr.w   #1,d1
	and.w   #$00FF,d1
	or.w    d1,d0
	move.w  (sp)+,d1
	move.w  d0,(a0)+

	; SPRxCTL: VSTOP bits 7-0, then HSTART bit 0
	move.w  d4,d0
	lsl.w   #8,d0
	btst    #0,d1
	beq.s   .bsNoH0
	or.w    #$0001,d0
.bsNoH0:
	move.w  d0,(a0)+

	; one line of data per rasterline the entry covers
	move.w  d4,d0
	sub.w   d2,d0
	subq.w  #1,d0
.bsLine:
	move.w  d5,(a0)+            ; plane A carries the stripe
	clr.w   (a0)+               ; plane B is empty, so colour 1 throughout
	dbra    d0,.bsLine

	dbra    d6,.bsSection

	clr.l   (a0)+               ; end of this sprite's list

	; patch this sprite's pointer pair in the Copper list
	move.l  d3,d5
	swap    d5
	move.w  d5,2(a2)
	move.w  d3,6(a2)
	addq.l  #8,a2

	addq.w  #1,d7
	cmp.w   #NSPR,d7
	bne     .bsSprite
	rts

.sectab:
	dc.w    $32,$74,SPR_LH
	dc.w    $76,$B8,SPR_LH
	dc.w    $BA,$FC,SPR_S

irq3:
	movem.l d0-a6,-(sp)
	move.w  #$3FFF,INTREQ(a1)
	movem.l (sp)+,d0-a6
	rte

copper:
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024           ; playfield behind the sprites
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DDFSTRT,$0038
	dc.w    DDFSTOP,$00D0
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000
	dc.w    COLOR00,BACKGND
	dc.w    COLOR01,STRIPES
	; Colour 1 of each sprite pair: 0/1 use 17, 2/3 use 21, 4/5 use 25,
	; 6/7 use 29. All four have to be set or half the sprites come out
	; in whatever those registers happen to hold.
	dc.w    COLOR17,STRIPES
	dc.w    COLOR21,STRIPES
	dc.w    COLOR25,STRIPES
	dc.w    COLOR29,STRIPES

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
	; LORES section, lines $30-$73
	;
	dc.w    $3001,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000           ; border open, or the ruler is swallowed
	dc.w    COLOR00,$000
	dc.w    $3131,$FFFE
	dc.w    COLOR00,RULER_0
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_9
	dc.w    $31E1,$FFFE
	dc.w    COLOR00,BACKGND
	dc.w    $3201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,(1<<12)|LORES_BITS
	dc.w    COLOR17,STRIPES         ; upper half: the sprites vanish
	dc.w    COLOR21,STRIPES
	dc.w    COLOR25,STRIPES
	dc.w    COLOR29,STRIPES
bplLORES2:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $3301,$FFFE
bplLORES3:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $3401,$FFFE
bplLORES4:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $3501,$FFFE
bplLORES5:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $3601,$FFFE
bplLORES6:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $3701,$FFFE
bplLORES7:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $3801,$FFFE
bplLORES8:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $3901,$FFFE
bplLORES9:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $3A01,$FFFE
bplLORES10:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $3B01,$FFFE
bplLORES11:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $3C01,$FFFE
bplLORES12:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $3D01,$FFFE
bplLORES13:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $3E01,$FFFE
bplLORES14:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $3F01,$FFFE
bplLORES15:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4001,$FFFE
bplLORES16:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4101,$FFFE
bplLORES17:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4201,$FFFE
bplLORES18:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4301,$FFFE
bplLORES19:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4401,$FFFE
bplLORES20:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4501,$FFFE
bplLORES21:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4601,$FFFE
bplLORES22:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4701,$FFFE
bplLORES23:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4801,$FFFE
bplLORES24:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4901,$FFFE
bplLORES25:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4A01,$FFFE
bplLORES26:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4B01,$FFFE
bplLORES27:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4C01,$FFFE
bplLORES28:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4D01,$FFFE
bplLORES29:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4E01,$FFFE
bplLORES30:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $4F01,$FFFE
bplLORES31:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5001,$FFFE
bplLORES32:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5101,$FFFE
bplLORES33:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5201,$FFFE
bplLORES34:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5301,$FFFE
	dc.w    COLOR17,SPRSHOW         ; lower half: the same sprites, in red
	dc.w    COLOR21,SPRSHOW
	dc.w    COLOR25,SPRSHOW
	dc.w    COLOR29,SPRSHOW
bplLORES35:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5401,$FFFE
bplLORES36:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5501,$FFFE
bplLORES37:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5601,$FFFE
bplLORES38:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5701,$FFFE
bplLORES39:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5801,$FFFE
bplLORES40:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5901,$FFFE
bplLORES41:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5A01,$FFFE
bplLORES42:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5B01,$FFFE
bplLORES43:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5C01,$FFFE
bplLORES44:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5D01,$FFFE
bplLORES45:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5E01,$FFFE
bplLORES46:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $5F01,$FFFE
bplLORES47:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6001,$FFFE
bplLORES48:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6101,$FFFE
bplLORES49:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6201,$FFFE
bplLORES50:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6301,$FFFE
bplLORES51:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6401,$FFFE
bplLORES52:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6501,$FFFE
bplLORES53:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6601,$FFFE
bplLORES54:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6701,$FFFE
bplLORES55:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6801,$FFFE
bplLORES56:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6901,$FFFE
bplLORES57:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6A01,$FFFE
bplLORES58:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6B01,$FFFE
bplLORES59:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6C01,$FFFE
bplLORES60:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6D01,$FFFE
bplLORES61:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6E01,$FFFE
bplLORES62:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $6F01,$FFFE
bplLORES63:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $7001,$FFFE
bplLORES64:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $7101,$FFFE
bplLORES65:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $7201,$FFFE
bplLORES66:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $7301,$FFFE
bplLORES67:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $73E1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	;
	; HIRES section, lines $74-$B7
	;
	dc.w    $7401,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000           ; border open, or the ruler is swallowed
	dc.w    COLOR00,$000
	dc.w    $7531,$FFFE
	dc.w    COLOR00,RULER_0
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_9
	dc.w    $75E1,$FFFE
	dc.w    COLOR00,BACKGND
	dc.w    $7601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,(1<<12)|HIRES_BITS
	dc.w    COLOR17,STRIPES         ; upper half: the sprites vanish
	dc.w    COLOR21,STRIPES
	dc.w    COLOR25,STRIPES
	dc.w    COLOR29,STRIPES
bplHIRES2:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $7701,$FFFE
bplHIRES3:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $7801,$FFFE
bplHIRES4:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $7901,$FFFE
bplHIRES5:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $7A01,$FFFE
bplHIRES6:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $7B01,$FFFE
bplHIRES7:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $7C01,$FFFE
bplHIRES8:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $7D01,$FFFE
bplHIRES9:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $7E01,$FFFE
bplHIRES10:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $7F01,$FFFE
bplHIRES11:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8001,$FFFE
bplHIRES12:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8101,$FFFE
bplHIRES13:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8201,$FFFE
bplHIRES14:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8301,$FFFE
bplHIRES15:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8401,$FFFE
bplHIRES16:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8501,$FFFE
bplHIRES17:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8601,$FFFE
bplHIRES18:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8701,$FFFE
bplHIRES19:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8801,$FFFE
bplHIRES20:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8901,$FFFE
bplHIRES21:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8A01,$FFFE
bplHIRES22:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8B01,$FFFE
bplHIRES23:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8C01,$FFFE
bplHIRES24:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8D01,$FFFE
bplHIRES25:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8E01,$FFFE
bplHIRES26:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $8F01,$FFFE
bplHIRES27:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9001,$FFFE
bplHIRES28:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9101,$FFFE
bplHIRES29:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9201,$FFFE
bplHIRES30:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9301,$FFFE
bplHIRES31:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9401,$FFFE
bplHIRES32:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9501,$FFFE
bplHIRES33:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9601,$FFFE
bplHIRES34:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9701,$FFFE
	dc.w    COLOR17,SPRSHOW         ; lower half: the same sprites, in red
	dc.w    COLOR21,SPRSHOW
	dc.w    COLOR25,SPRSHOW
	dc.w    COLOR29,SPRSHOW
bplHIRES35:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9801,$FFFE
bplHIRES36:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9901,$FFFE
bplHIRES37:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9A01,$FFFE
bplHIRES38:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9B01,$FFFE
bplHIRES39:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9C01,$FFFE
bplHIRES40:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9D01,$FFFE
bplHIRES41:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9E01,$FFFE
bplHIRES42:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $9F01,$FFFE
bplHIRES43:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $A001,$FFFE
bplHIRES44:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $A101,$FFFE
bplHIRES45:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $A201,$FFFE
bplHIRES46:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $A301,$FFFE
bplHIRES47:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $A401,$FFFE
bplHIRES48:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $A501,$FFFE
bplHIRES49:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $A601,$FFFE
bplHIRES50:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $A701,$FFFE
bplHIRES51:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $A801,$FFFE
bplHIRES52:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $A901,$FFFE
bplHIRES53:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $AA01,$FFFE
bplHIRES54:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $AB01,$FFFE
bplHIRES55:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $AC01,$FFFE
bplHIRES56:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $AD01,$FFFE
bplHIRES57:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $AE01,$FFFE
bplHIRES58:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $AF01,$FFFE
bplHIRES59:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $B001,$FFFE
bplHIRES60:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $B101,$FFFE
bplHIRES61:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $B201,$FFFE
bplHIRES62:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $B301,$FFFE
bplHIRES63:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $B401,$FFFE
bplHIRES64:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $B501,$FFFE
bplHIRES65:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $B601,$FFFE
bplHIRES66:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $B701,$FFFE
bplHIRES67:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $B7E1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	;
	; SHRES section, lines $B8-$FB
	;
	dc.w    $B801,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000           ; border open, or the ruler is swallowed
	dc.w    COLOR00,$000
	dc.w    $B931,$FFFE
	dc.w    COLOR00,RULER_0
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_A
	dc.w    COLOR00,RULER_B
	dc.w    COLOR00,RULER_9
	dc.w    $B9E1,$FFFE
	dc.w    COLOR00,BACKGND
	dc.w    $BA01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    BPLCON0,(1<<12)|SHRES_BITS
	dc.w    COLOR17,STRIPES         ; upper half: the sprites vanish
	dc.w    COLOR21,STRIPES
	dc.w    COLOR25,STRIPES
	dc.w    COLOR29,STRIPES
bplSHRES2:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $BB01,$FFFE
bplSHRES3:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $BC01,$FFFE
bplSHRES4:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $BD01,$FFFE
bplSHRES5:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $BE01,$FFFE
bplSHRES6:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $BF01,$FFFE
bplSHRES7:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $C001,$FFFE
bplSHRES8:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $C101,$FFFE
bplSHRES9:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $C201,$FFFE
bplSHRES10:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $C301,$FFFE
bplSHRES11:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $C401,$FFFE
bplSHRES12:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $C501,$FFFE
bplSHRES13:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $C601,$FFFE
bplSHRES14:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $C701,$FFFE
bplSHRES15:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $C801,$FFFE
bplSHRES16:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $C901,$FFFE
bplSHRES17:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $CA01,$FFFE
bplSHRES18:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $CB01,$FFFE
bplSHRES19:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $CC01,$FFFE
bplSHRES20:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $CD01,$FFFE
bplSHRES21:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $CE01,$FFFE
bplSHRES22:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $CF01,$FFFE
bplSHRES23:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $D001,$FFFE
bplSHRES24:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $D101,$FFFE
bplSHRES25:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $D201,$FFFE
bplSHRES26:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $D301,$FFFE
bplSHRES27:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $D401,$FFFE
bplSHRES28:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $D501,$FFFE
bplSHRES29:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $D601,$FFFE
bplSHRES30:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $D701,$FFFE
bplSHRES31:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $D801,$FFFE
bplSHRES32:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $D901,$FFFE
bplSHRES33:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $DA01,$FFFE
bplSHRES34:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $DB01,$FFFE
	dc.w    COLOR17,SPRSHOW         ; lower half: the same sprites, in red
	dc.w    COLOR21,SPRSHOW
	dc.w    COLOR25,SPRSHOW
	dc.w    COLOR29,SPRSHOW
bplSHRES35:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $DC01,$FFFE
bplSHRES36:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $DD01,$FFFE
bplSHRES37:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $DE01,$FFFE
bplSHRES38:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $DF01,$FFFE
bplSHRES39:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $E001,$FFFE
bplSHRES40:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $E101,$FFFE
bplSHRES41:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $E201,$FFFE
bplSHRES42:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $E301,$FFFE
bplSHRES43:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $E401,$FFFE
bplSHRES44:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $E501,$FFFE
bplSHRES45:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $E601,$FFFE
bplSHRES46:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $E701,$FFFE
bplSHRES47:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $E801,$FFFE
bplSHRES48:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $E901,$FFFE
bplSHRES49:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $EA01,$FFFE
bplSHRES50:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $EB01,$FFFE
bplSHRES51:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $EC01,$FFFE
bplSHRES52:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $ED01,$FFFE
bplSHRES53:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $EE01,$FFFE
bplSHRES54:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $EF01,$FFFE
bplSHRES55:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $F001,$FFFE
bplSHRES56:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $F101,$FFFE
bplSHRES57:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $F201,$FFFE
bplSHRES58:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $F301,$FFFE
bplSHRES59:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $F401,$FFFE
bplSHRES60:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $F501,$FFFE
bplSHRES61:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $F601,$FFFE
bplSHRES62:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $F701,$FFFE
bplSHRES63:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $F801,$FFFE
bplSHRES64:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $F901,$FFFE
bplSHRES65:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $FA01,$FFFE
bplSHRES66:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $FB01,$FFFE
bplSHRES67:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    $FBE1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	dc.w    $FC01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.l    $FFFFFFFE

ptrL:
	dc.l    bplLORES2,bplLORES3,bplLORES4,bplLORES5
	dc.l    bplLORES6,bplLORES7,bplLORES8,bplLORES9
	dc.l    bplLORES10,bplLORES11,bplLORES12,bplLORES13
	dc.l    bplLORES14,bplLORES15,bplLORES16,bplLORES17
	dc.l    bplLORES18,bplLORES19,bplLORES20,bplLORES21
	dc.l    bplLORES22,bplLORES23,bplLORES24,bplLORES25
	dc.l    bplLORES26,bplLORES27,bplLORES28,bplLORES29
	dc.l    bplLORES30,bplLORES31,bplLORES32,bplLORES33
	dc.l    bplLORES34,bplLORES35,bplLORES36,bplLORES37
	dc.l    bplLORES38,bplLORES39,bplLORES40,bplLORES41
	dc.l    bplLORES42,bplLORES43,bplLORES44,bplLORES45
	dc.l    bplLORES46,bplLORES47,bplLORES48,bplLORES49
	dc.l    bplLORES50,bplLORES51,bplLORES52,bplLORES53
	dc.l    bplLORES54,bplLORES55,bplLORES56,bplLORES57
	dc.l    bplLORES58,bplLORES59,bplLORES60,bplLORES61
	dc.l    bplLORES62,bplLORES63,bplLORES64,bplLORES65
	dc.l    bplLORES66,bplLORES67
	dc.l    0
ptrH:
	dc.l    bplHIRES2,bplHIRES3,bplHIRES4,bplHIRES5
	dc.l    bplHIRES6,bplHIRES7,bplHIRES8,bplHIRES9
	dc.l    bplHIRES10,bplHIRES11,bplHIRES12,bplHIRES13
	dc.l    bplHIRES14,bplHIRES15,bplHIRES16,bplHIRES17
	dc.l    bplHIRES18,bplHIRES19,bplHIRES20,bplHIRES21
	dc.l    bplHIRES22,bplHIRES23,bplHIRES24,bplHIRES25
	dc.l    bplHIRES26,bplHIRES27,bplHIRES28,bplHIRES29
	dc.l    bplHIRES30,bplHIRES31,bplHIRES32,bplHIRES33
	dc.l    bplHIRES34,bplHIRES35,bplHIRES36,bplHIRES37
	dc.l    bplHIRES38,bplHIRES39,bplHIRES40,bplHIRES41
	dc.l    bplHIRES42,bplHIRES43,bplHIRES44,bplHIRES45
	dc.l    bplHIRES46,bplHIRES47,bplHIRES48,bplHIRES49
	dc.l    bplHIRES50,bplHIRES51,bplHIRES52,bplHIRES53
	dc.l    bplHIRES54,bplHIRES55,bplHIRES56,bplHIRES57
	dc.l    bplHIRES58,bplHIRES59,bplHIRES60,bplHIRES61
	dc.l    bplHIRES62,bplHIRES63,bplHIRES64,bplHIRES65
	dc.l    bplHIRES66,bplHIRES67
	dc.l    0
ptrS:
	dc.l    bplSHRES2,bplSHRES3,bplSHRES4,bplSHRES5
	dc.l    bplSHRES6,bplSHRES7,bplSHRES8,bplSHRES9
	dc.l    bplSHRES10,bplSHRES11,bplSHRES12,bplSHRES13
	dc.l    bplSHRES14,bplSHRES15,bplSHRES16,bplSHRES17
	dc.l    bplSHRES18,bplSHRES19,bplSHRES20,bplSHRES21
	dc.l    bplSHRES22,bplSHRES23,bplSHRES24,bplSHRES25
	dc.l    bplSHRES26,bplSHRES27,bplSHRES28,bplSHRES29
	dc.l    bplSHRES30,bplSHRES31,bplSHRES32,bplSHRES33
	dc.l    bplSHRES34,bplSHRES35,bplSHRES36,bplSHRES37
	dc.l    bplSHRES38,bplSHRES39,bplSHRES40,bplSHRES41
	dc.l    bplSHRES42,bplSHRES43,bplSHRES44,bplSHRES45
	dc.l    bplSHRES46,bplSHRES47,bplSHRES48,bplSHRES49
	dc.l    bplSHRES50,bplSHRES51,bplSHRES52,bplSHRES53
	dc.l    bplSHRES54,bplSHRES55,bplSHRES56,bplSHRES57
	dc.l    bplSHRES58,bplSHRES59,bplSHRES60,bplSHRES61
	dc.l    bplSHRES62,bplSHRES63,bplSHRES64,bplSHRES65
	dc.l    bplSHRES66,bplSHRES67
	dc.l    0

	cnop    0,8
bitL:    ds.b BUF_SIZE
	cnop    0,8
bitH:    ds.b BUF_SIZE
	cnop    0,8
bitS:    ds.b BUF_SIZE
	cnop    0,8
sprBufs: ds.b NSPR*SPR_BUF
