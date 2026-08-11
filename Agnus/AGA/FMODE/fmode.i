; fmode.i -- shared body for the Agnus/AGA FMODE tests.
;
; The including file must define, before "include"-ing this:
;   FMODE      the value written to the FMODE register ($1FC) under test
;   DDF_START  the value written to DDFSTRT
;   DDF_STOP_LORES  DDFSTOP for the lores region
;   DDF_STOP_HIRES  DDFSTOP for the hires region
; and must itself have already included registers.i, hardware/dmabits.i,
;   hardware/intbits.i and ministartup.s (see fmode00/fmode00.s for the
; exact boilerplate) -- this file has no includes of its own so it stays
; agnostic of the including file's directory depth.
;
; The test is modelled on Agnus/DDF/ddf1, but where ddf1 sweeps DDFSTOP
; and keeps the bitplane count fixed, this one does the opposite: DDFSTRT
; and DDFSTOP are written once per region, never inside one, and
; never touched again -- so every difference between sections (and between
; the fmodeNN variants) is attributable to FMODE and the bitplane count
; alone.
;
; Layout: 8 sections in a LORES region followed by 8 sections in a HIRES
; region, enabling 1, 2, ... 8 bitplanes respectively (the 8-plane case
; uses BPLCON0 BPU3, bit 4, which only exists on AGA).

BPLCON3             equ $106          ; AGA only
BPLCON4             equ $10C          ; AGA only
BPL7PTH             equ $F8           ; AGA only
BPL7PTL             equ $FA           ; AGA only
BPL8PTH             equ $FC           ; AGA only
BPL8PTL             equ $FE           ; AGA only
FMODEREG            equ $1FC          ; AGA only (the register; FMODE is the value)

PLANE_SIZE          equ 2048          ; bytes reserved per bitplane, see below

; Per-plane 64-bit alignment control, one flag per bitplane. Each defaults
; to 0 (aligned -- the standard case, and the only one a real program would
; ever use): the buffer is forced onto a 64-bit (mod 8) address with cnop.
; Setting PLANEk_MISALIGN to 1 instead pushes bitplane k MISALIGN_OFFSET
; bytes off that boundary, so its pointer is still word-aligned -- legal as
; far as the 68000 and BPLxPT are concerned -- but not 64-bit aligned.
;
; MISALIGN_OFFSET defaults to 4 (mod 8 = 4, the maximum possible offset,
; used by fmode11a-e) but can be set to 2 (mod 8 = 2, the smallest offset
; a word-aligned pointer can have) to test whether the *distance* from the
; 64-bit boundary matters, or only whether the pointer sits on one at all
; (see fmode11f-j).
;
; PLANE_SIZE is a multiple of 8, and each plane is independently re-aligned
; with its own cnop rather than inheriting the previous plane's offset, so
; any combination of aligned/misaligned planes is expressible, including
; alternating patterns that a single shared alignment value could not
; produce (see fmode11d/fmode11e).
	IFND MISALIGN_OFFSET
MISALIGN_OFFSET     equ 4
	ENDC
	IFND PLANE1_MISALIGN
PLANE1_MISALIGN     equ 0
	ENDC
	IFND PLANE2_MISALIGN
PLANE2_MISALIGN     equ 0
	ENDC
	IFND PLANE3_MISALIGN
PLANE3_MISALIGN     equ 0
	ENDC
	IFND PLANE4_MISALIGN
PLANE4_MISALIGN     equ 0
	ENDC
	IFND PLANE5_MISALIGN
PLANE5_MISALIGN     equ 0
	ENDC
	IFND PLANE6_MISALIGN
PLANE6_MISALIGN     equ 0
	ENDC
	IFND PLANE7_MISALIGN
PLANE7_MISALIGN     equ 0
	ENDC
	IFND PLANE8_MISALIGN
PLANE8_MISALIGN     equ 0
	ENDC
NUM_PLANES          equ 8
NUM_SECTIONS        equ 8            ; per region

; The display window tracks DDF_START: bitplane data begins at hpos
; DDF_START*2+17, and the window opens 8 pixels ahead of it. DIWSTOP hstop
; carries an implicit bit 8, so $C1 means hpos $1C1 = 449 -- past the widest
; picture the windows below can produce, and comfortably inside a PAL line.
; (ddf1 uses $D1 here, i.e. hpos 465, which is past the end of the line and
; therefore never closes the window at all.)
DIW_START           equ $2C00+(DDF_START*2)+9
DIW_STOP            equ $2CC1

; BPL1MOD and BPL2MOD are both zero, and that is deliberate.
;
; Each plane holds one long, unbroken repetition of the 8-byte staircase,
; and the bitplane pointers are simply left to run from one line into the
; next; they are reloaded only when a new section starts. So a line begins
; wherever the previous line stopped, and because the data is periodic that
; is indistinguishable from starting at the beginning -- PROVIDED a line
; fetches a whole number of 8-byte periods. Then every line lands on a
; period boundary and the picture stands still, without the code having to
; know how many words the line actually fetched.
;
; That last part is the point. The earlier arrangement set the modulo to
; minus the fetched byte count, which meant the fetch count had to be known
; exactly, and it could not be computed reliably -- three successive
; formulas each matched some variants and not others, and a modulo that
; overshot walked the pointer backwards out of its buffer. Fetching a whole
; number of periods is a much weaker condition: it only needs the count to
; be right modulo 4 words, and getting it wrong shears the picture instead
; of destroying it.
;
; The DDF windows are therefore chosen to make each line fetch a whole
; number of stairs -- three in lores, six in hires. What a window is worth,
; as measured across the variants:
;
;     lores words = (DDF_STOP_LORES-DDF_START)/8 + Wl
;     hires words = (DDF_STOP_HIRES-DDF_START)/4 + Wh
;
; where the final fetch block holds Wl = 1, 2, 2, 4 words in lores and
; Wh = 2, 2, 2, 4 in hires, for FMODE $0, $1, $2, $3. FMODE adds a fixed
; number of words once; it does not scale the window. Treat this as a
; description that has already been revised more than once, not as a rule.
;
; To retune a variant: if a region shears, its line is not fetching a whole
; number of stairs. Nudge that region DDFSTOP by 8 (lores) or 4 (hires) and
; try again -- there are only four phases, so one is clean. The stair count
; you land on is then a direct measurement of what the window fetched.

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

	; Setup bitplane data: one long, unbroken repetition of an 8-byte
	; staircase, filling the whole buffer. Nothing marks where a line ends --
	; the pointers run straight on into the next line (BPLxMOD is zero), so
	; the data has to be continuous rather than one line long.
	;
	; Within each 64 lores pixel period, plane k (k>=2) switches on at byte
	; k-1 and stays on to the end of the period, so scanning left to right
	; brings in one more plane every 8 pixels and the colour index climbs
	; 1, 3, 7, 15, 31, 63, 127, 255. With the palette below (whose hue is
	; keyed on the highest set bit) that paints a staircase of eight hues,
	; and in a section with N planes enabled the staircase simply stops at
	; step N and holds that hue to the right edge. So both the number of
	; steps and the final hue read off the enabled bitplane count directly.
	;
	; A staircase is used rather than a plain binary ramp because the ramp
	; needs 512 pixels to reach the 8-plane hue, and the DDF window above is
	; only 80 pixels wide in the narrowest variant. The staircase gets there
	; in 64.
	;
	; Plane 1 is exempt: it toggles every 2 pixels across the whole width and
	; only ever flips the colour index between 2^k-1 and 2^k-2, which share a
	; hue but not a brightness. That makes it a fine horizontal ruler -- the
	; thing that makes a fetch misalignment obvious -- without ever disturbing
	; the hue staircase.
	lea     bitplane1,a0
	move.w  #(PLANE_SIZE/2)-1,d0
.l1: move.w  #$CCCC,(a0)+           ; toggles every 2 pixels
	dbra    d0,.l1

	lea     bitplane2,a0
	lea     .stair2(pc),a3
	move.w  #(PLANE_SIZE/8)-1,d0
	bsr     .fillPattern

	lea     bitplane3,a0
	lea     .stair3(pc),a3
	move.w  #(PLANE_SIZE/8)-1,d0
	bsr     .fillPattern

	lea     bitplane4,a0
	lea     .stair4(pc),a3
	move.w  #(PLANE_SIZE/8)-1,d0
	bsr     .fillPattern

	lea     bitplane5,a0
	lea     .stair5(pc),a3
	move.w  #(PLANE_SIZE/8)-1,d0
	bsr     .fillPattern

	lea     bitplane6,a0
	lea     .stair6(pc),a3
	move.w  #(PLANE_SIZE/8)-1,d0
	bsr     .fillPattern

	lea     bitplane7,a0
	lea     .stair7(pc),a3
	move.w  #(PLANE_SIZE/8)-1,d0
	bsr     .fillPattern

	lea     bitplane8,a0
	lea     .stair8(pc),a3
	move.w  #(PLANE_SIZE/8)-1,d0
	bsr     .fillPattern

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

	; Patch the bitplane pointers into every section's reload block. Each
	; section re-points all 8 planes on its own blank line, so a section
	; never inherits the fetch drift of the sections above it -- with a
	; wide FMODE that drift would otherwise accumulate over the whole frame
	; (and need far more chip RAM than a 512KB machine has to spare).
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

.fillPattern:
	; Replicates the 4-word (8-byte) pattern at a3 across the buffer at a0.
	; in: a0=dest ptr, a3=pattern, d0=period count-1 (dbra count)
	; clobbers: a4
.fpLoop:
	move.l  a3,a4
	move.w  (a4)+,(a0)+
	move.w  (a4)+,(a0)+
	move.w  (a4)+,(a0)+
	move.w  (a4)+,(a0)+
	dbra    d0,.fpLoop
	rts

	; Staircase patterns: plane k is off for the first k-1 bytes of each
	; 8-byte period and on for the rest.
.stair2: dc.w    $00FF,$FFFF,$FFFF,$FFFF   ; on from pixel 8
.stair3: dc.w    $0000,$FFFF,$FFFF,$FFFF   ; on from pixel 16
.stair4: dc.w    $0000,$00FF,$FFFF,$FFFF   ; on from pixel 24
.stair5: dc.w    $0000,$0000,$FFFF,$FFFF   ; on from pixel 32
.stair6: dc.w    $0000,$0000,$00FF,$FFFF   ; on from pixel 40
.stair7: dc.w    $0000,$0000,$0000,$FFFF   ; on from pixel 48
.stair8: dc.w    $0000,$0000,$0000,$00FF   ; on from pixel 56

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
	dc.l    bitplane1,bitplane2,bitplane3,bitplane4
	dc.l    bitplane5,bitplane6,bitplane7,bitplane8

sectionPtrTable:
	dc.l    secl0,secl1,secl2,secl3,secl4,secl5,secl6,secl7
	dc.l    sech0,sech1,sech2,sech3,sech4,sech5,sech6,sech7
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

	; DDF is written here once and never again -- see the header comment.
	dc.w    DDFSTRT,DDF_START
	dc.w    DDFSTOP,DDF_STOP_LORES

	; Zero: the bitplane pointers run freely, see the header comment.
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000

	;
	; Section secl0: 1 bitplane
	;
	dc.w    $3001,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secl0:
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
	dc.w    BPLCON0,$1200           ; 1 bitplanes, lores

	;
	; Section secl1: 2 bitplanes
	;
	dc.w    $3C01,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secl1:
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
	dc.w    BPLCON0,$2200           ; 2 bitplanes, lores

	;
	; Section secl2: 3 bitplanes
	;
	dc.w    $4801,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secl2:
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
	dc.w    BPLCON0,$3200           ; 3 bitplanes, lores

	;
	; Section secl3: 4 bitplanes
	;
	dc.w    $5401,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secl3:
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
	dc.w    BPLCON0,$4200           ; 4 bitplanes, lores

	;
	; Section secl4: 5 bitplanes
	;
	dc.w    $6001,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secl4:
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
	dc.w    BPLCON0,$5200           ; 5 bitplanes, lores

	;
	; Section secl5: 6 bitplanes
	;
	dc.w    $6C01,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secl5:
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
	dc.w    BPLCON0,$6200           ; 6 bitplanes, lores

	;
	; Section secl6: 7 bitplanes
	;
	dc.w    $7801,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secl6:
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
	dc.w    BPLCON0,$7200           ; 7 bitplanes, lores

	;
	; Section secl7: 8 bitplanes
	;
	dc.w    $8401,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
secl7:
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
	dc.w    BPLCON0,$0210           ; 8 bitplanes, lores

	;
	; Copper timing ruler (from ddf1), between the LORES and HIRES regions.
	; Each MOVE below takes 4 color clocks, i.e. 8 lores pixels, so the
	; stripes measure copper timing straight across the display. Bitplane
	; DMA is switched off first: left running it would steal slots from the
	; copper and the stripe train would no longer be evenly spaced.
	;
	dc.w    $9001,$FFFE            ; stop fetching before DDF_START
	dc.w    BPLCON0,$0200
	dc.w    $9000+DDF_START+1,$FFFE ; ruler starts where the data does
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
	; Section sech0: 1 bitplane
	;
	dc.w    $9401,$FFFE            ; blank line: stop fetching, re-point
	dc.w    BPLCON0,$0200
	dc.w    DDFSTOP,DDF_STOP_HIRES
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
	dc.w    $9501,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$9200           ; 1 bitplanes, hires

	;
	; Section sech1: 2 bitplanes
	;
	dc.w    $A001,$FFFE            ; blank line: stop fetching, re-point
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
	dc.w    $A101,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$A200           ; 2 bitplanes, hires

	;
	; Section sech2: 3 bitplanes
	;
	dc.w    $AC01,$FFFE            ; blank line: stop fetching, re-point
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
	dc.w    $AD01,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$B200           ; 3 bitplanes, hires

	;
	; Section sech3: 4 bitplanes
	;
	dc.w    $B801,$FFFE            ; blank line: stop fetching, re-point
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
	dc.w    $B901,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$C200           ; 4 bitplanes, hires

	;
	; Section sech4: 5 bitplanes
	;
	dc.w    $C401,$FFFE            ; blank line: stop fetching, re-point
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
	dc.w    $C501,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$D200           ; 5 bitplanes, hires

	;
	; Section sech5: 6 bitplanes
	;
	dc.w    $D001,$FFFE            ; blank line: stop fetching, re-point
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
	dc.w    $D101,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$E200           ; 6 bitplanes, hires

	;
	; Section sech6: 7 bitplanes
	;
	dc.w    $DC01,$FFFE            ; blank line: stop fetching, re-point
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
	dc.w    $DD01,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$F200           ; 7 bitplanes, hires

	;
	; Section sech7: 8 bitplanes
	;
	dc.w    $E801,$FFFE            ; blank line: stop fetching, re-point
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
	dc.w    $E901,$FFFE            ; first display line of the section
	dc.w    BPLCON0,$8210           ; 8 bitplanes, hires

	;
	; Done -- shut the display down again.
	;
	dc.w    $F401,$FFFE
	dc.w    BPLCON0,$0200

	dc.l    $fffffffe

	cnop    0,8                     ; always land on a 64-bit boundary first
	IFNE PLANE1_MISALIGN
	ds.b    MISALIGN_OFFSET         ; then step off it, on purpose
	ENDC
bitplane1: ds.b PLANE_SIZE
	cnop    0,8                     ; always land on a 64-bit boundary first
	IFNE PLANE2_MISALIGN
	ds.b    MISALIGN_OFFSET         ; then step off it, on purpose
	ENDC
bitplane2: ds.b PLANE_SIZE
	cnop    0,8                     ; always land on a 64-bit boundary first
	IFNE PLANE3_MISALIGN
	ds.b    MISALIGN_OFFSET         ; then step off it, on purpose
	ENDC
bitplane3: ds.b PLANE_SIZE
	cnop    0,8                     ; always land on a 64-bit boundary first
	IFNE PLANE4_MISALIGN
	ds.b    MISALIGN_OFFSET         ; then step off it, on purpose
	ENDC
bitplane4: ds.b PLANE_SIZE
	cnop    0,8                     ; always land on a 64-bit boundary first
	IFNE PLANE5_MISALIGN
	ds.b    MISALIGN_OFFSET         ; then step off it, on purpose
	ENDC
bitplane5: ds.b PLANE_SIZE
	cnop    0,8                     ; always land on a 64-bit boundary first
	IFNE PLANE6_MISALIGN
	ds.b    MISALIGN_OFFSET         ; then step off it, on purpose
	ENDC
bitplane6: ds.b PLANE_SIZE
	cnop    0,8                     ; always land on a 64-bit boundary first
	IFNE PLANE7_MISALIGN
	ds.b    MISALIGN_OFFSET         ; then step off it, on purpose
	ENDC
bitplane7: ds.b PLANE_SIZE
	cnop    0,8                     ; always land on a 64-bit boundary first
	IFNE PLANE8_MISALIGN
	ds.b    MISALIGN_OFFSET         ; then step off it, on purpose
	ENDC
bitplane8: ds.b PLANE_SIZE
