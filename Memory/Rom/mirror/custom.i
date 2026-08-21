; custom.i -- shared body for the Memory/Rom/mirror custom* tests.
;
; The including file must define, before "include"-ing this:
;   PROBE_FIRST  the address probe 0 writes to, e.g. $C00180
;
;
; WHAT IS UNDER TEST
; ------------------
;
; Where the custom chip registers appear a second time. Denise and Agnus do
; not decode the full address bus, so the register block at $DFF000 shows up
; again at many other addresses. This family maps half a megabyte per test by
; writing a colour to $XYY180, the address COLOR00 would occupy if the block
; were mirrored at $XYY000, and looking at whether the background changes.
;
; One raster line per probe, 128 of them:
;
;   line 0    probes  PROBE_FIRST
;   line 1    probes  PROBE_FIRST + $1000
;   ...
;   line 127  probes  PROBE_FIRST + $7F000
;
; A yellow line means the write reached COLOR00 and that address is a mirror.
; A black line means it did not.
;
;
; WHY THIS IS BUILT AROUND THE COPPER
; -----------------------------------
;
; The obvious way to write the test is a CPU loop that walks the addresses
; and toggles the colour, which is what the custC, custD and custE tests it
; replaces did. The picture then encodes CPU timing: where a line changes
; colour depends on how many cycles the loop took to get there, so the
; reference image is really a recording of one particular CPU and one
; particular bus arbitration, and no two machines agree on it.
;
; Here the Copper owns the timing and the CPU owns nothing:
;
;   HP $E0 of the previous line   Copper raises a level 1 interrupt
;   HP $00 of this line           Copper resets COLOR00 to black
;   HP $1A or thereabouts         the interrupt handler writes the probe
;   HP $31 onwards                the part of the line that is recorded
;
; The handler's single write is the only thing whose position depends on the
; CPU, and it is aimed at the gap between the end of one line and HP $31 of
; the next, which no screenshot covers. The gap is 49 colour clocks, just
; under a hundred 68000 cycles, against an interrupt latency of roughly 44
; plus a three instruction handler. That is a wide enough margin to absorb
; the difference between a 68000 and the 68EC020 in an A1200, so the same
; image is expected from every machine. See the README for what was measured.
;
;
; LAYOUT
; ------
;
; 128 lines is half of what fits on a screen, and that is deliberate. An
; earlier revision put 256 probes on one screen and paid for it twice: the
; band ran from raster line $1E to $11D, which a monitor crops at both ends,
; and it crossed raster line 256, where the Copper's eight bit vertical
; counter wraps and a wait for a low line number falls through.
;
; The 128 lines are split into eight blocks of sixteen, ruled off by white
; Copper lines, so a line's number is read as "block times sixteen plus
; offset" rather than counted from the top:
;
;   two white lines      top of the band, and the only asymmetry in it, so
;                        a cropped photograph still shows which end is which
;   16 probe lines       probes $00 to $0F
;   one white line
;   16 probe lines       probes $10 to $1F
;   ...
;   one white line       bottom of the band
;
; The rules are safe from the handler. A rule line has no probe, so nothing
; raises an interrupt on the line before it, and no CPU write ever lands on
; one -- which matters, because a block of sixteen mirrors is otherwise a
; solid yellow slab with nothing to count against.
;
; The whole band spans raster lines $4B to $D4, centred inside the $2C to $F4
; window that every PAL monitor shows.

	IFND PROBE_FIRST
	FAIL "PROBE_FIRST must be defined before including custom.i"
	ENDC

LVL1_INT_VECTOR     equ $64
LVL3_INT_VECTOR     equ $6C

LINE0               equ $4B             ; first line of the top rule
BLOCKS              equ 8               ; blocks of ...
BLOCKLINES          equ 16              ; ... this many probe lines
TOPRULE             equ 2               ; height of the top rule

HP_BASE             equ $01             ; HP $00, start of line: reset colour
HP_IRQ              equ $E1             ; HP $E0, end of line: raise the IRQ

BASE_COLOR          equ $000            ; a line whose probe found nothing
PROBE_COLOR         equ $FF0            ; a line whose probe reached COLOR00
RULE_COLOR          equ $FFF            ; the rules between the blocks
FRAME_COLOR         equ $006            ; above and below the band

PROBE_STEP          equ $1000           ; distance between two probes
PROBES              equ BLOCKS*BLOCKLINES


MAIN:
	lea     CUSTOM,a1

	; Silence the machine. No bitplanes, no sprites, no CIA interrupts:
	; the whole screen is background colour and the Copper paints it.
	move.w  #$0200,BPLCON0(a1)
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01

	; Install the interrupt handlers
	lea     irq1(pc),a0
	move.l  a0,LVL1_INT_VECTOR
	lea     irq3(pc),a0
	move.l  a0,LVL3_INT_VECTOR

	; Set up the registers the handlers rely on. Nothing else touches
	; them, so the handlers need no save and restore and stay short
	; enough to land inside the gap described above.
	movea.l #PROBE_FIRST,a2
	moveq   #0,d6
	move.w  #PROBE_STEP,d6
	move.w  #PROBE_COLOR,d7

	; Install the copper list
	lea     copper(pc),a0
	move.l  a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Copper DMA only. There are no bitplanes and no sprites to fetch.
	move.w  #$8280,DMACON(a1)

	; Master, vertical blank (level 3), software (level 1)
	move.w  #$C024,INTENA(a1)

.mainLoop:
	bra.b   .mainLoop


; ---------------------------------------------------------------------------
; Level 1, raised by the Copper once per probe line
;
; The write comes first and the acknowledge second, so that the probe lands
; as early after the interrupt as it can and the margin stays as wide as
; possible. a2 walks the half megabyte in PROBE_STEP steps.
; ---------------------------------------------------------------------------

irq1:
	move.w  d7,(a2)                 ; probe $XYY180
	adda.w  d6,a2                   ; next probe
	move.w  #$0004,INTREQ(a1)
	rte


; ---------------------------------------------------------------------------
; Level 3, vertical blank
;
; Reloads the probe pointer. The Copper raises exactly PROBES level 1
; interrupts per frame, so a2 would come back to its starting value on its
; own, but reloading it each frame means a single missed interrupt cannot
; shift every later frame by one probe.
; ---------------------------------------------------------------------------

irq3:
	movea.l #PROBE_FIRST,a2
	move.w  #$0020,INTREQ(a1)
	rte


; ---------------------------------------------------------------------------
; The copper list
;
; COLOR00 keeps its value until the next MOVE, so a rule two lines tall costs
; no more instructions than one line tall: set the colour and skip a line.
; ---------------------------------------------------------------------------

copper:
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,FRAME_COLOR

CLINE   set     LINE0

	; The top rule, the one that is taller than the rest
	dc.w    ((CLINE<<8)|HP_BASE),$FFFE
	dc.w    COLOR00,RULE_COLOR
CLINE   set     CLINE+TOPRULE

IDX     set     0
	rept    PROBES

	; Raise the interrupt for this probe at the end of the previous
	; line. The handler writes while the beam is still off the left of
	; the recorded area.
	dc.w    (((CLINE-1)<<8)|HP_IRQ),$FFFE
	dc.w    INTREQ,$8004

	; Reset the background before the handler's write arrives
	dc.w    ((CLINE<<8)|HP_BASE),$FFFE
	dc.w    COLOR00,BASE_COLOR
CLINE   set     CLINE+1
IDX     set     IDX+1

	; Rule off the end of every block. No probe sits on a rule, so no
	; interrupt is raised on the line before it and no CPU write can
	; land on it.
	ifeq    IDX-((IDX/BLOCKLINES)*BLOCKLINES)
	dc.w    ((CLINE<<8)|HP_BASE),$FFFE
	dc.w    COLOR00,RULE_COLOR
CLINE   set     CLINE+1
	endc

	endr

	; Below the band
	dc.w    ((CLINE<<8)|HP_BASE),$FFFE
	dc.w    COLOR00,FRAME_COLOR

	; The band must stay clear of raster line 256, where the Copper's
	; vertical counter wraps and a wait for a low line number falls
	; through instead of waiting.
	ifgt    CLINE-255
	FAIL    "the band runs past raster line 255"
	endc

	dc.l    $FFFFFFFE
