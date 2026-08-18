; rdram2 -- reading a colour register back in the same scanline it was written.
;
; rdram established that RDRAM makes the colour registers readable. This asks
; the follow-up question that rdram deliberately avoided: WHEN does a write
; become visible to a read?
;
; rdram seeds the registers in one loop and reads them in another, more than a
; scanline apart, so it never distinguishes "the register file is updated as
; the write is issued" from "the register file is updated once per line". On
; hardware there is nothing to distinguish -- a write lands in the register and
; the next read sees it. In vAmiga colour writes are queued in colChanges and
; replayed once per line (PixelEngine::colorize, replayColRegChanges), so a
; read sees the file as it stood at the end of the PREVIOUS line.
;
; THE THREE PROBES
; ----------------
;
; Every probe uses one register, COLOR01, seeded blue and then written green.
; The value that comes back is what a band is painted with, so each band reads
; directly:
;
;     green   the read returned the NEW value
;     blue    the read returned the OLD value
;
; Section 1  WRITE then READ, same line. The write is at horizontal position
;            hp, the read twelve VHPOSR units later. Hardware returns the new
;            value, so the section is green.
;
; Section 2  READ then WRITE, same line. The read comes first and the write
;            twelve units after it. The read must NOT see a write that has not
;            happened yet, so the section is blue -- on every machine.
;
; Section 3  WRITE, then READ two lines later. The control: it says the
;            readback works at all. Green everywhere, including on a vAmiga
;            that fails sections 1 and 2.
;
; Each section runs the probe at eight horizontal positions, 20 to 76 in
; VHPOSR units, and paints one band per position. A result that depends on
; where in the line the probe sat would show up as a section that is not one
; solid colour.
;
; WHAT EACH SECTION IS FOR
; ------------------------
;
; Section 1 is the bug. Section 3 is the control that stops section 1 being
; read as "the readback is broken". Section 2 is the guard on the FIX: the
; obvious repair is to search the recorded colour changes, and the obvious way
; to get that wrong is to return the newest recorded value rather than the
; newest one recorded AT OR BEFORE the read. A fix that does the wrong thing
; turns section 2 green and is caught here rather than in a demo years later.
;
;     machine / state                 sec 1   sec 2   sec 3
;     A1200                           green   blue    green
;     vAmiga, readback not searched    blue   blue    green
;     vAmiga, search ignoring order   green   green   green
;     vAmiga, correct                 green   blue    green
;
; The probes run with DMA off and bitplanes disabled, so nothing competes for
; cycles and the horizontal positions are the ones asked for. The results are
; latched into memory and only then patched into the Copper list, so the
; picture itself imposes no timing constraints.

	include "../../../../include/registers.i"
	include "../../../../include/ministartup.i"

BPLCON3             equ $106
BPLCON4             equ $10C
FMODEREG            equ $1FC

BPLCON0_OFF         equ $0201              ; ECSENA, no bitplanes
BPLCON0_PAL         equ $4201              ; four bitplanes, lores

BPLCON2_BASE        equ $0024              ; PF1P = PF2P = 4, RDRAM clear
BPLCON2_RD          equ $0124              ; the same with RDRAM set

DIW_START           equ $2C81
DIW_STOP            equ $2CC1

OLD_COL             equ $00F               ; the seed:    blue
NEW_COL             equ $0F0               ; the write:   green
BORDER_COL          equ $222

NPLANES             equ 4
LINEBYTES           equ 32                 ; 8 bands of 4 bytes
NPROBES             equ 8
HP_FIRST            equ 20                 ; VHPOSR units of the first probe
HP_STEP             equ 8
HP_GAP              equ 12                 ; between the two actions of a probe

MAIN:
	lea     CUSTOM,a1
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #BPLCON0_OFF,BPLCON0(a1)
	move.w  #$0000,BPLCON3(a1)      ; colour bank 0, LOCT clear
	move.w  #$0011,BPLCON4(a1)
	move.w  #$0000,FMODEREG(a1)
	move.w  #BPLCON2_BASE,BPLCON2(a1)
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01

	bsr     .buildPlanes
	bsr     .runProbes
	bsr     .patchCopper

	lea     CUSTOM,a1
	lea     copper(pc),a0
	move.l  a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	move.w  #$8080,DMACON(a1)       ; Copper DMA
	move.w  #$8100,DMACON(a1)       ; Bitplane DMA
	move.w  #$8200,DMACON(a1)       ; DMAEN
.mainLoop:
	bra.b   .mainLoop

; Four bitplanes holding eight vertical bands, four bytes each, carrying
; colour indices 1 to 8. The modulos are -LINEBYTES so every line refetches
; the same bytes and the bands are clean vertical columns.
.buildPlanes:
	lea     planes(pc),a3
	moveq   #0,d2                   ; plane
.bpPlane:
	moveq   #0,d3                   ; byte
.bpByte:
	move.w  d3,d4
	lsr.w   #2,d4                   ; band 0 to 7
	addq.w  #1,d4                   ; index 1 to 8
	moveq   #0,d5
	btst    d2,d4
	beq.s   .bpZero
	moveq   #-1,d5
.bpZero:
	move.b  d5,(a3)+
	addq.w  #1,d3
	cmp.w   #LINEBYTES,d3
	bne.s   .bpByte
	addq.w  #1,d2
	cmp.w   #NPLANES,d2
	bne.s   .bpPlane
	rts

; ---------------------------------------------------------------------------
; Raster helpers. VHPOSR's low byte is the horizontal position in units of two
; colour clocks, so a line runs 0 to about 113.
; ---------------------------------------------------------------------------

; Wait until a fresh scanline has started. Clobbers d3 and d4.
;
; This watches the LINE NUMBER rather than the horizontal position. Waiting for
; a small horizontal position instead -- "spin until hpos <= 10" -- looks
; equivalent and is not: that window is eleven colour clocks wide, one poll of
; VHPOSR costs more than that, and the loop steps straight over the window and
; spins for ever. Whether it happens to land inside depends on the alignment of
; the caller, which is exactly the kind of bug that hides until the code is
; moved. A change of line number holds for a whole line and cannot be missed.
.syncLine:
	move.w  VHPOSR(a1),d3
	and.w   #$FF00,d3               ; the line we are on now
.slLoop:
	move.w  VHPOSR(a1),d4
	and.w   #$FF00,d4
	cmp.w   d3,d4
	beq.s   .slLoop
	rts

; Wait until the horizontal position reaches d0. Must be entered with the
; current position below d0 so that the wait stays inside one line.
; Clobbers d3.
.waitHp:
.whLoop:
	move.w  VHPOSR(a1),d3
	and.w   #$00FF,d3
	cmp.w   d0,d3
	blo.s   .whLoop
	rts

; Seed COLOR01 with the old value and let it settle for three lines, so that
; whatever a read returns afterwards cannot be blamed on the seed.
.seedAndSync:
	move.w  #OLD_COL,COLOR01(a1)
	bsr     .syncLine
	bsr     .syncLine
	bsr     .syncLine
	rts

; Section 1: write at d0, read at d1, same line. Returns the readback in d2.
.probeWriteRead:
	bsr     .seedAndSync
	bsr     .waitHp
	move.w  #NEW_COL,COLOR01(a1)    ; RDRAM is clear, so this lands
	move.w  d1,d0
	bsr     .waitHp
	move.w  #BPLCON2_RD,BPLCON2(a1)
	move.w  COLOR01(a1),d2
	move.w  #BPLCON2_BASE,BPLCON2(a1)
	and.w   #$0FFF,d2
	rts

; Section 2: read at d0, write at d1, same line. Returns the readback in d2.
.probeReadWrite:
	bsr     .seedAndSync
	bsr     .waitHp
	move.w  #BPLCON2_RD,BPLCON2(a1)
	move.w  COLOR01(a1),d2
	move.w  #BPLCON2_BASE,BPLCON2(a1)
	move.w  d1,d0
	bsr     .waitHp
	move.w  #NEW_COL,COLOR01(a1)    ; after the read, and must not affect it
	and.w   #$0FFF,d2
	rts

; Section 3: write at d0, read at d0 two lines later. Returns d2.
.probeCrossLine:
	bsr     .seedAndSync
	bsr     .waitHp
	move.w  #NEW_COL,COLOR01(a1)
	bsr     .syncLine
	bsr     .syncLine
	bsr     .waitHp
	move.w  #BPLCON2_RD,BPLCON2(a1)
	move.w  COLOR01(a1),d2
	move.w  #BPLCON2_BASE,BPLCON2(a1)
	and.w   #$0FFF,d2
	rts

; Run all three sections at NPROBES horizontal positions each.
.runProbes:
	lea     result1(pc),a4
	moveq   #0,d5
.rp1:
	move.w  d5,d0
	mulu    #HP_STEP,d0
	add.w   #HP_FIRST,d0
	move.w  d0,d1
	add.w   #HP_GAP,d1
	bsr     .probeWriteRead
	move.w  d2,(a4)+
	addq.w  #1,d5
	cmp.w   #NPROBES,d5
	bne.s   .rp1

	lea     result2(pc),a4
	moveq   #0,d5
.rp2:
	move.w  d5,d0
	mulu    #HP_STEP,d0
	add.w   #HP_FIRST,d0
	move.w  d0,d1
	add.w   #HP_GAP,d1
	bsr     .probeReadWrite
	move.w  d2,(a4)+
	addq.w  #1,d5
	cmp.w   #NPROBES,d5
	bne.s   .rp2

	lea     result3(pc),a4
	moveq   #0,d5
.rp3:
	move.w  d5,d0
	mulu    #HP_STEP,d0
	add.w   #HP_FIRST,d0
	bsr     .probeCrossLine
	move.w  d2,(a4)+
	addq.w  #1,d5
	cmp.w   #NPROBES,d5
	bne.s   .rp3
	rts

; Patch the results into the Copper, and the bitplane pointers with them.
.patchCopper:
	lea     sec1Colors(pc),a2
	lea     result1(pc),a3
	bsr     .pc8
	lea     sec2Colors(pc),a2
	lea     result2(pc),a3
	bsr     .pc8
	lea     sec3Colors(pc),a2
	lea     result3(pc),a3
	bsr     .pc8

	lea     bplPtrs(pc),a2
	lea     planes(pc),a3
	moveq   #NPLANES-1,d0
.ppLoop:
	move.l  a3,d3
	move.w  d3,6(a2)                ; low word  -> BPLxPTL
	swap    d3
	move.w  d3,2(a2)                ; high word -> BPLxPTH
	lea     8(a2),a2
	lea     LINEBYTES(a3),a3
	dbra    d0,.ppLoop
	rts

.pc8:
	moveq   #NPROBES-1,d0
.pcLoop:
	move.w  (a3)+,2(a2)
	lea     4(a2),a2
	dbra    d0,.pcLoop
	rts

; ---------------------------------------------------------------------------

copper:
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,BPLCON2_BASE
	dc.w    BPLCON3,$0000
	dc.w    BPLCON4,$0011
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    DDFSTRT,$0038
	dc.w    DDFSTOP,$00B0
	dc.w    BPL1MOD,$FFE0           ; -LINEBYTES: every line refetches
	dc.w    BPL2MOD,$FFE0
	dc.w    COLOR00,BORDER_COL
bplPtrs:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000

	; Section 1 -- write then read, same line
	dc.w    $2F01,$FFFE
sec1Colors:
	dc.w    COLOR01,$0000
	dc.w    COLOR02,$0000
	dc.w    COLOR03,$0000
	dc.w    COLOR04,$0000
	dc.w    COLOR05,$0000
	dc.w    COLOR06,$0000
	dc.w    COLOR07,$0000
	dc.w    COLOR08,$0000
	dc.w    $3001,$FFFE
	dc.w    BPLCON0,BPLCON0_PAL
	dc.w    $6801,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	; Section 2 -- read then write, same line
	dc.w    $6F01,$FFFE
sec2Colors:
	dc.w    COLOR01,$0000
	dc.w    COLOR02,$0000
	dc.w    COLOR03,$0000
	dc.w    COLOR04,$0000
	dc.w    COLOR05,$0000
	dc.w    COLOR06,$0000
	dc.w    COLOR07,$0000
	dc.w    COLOR08,$0000
	dc.w    $7001,$FFFE
	dc.w    BPLCON0,BPLCON0_PAL
	dc.w    $A801,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	; Section 3 -- write, read two lines later
	dc.w    $AF01,$FFFE
sec3Colors:
	dc.w    COLOR01,$0000
	dc.w    COLOR02,$0000
	dc.w    COLOR03,$0000
	dc.w    COLOR04,$0000
	dc.w    COLOR05,$0000
	dc.w    COLOR06,$0000
	dc.w    COLOR07,$0000
	dc.w    COLOR08,$0000
	dc.w    $B001,$FFFE
	dc.w    BPLCON0,BPLCON0_PAL
	dc.w    $E801,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	dc.l    $fffffffe

result1:    ds.w NPROBES
result2:    ds.w NPROBES
result3:    ds.w NPROBES

	cnop    0,8
planes:     ds.b NPLANES*LINEBYTES
