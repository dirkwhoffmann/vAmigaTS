; shres.i -- shared body for the Agnus/AGA shres tests.
;
; The including file must define, before "include"-ing this:
;   FMODE      the value written to the FMODE register ($1FC)
; and may optionally define:
;   DDF_START  DDFSTRT (default $0038)
;   DDF_STOP   DDFSTOP (default $00B0)
; and must itself have already included registers.i, hardware/dmabits.i,
; hardware/intbits.i and ministartup.s (see shres00/shres00.s for the exact
; boilerplate) -- this file has no includes of its own so it stays agnostic
; of the including file's directory depth.
;
;
; WHAT IS UNDER TEST
; ------------------
;
; Super hires, BPLCON0 bit 6, the AGA display mode that halves the pixel
; again below hires. The question this suite asks is the same one the FMODE
; suite asked about hires: HOW MANY BITPLANES CAN IT ACTUALLY FETCH, and
; does FMODE change the answer?
;
; That question has a precedent. At FMODE = 0 a hires line fetches only
; bitplanes 1 to 4, because the fetch unit has no slots for planes 5 to 8;
; a non-zero FMODE widens the fetch and lifts the limit to 8. Super hires
; packs four times as many pixels into the same color clock as lores, so
; whatever its limit is, it should be tighter still.
;
; vAmiga's answer is unambiguous and worth stating up front, because it is
; the thing to check. Sequencer::computeBplEventTable enumerates hires
; bitplane counts 1 through 8, but for super hires it enumerates only 1 and
; 2 -- and anything above 2 does not degrade gracefully, it falls through
; to the zero-bitplane fetch unit. So vAmiga predicts:
;
;     BPU 1, 2     a picture
;     BPU 3 to 8   no bitplane DMA at all, i.e. a black band
;
; and it predicts that regardless of FMODE, because the plane count is
; capped before FMODE is consulted. If an A1200 paints anything at all in
; the BPU 3 sections, or if a wider FMODE lifts the cap the way it lifts
; the hires one, that is a real finding.
;
;
; LAYOUT
; ------
;
; Two regions of 8 sections each, enabling 1 to 8 bitplanes:
;
;     lines $30-$8F   HIRES, the reference
;     line  $90       the copper timing ruler from Agnus/DDF/ddf1
;     lines $94-$F3   SHRES, under test
;
; The hires region is not decoration. It is the control: it says what this
; FMODE value can fetch when the pixel is merely half a lores pixel rather
; than a quarter of one, and it is already characterised by the FMODE
; tests. Reading a shres section against the hires section directly above
; it separates "super hires cannot do this" from "this FMODE cannot do
; this".
;
; Note that BPLCON0 bit 6 alone selects super hires; the HIRES bit (15) is
; not also set, and is in fact ignored once bit 6 is set.
;
;
; THE PICTURE
; -----------
;
; Deliberately duller than the FMODE tests' staircase. Every bitplane is
; filled with a pattern that repeats every single word:
;
;     plane 1        $CCCC, i.e. on for 2 pixels, off for 2
;     planes 2 to 8  $FFFF, solid
;
; so with N planes enabled the colour index alternates between 2^N-1 and
; 2^N-2 straight across the line, and each section is one flat hue carrying
; a fine two pixel ruler. The palette keys hue on the highest set bit and
; brightness on bit 0, so the hue counts the bitplanes that arrived and the
; plane 1 ruler shows up as a bright/dim comb without ever making that
; count ambiguous.
;
; A word-periodic pattern is the point. It makes the picture completely
; independent of how many words a line fetches, so nothing here can shear
; or drift no matter what super hires turns out to do with the DDF window,
; and a black band means "no data arrived" rather than "the data landed
; somewhere unexpected". The comb also gets four times finer in super hires
; than in hires, which is an independent confirmation that the mode really
; engaged.
;
; BPLxMOD is zero and the pointers are reloaded once per section, purely to
; keep the buffers small.

BPLCON3             equ $106          ; AGA only
BPLCON4             equ $10C          ; AGA only
BPL7PTH             equ $F8           ; AGA only
BPL7PTL             equ $FA           ; AGA only
BPL8PTH             equ $FC           ; AGA only
BPL8PTL             equ $FE           ; AGA only
FMODEREG            equ $1FC          ; AGA only (the register; FMODE is the value)

	IFND DDF_START
DDF_START           equ $0038
	ENDC
	IFND DDF_STOP
DDF_STOP            equ $00B0
	ENDC

DIW_START           equ $2C00+(DDF_START*2)+9
DIW_STOP            equ $2CC1

PLANE_SIZE          equ 8192          ; one section's worth of fetching, plus slack

NUM_PLANES          equ 8


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

	; Put the chip into the fetch mode under test straight away, so the
	; state is already correct before the very first copper pass.
	move.w  #FMODE,FMODEREG(a1)

	; Two buffers, both filled with a single repeating word. rulerBuf feeds
	; bitplane 1, solidBuf feeds all seven others.
	lea     rulerBuf,a0
	move.w  #(PLANE_SIZE/2)-1,d0
.l1: move.w  #$CCCC,(a0)+
	dbra    d0,.l1

	lea     solidBuf,a0
	move.w  #(PLANE_SIZE/2)-1,d0
.l2: move.w  #$FFFF,(a0)+
	dbra    d0,.l2

	; Initialize all 256 AGA color registers (COLOR00-31 are banked 8 times
	; via BPLCON3's BANK bits, and each register's low nibble is written
	; separately with LOCT set). See .makeColor for the scheme.
	lea     CUSTOM,a1
	; Banks are processed 7 down to 0, so bank 0 (COLOR00-31, the only bank
	; OCS/ECS ever look at) is written *last*. On chipsets where BPLCON3's
	; BANK field is a no-op every "bank" write lands in the same physical 32
	; registers, so whichever bank is processed last is what sticks -- it has
	; to be bank 0, or the visible palette ends up being bank 7's.
	moveq   #7,d7                   ; d7 = bank (7 downto 0)
.colorBankLoop:
	move.w  d7,d0
	lsl.w   #8,d0                   ; BANK2-0 -> BPLCON3 bits 15-13
	lsl.w   #5,d0
	move.w  d0,BPLCON3(a1)          ; LOCT=0: write high nibble of R,G,B
	lea     COLOR00(a1),a2
	moveq   #0,d6                   ; d6 = register number within bank (0-31)
.colorHiLoop:
	move.w  d7,d5
	lsl.w   #5,d5
	or.w    d6,d5                   ; d5 = i = bank*32+reg (0-255)
	bsr     .makeColor              ; d5 -> d2
	move.w  d2,(a2)+
	addq.w  #1,d6
	cmp.w   #32,d6
	bne.s   .colorHiLoop

	or.w    #$0200,d0               ; LOCT=1: write low nibble of R,G,B
	move.w  d0,BPLCON3(a1)
	lea     COLOR00(a1),a2
	moveq   #0,d6
.colorLoLoop:
	move.w  d7,d5
	lsl.w   #5,d5
	or.w    d6,d5
	bsr     .makeColor
	move.w  d2,(a2)+
	addq.w  #1,d6
	cmp.w   #32,d6
	bne.s   .colorLoLoop

	dbra    d7,.colorBankLoop

	; COLOR00 (the background/border colour) is forced to true black; it is
	; index 0, which .makeColor already returns black for, but writing it
	; explicitly keeps the intent obvious and BPLCON3 in a known state.
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT=0
	move.w  #$0000,COLOR00(a1)
	move.w  #$0200,BPLCON3(a1)      ; bank 0, LOCT=1
	move.w  #$0000,COLOR00(a1)
	move.w  #$0000,BPLCON3(a1)      ; leave BPLCON3 in a known state


	; Patch the bitplane pointers into every section's reload block. Every
	; section points plane 1 at rulerBuf and planes 2 to 8 at solidBuf, so
	; a section never inherits the fetch drift of the sections above it.
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

.makeColor:
	; Maps colour index d5 (0-255) to a 12-bit $RGB value whose *hue* is
	; determined solely by the position p of the index's highest set bit,
	; i.e. by how many bitplanes it takes to produce that index:
	;   0        black
	;   1        red        (1 plane)
	;   2-3      orange     (2 planes)
	;   4-7      yellow     (3 planes)
	;   8-15     green      (4 planes)
	;   16-31    cyan       (5 planes)
	;   32-63    blue       (6 planes)
	;   64-127   magenta    (7 planes)
	;   128-255  white      (8 planes)
	; Bit 0 of the index -- and only bit 0, i.e. bitplane 1 -- picks between
	; half and full brightness. Every other bit affects the hue alone, so the
	; 2-pixel plane 1 ruler shows up as a crisp bright/dim alternation right
	; across the picture without ever making the bitplane count ambiguous.
	; in: d5=index (0-255); out: d2=12-bit RGB
	; clobbers: d0, d1, d3, d4, a3
	moveq   #0,d2
	tst.w   d5
	beq     .mcDone                 ; index 0 -> black

	; d3 = p = position of the highest set bit (0-7)
	move.w  d5,d1
	moveq   #0,d3
.mcTopBit:
	lsr.w   #1,d1
	beq.s   .mcGotP
	addq.w  #1,d3
	bra.s   .mcTopBit
.mcGotP:

	; d4 = brightness: full if the index is odd, half if it is even
	moveq   #8,d4
	btst    #0,d5
	beq.s   .mcGotB
	moveq   #15,d4
.mcGotB:

	; Fetch the hue for family p: three nibbles holding a per-channel code
	; (0 = off, 1 = half brightness, 2 = full brightness).
	lea     .hueTable(pc),a3
	add.w   d3,d3
	move.w  0(a3,d3.w),d1

	move.w  d1,d3
	lsr.w   #8,d3
	and.w   #$0F,d3
	bsr.s   .mcChannel
	lsl.w   #8,d0
	or.w    d0,d2                   ; red   -> bits 11-8

	move.w  d1,d3
	lsr.w   #4,d3
	and.w   #$0F,d3
	bsr.s   .mcChannel
	lsl.w   #4,d0
	or.w    d0,d2                   ; green -> bits 7-4

	move.w  d1,d3
	and.w   #$0F,d3
	bsr.s   .mcChannel
	or.w    d0,d2                   ; blue  -> bits 3-0
.mcDone:
	rts

.mcChannel:
	; in: d3=code (0/1/2), d4=brightness; out: d0=channel value
	moveq   #0,d0
	tst.w   d3
	beq.s   .mcChannelDone
	move.w  d4,d0
	cmp.w   #2,d3
	beq.s   .mcChannelDone
	lsr.w   #1,d0                   ; half brightness
.mcChannelDone:
	rts

.hueTable:
	dc.w    $0200                  ; red     (1 plane)
	dc.w    $0210                  ; orange  (2 planes)
	dc.w    $0220                  ; yellow  (3 planes)
	dc.w    $0020                  ; green   (4 planes)
	dc.w    $0022                  ; cyan    (5 planes)
	dc.w    $0002                  ; blue    (6 planes)
	dc.w    $0202                  ; magenta (7 planes)
	dc.w    $0222                  ; white   (8 planes)

planeTable:
	dc.l    rulerBuf,solidBuf,solidBuf,solidBuf
	dc.l    solidBuf,solidBuf,solidBuf,solidBuf

sectionPtrTable:
	dc.l    sech0,sech1,sech2,sech3,sech4,sech5,sech6,sech7
	dc.l    secs0,secs1,secs2,secs3,secs4,secs5,secs6,secs7
	dc.l    0

copper:
	dc.w    FMODEREG,FMODE          ; the fetch mode under test
	dc.w    BPLCON0,$0200           ; bitplanes off for now
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024
	dc.w    BPLCON3,$0000
	dc.w    BPLCON4,$0011           ; AGA defaults (no bitplane colour XOR)
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    DDFSTRT,DDF_START
	dc.w    DDFSTOP,DDF_STOP
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000

	;
	; Section sech0: 1 bitplane, HIRES
	;
	dc.w    $3001,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
sech0:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $3101,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$9200           ; 1 bitplane, hires

	;
	; Section sech1: 2 bitplanes, HIRES
	;
	dc.w    $3C01,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
sech1:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $3D01,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$A200           ; 2 bitplanes, hires

	;
	; Section sech2: 3 bitplanes, HIRES
	;
	dc.w    $4801,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
sech2:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $4901,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$B200           ; 3 bitplanes, hires

	;
	; Section sech3: 4 bitplanes, HIRES
	;
	dc.w    $5401,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
sech3:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $5501,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$C200           ; 4 bitplanes, hires

	;
	; Section sech4: 5 bitplanes, HIRES
	;
	dc.w    $6001,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
sech4:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $6101,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$D200           ; 5 bitplanes, hires

	;
	; Section sech5: 6 bitplanes, HIRES
	;
	dc.w    $6C01,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
sech5:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $6D01,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$E200           ; 6 bitplanes, hires

	;
	; Section sech6: 7 bitplanes, HIRES
	;
	dc.w    $7801,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
sech6:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $7901,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$F200           ; 7 bitplanes, hires

	;
	; Section sech7: 8 bitplanes, HIRES
	;
	dc.w    $8401,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
sech7:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $8501,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$8210           ; 8 bitplanes, hires

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
	; Section secs0: 1 bitplane, SHRES
	;
	dc.w    $9401,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secs0:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $9501,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$1240           ; 1 bitplane, shres

	;
	; Section secs1: 2 bitplanes, SHRES
	;
	dc.w    $A001,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secs1:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $A101,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$2240           ; 2 bitplanes, shres

	;
	; Section secs2: 3 bitplanes, SHRES
	;
	dc.w    $AC01,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secs2:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $AD01,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$3240           ; 3 bitplanes, shres

	;
	; Section secs3: 4 bitplanes, SHRES
	;
	dc.w    $B801,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secs3:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $B901,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$4240           ; 4 bitplanes, shres

	;
	; Section secs4: 5 bitplanes, SHRES
	;
	dc.w    $C401,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secs4:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $C501,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$5240           ; 5 bitplanes, shres

	;
	; Section secs5: 6 bitplanes, SHRES
	;
	dc.w    $D001,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secs5:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $D101,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$6240           ; 6 bitplanes, shres

	;
	; Section secs6: 7 bitplanes, SHRES
	;
	dc.w    $DC01,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secs6:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $DD01,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$7240           ; 7 bitplanes, shres

	;
	; Section secs7: 8 bitplanes, SHRES
	;
	dc.w    $E801,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secs7:
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
	dc.w    BPL7PTH,$0000
	dc.w    BPL7PTL,$0000
	dc.w    BPL8PTH,$0000
	dc.w    BPL8PTL,$0000
	dc.w    $E901,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$0250           ; 8 bitplanes, shres

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
