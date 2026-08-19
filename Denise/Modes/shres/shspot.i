; shspot.i -- shared body for the Denise/Modes shspot1 to shspot16 tests.
;
; The including file must define, before "include"-ing this:
;   SPOT_REG   the colour register to light up (1 to 16)
; and may optionally define:
;   DDF_START  DDFSTRT (default $0038)
;   DDF_STOP   DDFSTOP (default $00B0)
; and must itself have already included registers.i, hardware/dmabits.i,
; hardware/intbits.i and ministartup.s (see shspot1/shspot1.s).
;
;
; WHAT IS UNDER TEST
; ------------------
;
; Which colour register a super hires pixel pair actually reaches.
;
; ECS Denise cannot look a colour up per pixel at the super hires dot rate,
; so it takes pixels in PAIRS and concatenates them into one index:
;
;   index = (pixel1 & 3) * 4 + (pixel0 & 3) + ((pixel0 | pixel1) & 16)
;
; Two bitplanes therefore reach COLOR00 to COLOR15 rather than COLOR00 to
; COLOR03. The other shres tests infer that indirectly, by reasoning about
; blended colours in a photograph. This family reads it off directly.
;
; The whole palette is blue except for two registers: COLOR00 is black, and
; the single register under test is yellow. So a yellow stripe means "the
; index landed exactly here" and everything else stays blue. Sixteen tests,
; shspot1 to shspot16, walk the yellow through COLOR01 to COLOR16.
;
; COLOR16 is the interesting end of the range: two bitplanes cannot reach
; it, because bit 4 of the index only comes from bitplane 5. shspot16 should
; therefore show NO yellow at all, and is the negative control of the set.
;
; Every colour used is drawn from nibbles $0 and $F, so it survives Denise's
; nibble split unchanged and a pair reads as one flat patch.
;
;
; THE FOUR SECTIONS
; -----------------
;
; Four super hires sections, separated by white copper bars. Each repeats a
; single 16 pixel pattern, i.e. eight pixel pairs. A one word period is the
; longest that tiles a super hires line without shearing, which is why the
; sweep is split across sections rather than laid out in one run.
;
;   section 1   indices  0  1  2  3  4  5  6  7
;   section 2   indices  8  9 10 11 12 13 14 15
;   section 3   indices  0  0  5  5 10 10 15 15   (runs of four pixels)
;   section 4   indices  4  1 14 11  4  1 14 11   (pair ordering probe)
;
; Sections 1 and 2 are the sweep: between them every reachable index appears
; exactly once, in order, so the position of the yellow stripe names the
; index directly.
;
; Section 3 holds each pixel value for four pixels, so its pairs sit well
; inside a run rather than across a boundary. Indices 0, 5, 10 and 15 show
; up there whichever way the pairing grid is phased, which makes it the one
; section that does not depend on that question.
;
; Section 4 pairs values that differ, and pairs them both ways round: (0,1)
; against (1,0), and (2,3) against (3,2). If the index really is built as
; pixel1 * 4 + pixel0 then those give 4, 1, 14 and 11; if the two pixels
; were the other way round they would give 1, 4, 11 and 14 instead. Lighting
; one register tells the two apart.
;
; The patterns are laid out for a pairing grid that starts on odd pixels,
; which is what Denise/Modes/shres/shres00 and the shblocks family measure
; on an A500+ (see SHRES_PAIR_PHASE in vAmiga's PixelEngine). Under an even
; grid the sections still show a fixed set of indices, just not this one.

	IFND DDF_START
DDF_START           equ $0038
	ENDC
	IFND DDF_STOP
DDF_STOP            equ $00B0
	ENDC

DIW_START           equ $2C00+(DDF_START*2)+9
DIW_STOP            equ $2CC1

; One section is 46 display lines and super hires pulls about 122 bytes per
; line per plane, so a little over 5600 bytes. 6144 covers that with slack.
; Eight buffers are needed (two planes for each of four sections), and the
; total matters: the buffers are emitted into the binary, so oversizing them
; pushes the program past the 512K chip RAM boundary and the tail of it
; stops being reachable by the bitplane DMA.
PLANE_SIZE          equ 6144

; Section patterns, as the 16 bit words the two planes are filled with.
P1_S1               equ $913B
P2_S1               equ $0505
P1_S2               equ $913B
P2_S2               equ $AFAF
P1_S3               equ $8787
P2_S3               equ $807F
P1_S4               equ $3333
P2_S4               equ $8787

BAR_COLOR           equ $FFF
SPOT_COLOR          equ $FF0
REST_COLOR          equ $00F


MAIN:
	lea     CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Fill the eight buffers, two per section
	lea     buf1a,a0
	move.w  #P1_S1,d1
	bsr     .fill
	lea     buf1b,a0
	move.w  #P2_S1,d1
	bsr     .fill
	lea     buf2a,a0
	move.w  #P1_S2,d1
	bsr     .fill
	lea     buf2b,a0
	move.w  #P2_S2,d1
	bsr     .fill
	lea     buf3a,a0
	move.w  #P1_S3,d1
	bsr     .fill
	lea     buf3b,a0
	move.w  #P2_S3,d1
	bsr     .fill
	lea     buf4a,a0
	move.w  #P1_S4,d1
	bsr     .fill
	lea     buf4b,a0
	move.w  #P2_S4,d1
	bsr     .fill

	; The palette: everything blue, COLOR00 black, one register yellow.
	lea     COLOR00(a1),a2
	moveq   #31,d0
.palLoop:
	move.w  #REST_COLOR,(a2)+
	dbra    d0,.palLoop
	move.w  #$0000,COLOR00(a1)
	move.w  #SPOT_COLOR,COLOR00+2*SPOT_REG(a1)

	; Bitplanes 3 to 6 are never enabled here, so they are never fetched
	; and their data registers would keep whatever Kickstart left in them.
	; Clear them, or a chipset that folds them in shows boot screen dregs.
	move.w  #$0000,DPL3DATA(a1)
	move.w  #$0000,DPL4DATA(a1)
	move.w  #$0000,DPL5DATA(a1)
	move.w  #$0000,DPL6DATA(a1)

	; Patch each section's two bitplane pointers into its copper block
	lea     sectionPtrTable(pc),a4
.ptLoop:
	move.l  (a4)+,d0
	beq.s   .ptDone
	move.l  d0,a2
	move.l  (a4)+,d3                ; bitplane 1 buffer
	move.w  d3,6(a2)
	swap    d3
	move.w  d3,2(a2)
	move.l  (a4)+,d3                ; bitplane 2 buffer
	move.w  d3,14(a2)
	swap    d3
	move.w  d3,10(a2)
	bra.s   .ptLoop
.ptDone:

	; Install Copper list and enable DMA
	lea     CUSTOM,a1
	lea     copper(pc),a0
	move.l  a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	move.w  #$8080,DMACON(a1)   ; Copper DMA
	move.w  #$8100,DMACON(a1)   ; Bitplane DMA
	move.w  #$8200,DMACON(a1)   ; DMAEN

.mainLoop:
	bra.b   .mainLoop

.fill:
	; in: a0 = buffer, d1 = fill word; clobbers d0, a0
	move.w  #(PLANE_SIZE/2)-1,d0
.fillLoop:
	move.w  d1,(a0)+
	dbra    d0,.fillLoop
	rts

sectionPtrTable:
	dc.l    sec1,buf1a,buf1b
	dc.l    sec2,buf2a,buf2b
	dc.l    sec3,buf3a,buf3b
	dc.l    sec4,buf4a,buf4b
	dc.l    0

copper:
	dc.w    BPLCON0,$0200           ; bitplanes off for now
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    DDFSTRT,DDF_START
	dc.w    DDFSTOP,DDF_STOP
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000

	;
	; Section 1: indices 0 to 7
	;
	dc.w    $3001,$FFFE
	dc.w    BPLCON0,$0200
sec1:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $3201,$FFFE
	dc.w    BPLCON0,$2240           ; 2 bitplanes, shres

	;
	; Copper bar
	;
	dc.w    $6001,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $6101,$FFFE
	dc.w    COLOR00,$0000

	;
	; Section 2: indices 8 to 15
	;
sec2:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $6301,$FFFE
	dc.w    BPLCON0,$2240

	;
	; Copper bar
	;
	dc.w    $9101,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $9201,$FFFE
	dc.w    COLOR00,$0000

	;
	; Section 3: runs of four pixels, indices 0, 5, 10, 15
	;
sec3:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $9401,$FFFE
	dc.w    BPLCON0,$2240

	;
	; Copper bar
	;
	dc.w    $C201,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $C301,$FFFE
	dc.w    COLOR00,$0000

	;
	; Section 4: pair ordering probe, indices 4, 1, 14, 11
	;
sec4:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $C501,$FFFE
	dc.w    BPLCON0,$2240

	;
	; Done -- shut the display down again.
	;
	dc.w    $F401,$FFFE
	dc.w    BPLCON0,$0200

	dc.l    $fffffffe

	cnop    0,8
buf1a: ds.b PLANE_SIZE
	cnop    0,8
buf1b: ds.b PLANE_SIZE
	cnop    0,8
buf2a: ds.b PLANE_SIZE
	cnop    0,8
buf2b: ds.b PLANE_SIZE
	cnop    0,8
buf3a: ds.b PLANE_SIZE
	cnop    0,8
buf3b: ds.b PLANE_SIZE
	cnop    0,8
buf4a: ds.b PLANE_SIZE
	cnop    0,8
buf4b: ds.b PLANE_SIZE
