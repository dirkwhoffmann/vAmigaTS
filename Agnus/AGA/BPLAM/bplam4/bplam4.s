	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

;
; bplam4.s -- where the picture starts, read against the display window.
;
; The same four bitplanes as bplam3, the same $5555 / $3333 / $0F0F / $00FF
; pixel-position data and the same 256 entry palette. Two changes:
;
;   BPLAM is a constant, not a sweep. Every index 0 pixel -- which is what
;   the picture is made of wherever a plane happens to be clear -- comes
;   out as colour[BPLAM] rather than as COLOR00, so the bitplane data has a
;   hard left edge against a background that is not part of it.
;
;   The DISPLAY WINDOW is what varies instead, three positions per section,
;   each of them run twice, once with the border blanked and once without.
;
;
; WHAT IT MEASURES
; ----------------
;
; The pixel shift around the border. The display window does not open where
; DIWSTRT says: it opens at the first BPL1DAT write, so DIWSTRT only bites
; once it has moved past that point (see Denise/Sprites/clip/diwclip). Each
; section therefore places the window three ways relative to the first
; bitplane pixel:
;
;   before    DIWSTRT one step LEFT of the first pixel. DIWSTRT is not the
;             constraint, and the left edge of the picture is the data.
;
;   exact     DIWSTRT ON the first pixel. Both constraints coincide, and
;             the edge must not move from the previous case.
;
;   overlap   DIWSTRT one step RIGHT of the first pixel. Now DIWSTRT is the
;             constraint, it eats into the data, and the edge must move by
;             exactly one step.
;
; Read down a section, the first two subsections have their left edge in the
; same column and the third has it one step further right. An edge that
; moves between the first and the second means the window is opening at
; DIWSTRT when it should be opening at the data; an edge that does not move
; into the third means DIWSTRT is not clipping when it should be.
;
;
; THE TWO BORDER SETTINGS
; -----------------------
;
; Subsections 1 to 3 run with BRDRBLNK clear, so the border takes COLOR00,
; which is dark grey. Subsections 4 to 6 repeat the same three positions
; with BRDRBLNK set, so the border is forced to pure black.
;
; The pair matters because the stretch between DIWSTRT and the first
; bitplane word is border, not window. With the border open it is dark grey
; like the rest of the border and there is no seam at DIWSTRT at all; with
; the border blanked it is black. Either way the edge that can be located is
; the same one -- the first bitplane pixel -- and it must land in the same
; column in both. A left edge that moves when BRDRBLNK is toggled would mean
; the border is being blanked over a different range than it is drawn.
;
;
; NOTES
; -----
;
; FMODE is 1 rather than bplam3's 0. Four bitplanes do not fit in a super
; hires fetch unit at FMODE 0, and the third section would draw nothing.
;
; COLOR00 is dark grey rather than black. Black is what BRDRBLNK paints, and
; a background that is already black would make the two halves of every
; section identical.
;
; Each section opens with a Copper ruler on a plane-less line with BRDRBLNK
; cleared, because a line with no bitplanes is border across its full width
; and a blanked border would swallow the stripes (see brdrblnk2).
;
; The picture covers lines $2A to $12B, which is as much of the vertical
; overscan as a real display can be expected to show. Two consequences:
;
;   The vertical position in a Copper WAIT is only eight bits wide, so the
;   list has to be re-synchronised once at line 256 (WAIT $FFDF).
;
;   The four bitplane pointers are rewound at the top of every subsection.
;   One super hires line fetches 256 bytes at FMODE 1, so planes left running
;   for the whole picture would read far past the end of their buffers.
;
BPLCON3             equ $106          ; AGA only
BPLCON4             equ $10C          ; AGA only
FMODEREG            equ $1FC          ; AGA only

FMODE               equ $0001         ; 4 planes have to fit in super hires

DDF_START           equ $0038
DDF_STOP            equ $00B0

; DIWSTRT is written per subsection; only the stop is global here.
DIW_VSTART          equ $2A00         ; vertical window start
DIW_STOP            equ $2CC1

LORES_BITS          equ $0201         ; lores, ECSENA
HIRES_BITS          equ $8201         ; hires, ECSENA
SHRES_BITS          equ $0241         ; super hires, ECSENA
BPLAM               equ $10           ; constant colour XOR
BPLCON4_VAL         equ (BPLAM<<8)|$11
BLACK               equ $000
BRDRBLNK            equ $0020         ; BPLCON3 bit 5
BACKGND             equ $444          ; not black: BRDRBLNK has to show
BPLCON0_OFF         equ $0201         ; no bitplanes, ECSENA

PLANE_SIZE          equ 8192


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

	move.w  #FMODE,FMODEREG(a1)

	; Fill the four buffers, one repeating word each.
	lea     bitBuf0,a0
	move.w  #$5555,d1
	bsr     .fillWord
	lea     bitBuf1,a0
	move.w  #$3333,d1
	bsr     .fillWord
	lea     bitBuf2,a0
	move.w  #$0F0F,d1
	bsr     .fillWord
	lea     bitBuf3,a0
	move.w  #$00FF,d1
	bsr     .fillWord

	lea     CUSTOM,a1
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

	; COLOR00 is dark blue rather than black. It is the colour of the
	; display window wherever the bitplanes have not delivered data yet,
	; and with BRDRBLNK set it is no longer shared with the border, so the
	; window edge becomes visible. Written twice, LOCT=0 then LOCT=1, so
	; both nibbles of every channel are filled.
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT=0
	move.w  #BACKGND,COLOR00(a1)
	move.w  #$0200,BPLCON3(a1)      ; bank 0, LOCT=1
	move.w  #BACKGND,COLOR00(a1)
	move.w  #$0000,BPLCON3(a1)      ; leave BPLCON3 in a known state


	; Patch the four bitplane pointers into every block of the copper
	; list. There is one block per subsection: the planes are rewound
	; every 14 lines so that a super hires section cannot read past the
	; end of its buffer.
	lea     ptrBlocks(pc),a4
.blkLoop:
	move.l  (a4)+,d4
	beq.s   .blkDone
	move.l  d4,a2
	lea     planeTable(pc),a5
	moveq   #3,d6
.ptLoop:
	move.l  (a5)+,d3
	move.w  d3,6(a2)                ; low  word -> BPLxPTL move
	swap    d3
	move.w  d3,2(a2)                ; high word -> BPLxPTH move
	addq.l  #8,a2
	dbra    d6,.ptLoop
	bra.s   .blkLoop
.blkDone:

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

.fillWord:
	; Fills the buffer at a0 with the word in d1. clobbers a0, d0
	move.w  #(PLANE_SIZE/2)-1,d0
.fwLoop:
	move.w  d1,(a0)+
	dbra    d0,.fwLoop
	rts

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
	dc.l    bitBuf0,bitBuf1,bitBuf2,bitBuf3

copper:
	dc.w    FMODEREG,FMODE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024
	dc.w    BPLCON3,$0000
	dc.w    BPLCON4,BPLCON4_VAL     ; BPLAM held constant
	dc.w    DIWSTOP,DIW_STOP
	dc.w    DDFSTRT,DDF_START
	dc.w    DDFSTOP,DDF_STOP
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000
	dc.w    COLOR00,BACKGND

	;
	; LORES section, lines $2A-$7F. First bitplane pixel at lores $7F.
	;
	dc.w    $2A01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000           ; border open: BPU = 0 is all border
	dc.w    COLOR00,BLACK
	dc.w    $2B31,$FFFE
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$0F0
	dc.w    $2BE1,$FFFE
	dc.w    COLOR00,BLACK
	dc.w    COLOR00,BACKGND

	dc.w    $2C01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$77 ; before, border open
	dc.w    BPLCON0,(4<<12)|LORES_BITS
bplPtrsLORES0:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $3A01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$7F ; exact , border open
	dc.w    BPLCON0,(4<<12)|LORES_BITS
bplPtrsLORES1:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $4801,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$87 ; overlap, border open
	dc.w    BPLCON0,(4<<12)|LORES_BITS
bplPtrsLORES2:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $5601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$77 ; before, border blanked
	dc.w    BPLCON0,(4<<12)|LORES_BITS
bplPtrsLORES3:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $6401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$7F ; exact , border blanked
	dc.w    BPLCON0,(4<<12)|LORES_BITS
bplPtrsLORES4:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $7201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$87 ; overlap, border blanked
	dc.w    BPLCON0,(4<<12)|LORES_BITS
bplPtrsLORES5:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000

	dc.w    $7FE1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	;
	; HIRES section, lines $80-$D5. First bitplane pixel at lores $7F.
	;
	dc.w    $8001,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000           ; border open: BPU = 0 is all border
	dc.w    COLOR00,BLACK
	dc.w    $8131,$FFFE
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$0F0
	dc.w    $81E1,$FFFE
	dc.w    COLOR00,BLACK
	dc.w    COLOR00,BACKGND

	dc.w    $8201,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$77 ; before, border open
	dc.w    BPLCON0,(4<<12)|HIRES_BITS
bplPtrsHIRES0:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $9001,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$7F ; exact , border open
	dc.w    BPLCON0,(4<<12)|HIRES_BITS
bplPtrsHIRES1:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $9E01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$87 ; overlap, border open
	dc.w    BPLCON0,(4<<12)|HIRES_BITS
bplPtrsHIRES2:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $AC01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$77 ; before, border blanked
	dc.w    BPLCON0,(4<<12)|HIRES_BITS
bplPtrsHIRES3:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $BA01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$7F ; exact , border blanked
	dc.w    BPLCON0,(4<<12)|HIRES_BITS
bplPtrsHIRES4:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $C801,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$87 ; overlap, border blanked
	dc.w    BPLCON0,(4<<12)|HIRES_BITS
bplPtrsHIRES5:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000

	dc.w    $D5E1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	;
	; SHRES section, lines $D6-$12B. First bitplane pixel at lores $73.
	;
	dc.w    $D601,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000           ; border open: BPU = 0 is all border
	dc.w    COLOR00,BLACK
	dc.w    $D731,$FFFE
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$0F0
	dc.w    $D7E1,$FFFE
	dc.w    COLOR00,BLACK
	dc.w    COLOR00,BACKGND

	dc.w    $D801,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$6B ; before, border open
	dc.w    BPLCON0,(4<<12)|SHRES_BITS
bplPtrsSHRES0:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $E601,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$73 ; exact , border open
	dc.w    BPLCON0,(4<<12)|SHRES_BITS
bplPtrsSHRES1:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $F401,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$7B ; overlap, border open
	dc.w    BPLCON0,(4<<12)|SHRES_BITS
bplPtrsSHRES2:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $FFDF,$FFFE             ; cross the 8 bit vertical boundary
	dc.w    $0001,$FFFE             ; re-sync at the start of line 256
	dc.w    $0201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$6B ; before, border blanked
	dc.w    BPLCON0,(4<<12)|SHRES_BITS
bplPtrsSHRES3:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $1001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$73 ; exact , border blanked
	dc.w    BPLCON0,(4<<12)|SHRES_BITS
bplPtrsSHRES4:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $1E01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$7B ; overlap, border blanked
	dc.w    BPLCON0,(4<<12)|SHRES_BITS
bplPtrsSHRES5:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000

	dc.w    $2BE1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	dc.w    $2C01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.l    $FFFFFFFE

; Every block of BPLxPT moves in the list above, terminated by zero.
ptrBlocks:
	dc.l    bplPtrsLORES0,bplPtrsLORES1,bplPtrsLORES2
	dc.l    bplPtrsLORES3,bplPtrsLORES4,bplPtrsLORES5
	dc.l    bplPtrsHIRES0,bplPtrsHIRES1,bplPtrsHIRES2
	dc.l    bplPtrsHIRES3,bplPtrsHIRES4,bplPtrsHIRES5
	dc.l    bplPtrsSHRES0,bplPtrsSHRES1,bplPtrsSHRES2
	dc.l    bplPtrsSHRES3,bplPtrsSHRES4,bplPtrsSHRES5
	dc.l    0

	cnop    0,8
bitBuf0: ds.b PLANE_SIZE
	cnop    0,8
bitBuf1: ds.b PLANE_SIZE
	cnop    0,8
bitBuf2: ds.b PLANE_SIZE
	cnop    0,8
bitBuf3: ds.b PLANE_SIZE
