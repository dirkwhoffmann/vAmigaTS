; shpattern.i -- shared body for the Denise/Modes shpattern1-8 tests.
;
; The including file must define, before "include"-ing this, either
;   RULER_BYTE   the repeating byte pattern loaded into rulerBuf (bitplane 1)
;   SOLID_BYTE   the repeating byte pattern loaded into solidBuf (bitplane 2)
; or, for patterns whose runs exceed a byte, the 16 bit fill words directly
;   RULER_WORD   the repeating word loaded into rulerBuf (bitplane 1)
;   SOLID_WORD   the repeating word loaded into solidBuf (bitplane 2)
; and may optionally define:
;   DDF_START  DDFSTRT (default $0038)
;   DDF_STOP   DDFSTOP (default $00B0)
; and must itself have already included registers.i, hardware/dmabits.i,
; hardware/intbits.i and ministartup.s (see shpattern1/shpattern1.s for the
; exact boilerplate) -- this file has no includes of its own so it stays
; agnostic of the including file's directory depth.
;
;
; WHAT IS UNDER TEST
; ------------------
;
; Super hires, BPLCON0 bit 6: the ECS Denise display mode that halves the
; pixel again below hires, and the reason these tests are A500+ material
; rather than AGA material. ECS super hires tops out at two bitplanes, so
; two planes is the ceiling here -- and four colours is the whole palette
; a two plane picture can address.
;
; Each region sweeps that range rather than sitting at the top of it: its
; upper half runs 1 bitplane, its lower half 2. Plane 2 therefore arrives
; part way down a region that is otherwise unchanged, which makes its
; contribution readable as a horizontal seam instead of having to be
; inferred by comparing one test against another. Above the seam only
; COLOR00 and COLOR01 can appear; below it all four are in play.
;
; Nothing AGA is touched. There is no FMODE, no BPLCON3/BPLCON4, no colour
; banking or LOCT, and no bitplanes 7 and 8. The picture is built from two
; bitplane pointers; planes 3 to 6 exist only to be pinned to a zeroed
; buffer, so that nothing stale can leak into it (see below).
;
; What varies between the eight tests is the bit pattern feeding each of
; the two planes:
;
;   rulerBuf (bitplane 1)  RULER_BYTE, repeated
;   solidBuf (bitplane 2)  SOLID_BYTE, repeated
;
; Both are byte patterns replicated across every word of the buffer, so the
; picture is word-periodic: it cannot shear or drift no matter what super
; hires does with the DDF window, and a black band means "no data arrived"
; rather than "the data landed somewhere unexpected".
;
; In HIRES the colour a pixel ends up with is a direct readout of the two
; pattern bits at that position:
;
;   plane2 plane1   index   colour
;      0     0        0     black
;      0     1        1     red
;      1     0        2     green
;      1     1        3     blue
;
; SUPER HIRES DOES NOT WORK THAT WAY, which is the whole reason this test
; initialises all 32 colour registers instead of the four a two plane mode
; would seem to need. ECS Denise cannot look a colour up per pixel at the
; super hires dot rate, so it takes pixels in PAIRS and concatenates them
; into one index:
;
;   index = (pixel1 & 3) * 4 + (pixel0 & 3) + ((pixel0 | pixel1) & 16)
;
; Two bitplanes therefore address COLOR00 to COLOR15, not COLOR00 to
; COLOR03, and bitplane 5 -- if it is ever enabled -- adds bit 4 on top for
; a range of COLOR00 to COLOR31. Denise then splits the register it picked
; across the pair: the first pixel shows the high bit pair of each RGB
; nibble, the second the low bit pair.
;
; A test that initialises only COLOR00-03 hits uninitialised registers
; almost everywhere in its super hires region and paints whatever Kickstart
; happened to leave behind -- on an A500+ that reads as a flat white block,
; even in a section running a single bitplane, where the pairing still
; reaches COLOR05. That is exactly what the earlier revision of this test
; did, and it is the trap this palette exists to avoid.
;
;
; LAYOUT
; ------
;
;     lines $31-$5F   HIRES, 1 bitplane    the reference
;     lines $60-$8F   HIRES, 2 bitplanes
;     line  $90       the copper timing ruler from Agnus/DDF/ddf1
;     lines $95-$C3   SHRES, 1 bitplane    under test
;     lines $C4-$F3   SHRES, 2 bitplanes
;
; The hires region is the control: same planes, same patterns, same seam,
; at a pixel twice as wide. Reading the super hires region against it
; separates "super hires got this wrong" from "this pattern was never
; going to work". The comb comes out twice as fine in super hires, which
; is an independent confirmation that the mode really engaged.
;
; The plane count is raised by a bare BPLCON0 write, with no blank line and
; no re-point at the seam. Plane 1 therefore runs on undisturbed across it,
; and plane 2 starts from the top of solidBuf because it never fetched
; while it was switched off, so its pointer never moved.
;
; BPLxMOD is zero and the pointers are reloaded once per region, purely to
; keep the buffers small.

	IFND DDF_START
DDF_START           equ $0038
	ENDC
	IFND DDF_STOP
DDF_STOP            equ $00B0
	ENDC

DIW_START           equ $2C00+(DDF_START*2)+9
DIW_STOP            equ $2CC1

; One region's worth of fetching, plus slack. Super hires is the binding
; case: the DDF window spans $B0-$38 = 120 colour clocks, and super hires
; fetches a word every 2 of them, so a line pulls about 122 bytes per
; plane. A region is ~95 display lines, hence ~11600 bytes. Undersizing
; this is not a loud failure -- the planes just run off the end of their
; buffers into whatever follows, which paints a plausible looking but
; wrong picture -- so keep the slack.
PLANE_SIZE          equ 16384

NUM_PLANES          equ 6             ; shres uses 2; 3-6 are pinned to zeroBuf

; A test may supply the 16 bit fill words directly instead of the bytes, which
; is what the shblocks family does: a one word period is the longest that
; still tiles a super hires line cleanly, so a pattern with runs longer than a
; byte has to be specified as a whole word.
	IFND RULER_WORD
RULER_WORD          equ (RULER_BYTE*256)+RULER_BYTE
	ENDC
	IFND SOLID_WORD
SOLID_WORD          equ (SOLID_BYTE*256)+SOLID_BYTE
	ENDC


MAIN:
	; Load base address into a1
	lea     CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Two buffers, each filled with its own caller-supplied repeating word.
	; rulerBuf feeds bitplane 1, solidBuf feeds bitplane 2.
	lea     rulerBuf,a0
	move.w  #(PLANE_SIZE/2)-1,d0
.l1: move.w  #RULER_WORD,(a0)+
	dbra    d0,.l1

	lea     solidBuf,a0
	move.w  #(PLANE_SIZE/2)-1,d0
.l2: move.w  #SOLID_WORD,(a0)+
	dbra    d0,.l2

	; Bitplanes 3 to 6 are never wanted here, but they must still point
	; somewhere defined -- see the note by DPL3DATA below.
	lea     zeroBuf,a0
	move.w  #(PLANE_SIZE/2)-1,d0
.l3: clr.w   (a0)+
	dbra    d0,.l3

	; All 32 colour registers. Two bitplanes reach only COLOR00-03 in a
	; normal mode, but ECS super hires pairs adjacent pixels into a 4 bit
	; index and so reaches COLOR00-15 (COLOR16-31 once bitplane 5 is in
	; play). Leaving the rest at whatever Kickstart put there makes a super
	; hires picture read as uninitialised garbage; see the header.
	lea     COLOR00(a1),a2
	lea     paletteTable(pc),a3
	moveq   #31,d0
.colLoop:
	move.w  (a3)+,(a2)+
	dbra    d0,.colLoop

	; The pointers alone do not settle bitplanes 3 to 6. With BPU at 1 or 2
	; those planes are never fetched, so their data registers keep whatever
	; Kickstart last left in them and a chipset that folds them into the
	; picture would paint boot screen leftovers. Clear them by hand.
	move.w  #$0000,DPL3DATA(a1)
	move.w  #$0000,DPL4DATA(a1)
	move.w  #$0000,DPL5DATA(a1)
	move.w  #$0000,DPL6DATA(a1)

	; Patch the bitplane pointers into each region's reload block, so the
	; super hires region never inherits the fetch drift of the hires one.
	lea     sectionPtrTable(pc),a4
.ptSectionLoop:
	move.l  (a4)+,d0
	beq.s   .ptDone
	move.l  d0,a2
	lea     planeTable(pc),a5
	moveq   #NUM_PLANES-1,d6
.ptPlaneLoop:
	move.l  (a5)+,d3
	move.w  d3,6(a2)                ; low  word -> BPLxPTL move
	swap    d3
	move.w  d3,2(a2)                ; high word -> BPLxPTH move
	addq.l  #8,a2
	dbra    d6,.ptPlaneLoop
	bra.s   .ptSectionLoop
.ptDone:

	; Install Copper list and enable DMA
	lea 	CUSTOM,a1
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	move.w	#$8080,DMACON(a1)   ; Copper DMA
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA
	move.w	#$8200,DMACON(a1)   ; DMAEN

.mainLoop:
	bra.b	.mainLoop

paletteTable:
	; COLOR00-31. Every nibble is drawn from $0/$5/$A/$F, i.e. from values
	; whose high and low bit pairs are equal, so ECS super hires' nibble
	; split hands both pixels of a pair the same colour and the pair reads
	; as one flat patch. A nibble like $C or $3 would instead paint the two
	; pixels differently and make the index unreadable -- worth a test of
	; its own, but not this one.
	;
	; COLOR00-03 keep the values the four colour version of this test used,
	; so the HIRES control region still reads black / red / green / blue.
	dc.w    $000,$F00,$0F0,$00F     ;  0- 3
	dc.w    $FF0,$F0F,$0FF,$FFF     ;  4- 7
	dc.w    $FA0,$A0F,$0FA,$AAA     ;  8-11
	dc.w    $F55,$5F5,$55F,$555     ; 12-15
	dc.w    $500,$050,$005,$550     ; 16-19
	dc.w    $505,$055,$A00,$0A0     ; 20-23
	dc.w    $00A,$AA0,$A0A,$0AA     ; 24-27
	dc.w    $FA5,$5AF,$AF5,$A5F     ; 28-31

planeTable:
	dc.l    rulerBuf,solidBuf,zeroBuf,zeroBuf
	dc.l    zeroBuf,zeroBuf

sectionPtrTable:
	dc.l    sech,secs
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
	; The HIRES region, the reference: 1 bitplane in its upper half,
	; 2 in its lower half.
	;
	dc.w    $3001,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
sech:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    BPL5PTH,$0000
	dc.w    BPL5PTL,$0000
	dc.w    BPL6PTH,$0000
	dc.w    BPL6PTL,$0000
	dc.w    $3101,$FFFE            ; first display line of the region
	dc.w    BPLCON0,$9200           ; 1 bitplane, hires
	dc.w    $6001,$FFFE            ; half way down: plane 2 joins in
	dc.w    BPLCON0,$A200           ; 2 bitplanes, hires

	;
	; Copper timing ruler (from ddf1), between the two regions. Each
	; MOVE takes 4 color clocks, i.e. 8 lores pixels. Bitplane DMA is
	; switched off first so the copper keeps every slot.
	;
	dc.w    $9001,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    $9000+DDF_START+1,$FFFE
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

	;
	; The SHRES region, under test: 1 bitplane in its upper half,
	; 2 in its lower half.
	;
	dc.w    $9401,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secs:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    BPL5PTH,$0000
	dc.w    BPL5PTL,$0000
	dc.w    BPL6PTH,$0000
	dc.w    BPL6PTL,$0000
	dc.w    $9501,$FFFE            ; first display line of the region
	dc.w    BPLCON0,$1240           ; 1 bitplane, shres
	dc.w    $C401,$FFFE            ; half way down: plane 2 joins in
	dc.w    BPLCON0,$2240           ; 2 bitplanes, shres

	;
	; Done -- shut the display down again.
	;
	dc.w    $F401,$FFFE
	dc.w    BPLCON0,$0200

	dc.l    $fffffffe

	cnop    0,8
rulerBuf: ds.b PLANE_SIZE
	cnop    0,8
solidBuf: ds.b PLANE_SIZE
	cnop    0,8
zeroBuf:  ds.b PLANE_SIZE
