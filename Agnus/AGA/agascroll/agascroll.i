; agascroll.i -- shared body for the Agnus/AGA agascroll tests.
;
; The including file must define, before "include"-ing this:
;   DDF_START  the value written to DDFSTRT (the parameter under test)
; and may optionally define:
;   DDF_STOP   the value written to DDFSTOP  (default $00B0)
;   FMODE      the value written to FMODE    (default $0003, 64-bit fetch)
; and must itself have already included registers.i, hardware/dmabits.i,
; hardware/intbits.i and ministartup.s (see agascroll0/agascroll0.s for the
; exact boilerplate) -- this file has no includes of its own so it stays
; agnostic of the including file's directory depth.
;
; The test is modelled on Denise/Registers/BPLCON1/simple<n>, which sets
; DDFSTRT to $38+n and runs BPLCON1 through $00, $11, $22, ... $FF. That
; sweep only covers the 4 bit ECS scroll field. AGA widens the field to 8
; bits per playfield, so there are 256 scroll values rather than 16, and
; with FMODE = $3 (64-bit fetch) the chip actually has the buffered data to
; act on all of them.
;
;
; BPLCON1 ON AGA
; --------------
;
; The 8 bit scroll value PF1H7-0 is not contiguous in the register. The
; original ECS field keeps bits 3-0 so that ECS code keeps working, and the
; four added bits are dropped into the gaps left by the ECS layout:
;
;     bit 15-14   PF2H7-6      bit 13-12   PF1H7-6
;     bit 11-10   PF2H5-4      bit  9-8    PF1H5-4
;     bit  7-4    PF2H3-0      bit  3-0    PF1H3-0
;
; The value is a delay in SHRES pixels, i.e. quarter lores pixels, so the
; full 0-255 range spans 64 lores pixels -- four times the ECS range of 16.
; A value of the form $0v with v < 16 therefore still means exactly what it
; means on ECS. The SCROLL macro below performs that scattering; it is the
; single place where this layout is encoded, so if hardware disagrees, only
; the macro has to change.
;
; Note that vAmiga (as of writing) models a different layout: it takes the
; coarse bits from bits 11-10 (PF1) and 15-14 (PF2) and ignores bits 13-12
; and 9-8 entirely, which makes its scroll range 64 lores pixels in 16 steps
; rather than 256. Under that model the four blocks of this test would not
; land where they land under the layout above. That disagreement is a large
; part of what this test is for -- the emulator and the A1200 cannot both be
; right.
;
;
; LAYOUT
; ------
;
; Four colour blocks of 24 lines in a LORES region, the copper timing ruler
; from the Agnus/DDF/ddf1 test, then the same four blocks again in HIRES.
; There are nowhere near 256 display lines to spare, so each block sweeps a
; 24 value window instead, one value per line:
;
;     block 1    0 - 23      (0 - 5.75 lores pixels)
;     block 2   64 - 87      (16 - 21.75)
;     block 3  128 - 151     (32 - 37.75)
;     block 4  232 - 255     (58 - 63.75)
;
; The windows are 64 apart, i.e. exactly 16 lores pixels apart, so the four
; blocks sample the four quarters of the AGA range while each block resolves
; the fine end of the field. Block 4 runs up against 255 and so is offset by
; 40 rather than 64 from block 3; it is the one that shows what happens at
; the top of the range.
;
; Every fourth line of a block has its background switched to red for the
; length of the line, which divides each block into six groups of four and
; makes it possible to say which of the 24 values a given line is showing.
;
; One bitplane is enough here, as in simple<n>: the register under test acts
; on the odd-plane playfield and a single plane makes the shift easiest to
; read. PF2H is nevertheless written with the same value as PF1H, so a
; machine that (contrary to the layout above) routes odd planes through the
; PF2 field still produces a coherent picture rather than a torn one.
;
;
; BITPLANE DATA AND MEMORY
; ------------------------
;
; The buffer is one long repetition of an 8 byte period holding a single 8
; pixel bar:
;
;     $FF00, $0000, $0000, $0000     8 pixels on, 56 off
;
; so the picture is a train of thin bars 64 lores pixels apart. 64 lores
; pixels is exactly the AGA scroll range, so sweeping the value from 0 to
; 255 slides the train by exactly one period: the picture at 256 would be
; the picture at 0 again. Reading the test means watching a bar's left edge
; walk right as the value climbs.
;
; BPL1MOD is zero and the bitplane pointer is reloaded on EVERY display
; line, not once per block. That is what makes the picture independent of
; how many words a line actually fetches.
;
; The tempting alternative is to let the pointer run and rely on the data
; being periodic, which works only if a line consumes a whole number of 8
; byte periods. It does not here. At FMODE = $3 the per-plane word count is
;
;     words = (DDF_STOP - DDF_START) / 8 + 4
;
; (the model fitted in fmode.i, whose FMODE = $3 case is confirmed by
; fmode11 painting exactly three 64 pixel stairs from a $40 wide window:
; $40/8 + 4 = 12 words = 192 pixels). For DDF_START = $38 and DDF_STOP =
; $B0 that is 19 words = 38 bytes, and 38 mod 8 = 6 -- so a free-running
; pointer would start each line 48 lores pixels further into the pattern
; and shear the picture into a diagonal. No choice of DDF_STOP fixes this
; for all eight variants at once, because DDF_START is the thing being
; swept.
;
; Reloading per line sidesteps the arithmetic entirely rather than trying
; to satisfy it, which is the lesson the FMODE tests learned twice. It is
; affordable here only because there is a single bitplane: two copper MOVEs
; per line, about 1.5KB of copper list in total, and PLANE_SIZE shrinks to
; a single line's worth of data.

BPLCON3             equ $106          ; AGA only
BPLCON4             equ $10C          ; AGA only
FMODEREG            equ $1FC          ; AGA only (the register; FMODE is the value)

	IFND FMODE
FMODE               equ $0003         ; 64-bit fetch: all 256 scroll values usable
	ENDC
	IFND DDF_STOP
DDF_STOP            equ $00B0
	ENDC

; The display window is deliberately NOT derived from DDF_START. DDFSTRT is
; the parameter under test, and the point of the sweep is to see where the
; data lands inside a window that stays put. These are simple<n>'s values,
; except that DIWSTOP is $C1 rather than $D1: hstop carries an implicit bit
; 8, so $D1 means hpos 465, past the 454 pixel end of a PAL line, and the
; window would never close at all.
DIW_START           equ $2C71
DIW_STOP            equ $2CC1

BPLCON0_LORES       equ $1200         ; 1 bitplane, lores
BPLCON0_HIRES       equ $9200         ; 1 bitplane, hires
BPLCON0_OFF         equ $0200

PLANE_SIZE          equ 1024          ; one line's worth of fetching, plus slack

MARKER              equ $0F00         ; background of every fourth line


; SCROLL -- write scroll value \1 (0-255) into BPLCON1, scattered across the
; PF1H and PF2H fields as documented above. Both playfields get the same
; value.
SCROLL	MACRO
	dc.w	BPLCON1,((\1)&$0F)|(((\1)&$0F)<<4)|(((\1)&$30)<<4)|(((\1)&$30)<<6)|(((\1)&$C0)<<6)|(((\1)&$C0)<<8)
	ENDM

; BLOCK -- 24 consecutive lines starting at VP \1, running the scroll value
; from \2 to \2+23, one value per line. Each line waits at hpos $01, reloads
; the bitplane pointer and sets the new scroll value; $01 is far enough
; ahead of any DDFSTRT this test uses that all of it is in place before the
; line fetches anything. Every fourth line additionally gets a red
; background.
;
; The two pointer words are emitted as zero and filled in at run time, see
; the patch loop in MAIN.
;
; Bit 0 of a copper WAIT's first word is what makes it a WAIT; with the bit
; clear Agnus executes the word as a MOVE of $FFFE into whatever register it
; aliases. Both positions used here, $01 and $D9, are odd.
BLOCK	MACRO
SCROLLIDX	set	0
	REPT	24
	dc.w	(((\1)+SCROLLIDX)<<8)|$01,$FFFE
	IFEQ	SCROLLIDX&3
	dc.w	COLOR00,MARKER
	ENDC
	dc.w	BPL1PTH,$0000
	dc.w	BPL1PTL,$0000
	SCROLL	(\2)+SCROLLIDX
	IFEQ	SCROLLIDX&3
	dc.w	(((\1)+SCROLLIDX)<<8)|$D9,$FFFE
	dc.w	COLOR00,$0000
	ENDC
SCROLLIDX	set	SCROLLIDX+1
	ENDR
	ENDM


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

	; Put the chip into 64-bit fetch mode straight away, so the state is
	; already correct before the very first copper pass. Without this the
	; upper scroll bits have no buffered data to delay and the sweep
	; degenerates to its ECS range.
	move.w  #FMODE,FMODEREG(a1)

	; Fill the buffer with the 8 byte bar period. Nothing marks where a
	; line ends -- the pointer runs straight on into the next line
	; (BPL1MOD is zero), so the data has to be continuous rather than one
	; line long.
	lea     bitplane1,a0
	move.w  #(PLANE_SIZE/8)-1,d0
.fill:
	move.w  #$FF00,(a0)+
	move.w  #$0000,(a0)+
	move.w  #$0000,(a0)+
	move.w  #$0000,(a0)+
	dbra    d0,.fill

	; Colours. Only COLOR00 and COLOR01 are ever used; the copper repaints
	; both during the frame. On AGA a write with LOCT clear stores the
	; nibble in both halves of each component, so a single write per
	; register gives the full 8 bit value and no LOCT pass is needed.
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT = 0
	move.w  #$0000,COLOR00(a1)
	move.w  #$066F,COLOR01(a1)

	; Patch the bitplane pointer into every BPL1PTH/BPL1PTL move in the
	; copper list. There is one such pair on every display line, so rather
	; than keeping a table of ~200 sites in step with the macro that emits
	; them, walk the list and fill in whatever is found. A word with bit 0
	; set is a WAIT, whose second word must be stepped over rather than
	; inspected.
	lea     copper(pc),a2
	move.l  #bitplane1,d3
	move.l  d3,d4
	swap    d4                      ; d4 = high word of the address
.ptLoop:
	cmpi.l  #$FFFFFFFE,(a2)
	beq.s   .ptDone
	move.w  (a2)+,d1
	btst    #0,d1
	bne.s   .ptSkip                 ; WAIT: step over its second word
	cmpi.w  #BPL1PTH,d1
	beq.s   .ptHi
	cmpi.w  #BPL1PTL,d1
	beq.s   .ptLo
.ptSkip:
	addq.l  #2,a2
	bra.s   .ptLoop
.ptHi:
	move.w  d4,(a2)+
	bra.s   .ptLoop
.ptLo:
	move.w  d3,(a2)+
	bra.s   .ptLoop
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


copper:
	dc.w    FMODEREG,FMODE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024
	dc.w    BPLCON3,$0000
	dc.w    BPLCON4,$0011           ; AGA defaults (no bitplane colour XOR)
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP

	; DDFSTRT is the parameter under test. It and DDFSTOP are written here
	; once and never again, so every difference between the agascroll<n>
	; variants is attributable to DDFSTRT alone.
	dc.w    DDFSTRT,DDF_START
	dc.w    DDFSTOP,DDF_STOP

	; Zero: the bitplane pointer runs freely, see the header comment.
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000

	;
	; LORES block 1: scroll values 0 - 23
	;
	dc.w    $3001,$FFFE
	dc.w    BPLCON0,BPLCON0_LORES
	dc.w    COLOR01,$066F
	BLOCK	$30,0

	;
	; LORES block 2: scroll values 64 - 87
	;
	dc.w    $4801,$FFFE
	dc.w    COLOR01,$0B6F
	BLOCK	$48,64

	;
	; LORES block 3: scroll values 128 - 151
	;
	dc.w    $6001,$FFFE
	dc.w    COLOR01,$0F6F
	BLOCK	$60,128

	;
	; LORES block 4: scroll values 232 - 255
	;
	dc.w    $7801,$FFFE
	dc.w    COLOR01,$0F6B
	BLOCK	$78,232

	;
	; Copper timing ruler (from ddf1), between the LORES and HIRES regions.
	; Each MOVE below takes 4 color clocks, i.e. 8 lores pixels, so the
	; stripes measure copper timing straight across the display. Bitplane
	; DMA is switched off first: left running it would steal slots from the
	; copper and the stripe train would no longer be evenly spaced.
	;
	dc.w    $9001,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,$0000
	dc.w    $9800+DDF_START+1,$FFFE ; ruler starts where the data does
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
	; HIRES block 1: scroll values 0 - 23
	;
	dc.w    $A001,$FFFE
	dc.w    BPLCON0,BPLCON0_HIRES
	dc.w    COLOR01,$066F
	BLOCK	$A0,0

	;
	; HIRES block 2: scroll values 64 - 87
	;
	dc.w    $B801,$FFFE
	dc.w    COLOR01,$0B6F
	BLOCK	$B8,64

	;
	; HIRES block 3: scroll values 128 - 151
	;
	dc.w    $D001,$FFFE
	dc.w    COLOR01,$0F6F
	BLOCK	$D0,128

	;
	; HIRES block 4: scroll values 232 - 255
	;
	dc.w    $E801,$FFFE
	dc.w    COLOR01,$0F6B
	BLOCK	$E8,232

	;
	; Done -- shut the display down again. The last block ends on line $FF,
	; so the wait below has to sit inside that same line.
	;
	dc.w    $FFDF,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,$0000

	dc.l    $fffffffe

	cnop    0,8                     ; FMODE $3 needs a 64-bit aligned pointer
bitplane1: ds.b PLANE_SIZE
