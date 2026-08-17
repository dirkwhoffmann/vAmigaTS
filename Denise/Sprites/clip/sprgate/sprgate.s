
; sprgate.s -- when the window opens, when does the sprite arrive?
;
; Agnus/AGA/BPLAM/bplam9 measured this on an A1200 and found that the sprite
; arrives one screen column AFTER the display window opens: there is exactly
; one column of playfield between the last border pixel and the first sprite
; pixel. vAmiga models that with SPRITE_LATENCY = BPLDAT_LATENCY + 2, which
; is chipset independent -- and nothing has ever checked it on OCS or ECS.
; bplam9 cannot: BPLAM is an AGA register and the effect was only legible in
; super hires, which ECS Denise does not have.
;
; This test asks the same thing with nothing but OCS/ECS features.
;
; The trick is bplam9's: make the sprite the SAME COLOUR as the border, so
; that the two merge and the only thing that can separate them is playfield
; getting in between. BRDRBLNK forces the border to pure black and COLOR17
; is black, so:
;
;   sprite clipped by the window   black border runs straight into black
;                                  sprite; nothing to see
;
;   sprite clear of the window     black border, then a strip of blue
;                                  playfield, then the black sprite
;
; Ten bands per section, the sprite one lores pixel further right in each.
; The measurement is not a width or a position but WHICH BAND IS THE FIRST
; to show blue between the border and the sprite. A latency error of one
; column moves that band by one, and counting bands survives any amount of
; colour bleeding.
;
; Every band is followed by three lines with no sprite at all, which show
; where the window edge is on its own. So each band carries its own
; reference on the two rasterlines above and below it.
;
; The third section repeats the first with BRDRBLNK CLEARED, so the border
; takes COLOR00 and is blue like the playfield. The black sprite is then
; visible against blue on both sides, which shows where each sprite really
; is and proves that all ten are being drawn. Without it, a picture in
; which the sprites never appeared would look like a valid result.
;
; A Copper ruler line sits at the top of each section. It is not needed for
; the reading above; it is there so that a photograph can still be measured
; in columns if the counting comes out ambiguous.
;
	include "../../../../include/registers.i"
	include "../../../../include/ministartup.i"

LVL3_INT_VECTOR     equ $6C
BPLCON3             equ $106           ; ECS and AGA

BRDRBLNK            equ $0020          ; BPLCON3 bit 5

BPLCON0_OFF         equ $0201          ; ECSENA, no bitplanes
LORES_BITS          equ $1201          ; one bitplane, lores
HIRES_BITS          equ $9201          ; one bitplane, hires

DIW_START           equ $2C61          ; far left, so the data gate decides
DIW_STOP            equ $2CC1

COL_BACK            equ $04C           ; the playfield, and index 0
COL_SPR             equ $000           ; the sprite, and a blanked border

RULER_A             equ $FFF
RULER_B             equ $00A
RULER_5             equ $FF0
RULER_0             equ $F00
RULER_9             equ $0F0

SPR_H               equ 5
SPR_BUF_SIZE        equ 728
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

	; One bitplane of zeros: every pixel of the window is index 0, which
	; is COLOR00. The window is a flat field of one colour and the only
	; structure in it is the sprite.
	lea     bitBuf(pc),a2
	move.w  #(BUF_SIZE/2)-1,d0
.clrLoop:
	clr.w   (a2)+
	dbra    d0,.clrLoop

	; The sprite colours. Colour 1 is the sprite body and it is black,
	; the same black BRDRBLNK makes of the border.
	move.w  #COL_SPR,COLOR17(a1)
	move.w  #COL_SPR,COLOR18(a1)
	move.w  #COL_SPR,COLOR19(a1)

	bsr     .buildSprite

	lea     bitBuf(pc),a3
	move.l  a3,d3
	lea     bplPtr(pc),a2
	move.l  d3,d4
	swap    d4
	move.w  d4,2(a2)
	move.w  d3,6(a2)

	; Sprite DMA runs for the whole channel set, so the seven unused
	; sprites need a list of their own or they fetch garbage.
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

	move.w  #$8080,DMACON(a1)   ; Copper DMA
	move.w  #$8100,DMACON(a1)   ; Bitplane DMA
	move.w  #$8020,DMACON(a1)   ; Sprite DMA
	move.w  #$8200,DMACON(a1)   ; DMAEN
	move.w  #$C020,INTENA(a1)
.mainLoop:
	bra.b   .mainLoop

.patchPtr:
	move.w  d3,6(a2)
	swap    d3
	move.w  d3,2(a2)
	addq.l  #8,a2
	rts

; Walks the (VSTART, HSTART) table and writes one sprite entry per group.
; The control words are computed rather than assembled because the picture
; runs past line 255 and the ninth vertical bit lives in SPRxCTL.
.buildSprite:
	lea     sprBuf(pc),a0
	lea     sprPos(pc),a4
.bsLoop:
	move.w  (a4)+,d2               ; VSTART
	beq.s   .bsDone
	move.w  (a4)+,d1               ; HSTART, in lores pixels
	move.w  d2,d4
	add.w   #SPR_H,d4              ; VSTOP

	move.w  d2,d5                  ; SPRxPOS
	and.w   #$00FF,d5
	lsl.w   #8,d5
	move.w  d1,d6
	lsr.w   #1,d6
	and.w   #$00FF,d6
	or.w    d6,d5
	move.w  d5,(a0)+

	move.w  d4,d5                  ; SPRxCTL
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

	; SPR_H lines of solid colour 1: every bit set in the first word,
	; none in the second.
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
	dc.l    sprBuf
	dc.l    sprNull,sprNull,sprNull,sprNull,sprNull,sprNull,sprNull

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
	dc.w    BPL1MOD,$FFD8           ; -40: every line refetches
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
	; LORES section, lines $2C-$7C, HSTART $7B to $84
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
	; HIRES section, lines $7D-$CD, HSTART $73 to $7C
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

	;
	; OPEN section, lines $CE-$11E, HSTART $7B to $84, border NOT blanked
	;
	dc.w    $CE01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.w    $CE31,$FFFE
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
	dc.w    $CF01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $D701,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $DF01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $E701,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $EF01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $F701,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $FF01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $FFDF,$FFFE             ; cross the 8 bit vertical boundary
	dc.w    $0001,$FFFE             ; re-sync at the start of line 256
	dc.w    $0701,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $0F01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $1701,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON0,LORES_BITS
	dc.w    COLOR00,COL_BACK
	dc.w    $1EE1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    $1F01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.l    $FFFFFFFE

sprPos:
	; VSTART, HSTART for each of the 30 groups
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
	dc.w    $0CF,$07B
	dc.w    $0D7,$07C
	dc.w    $0DF,$07D
	dc.w    $0E7,$07E
	dc.w    $0EF,$07F
	dc.w    $0F7,$080
	dc.w    $0FF,$081
	dc.w    $107,$082
	dc.w    $10F,$083
	dc.w    $117,$084
	dc.w    0,0

	cnop    0,8
bitBuf:  ds.b BUF_SIZE
	cnop    0,8
sprBuf:  ds.b SPR_BUF_SIZE
	cnop    0,8
sprNull: ds.b 8
