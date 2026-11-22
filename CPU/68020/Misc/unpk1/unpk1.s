;
; unpk1 -- How does UNPK -(Ax),-(Ay),#adj write its result?
;
; UNPK -(Ax),-(Ay) stores a word at Ay-2. It could be written as two byte
; accesses (the low byte at Ay-1 first, then the high byte at Ay-2) or as a
; single word. Registers and memory end up the same, so the
; test makes the CPU write into COLOR00. A custom register has no byte enables:
; a byte write sets the whole register, so every write shows up as a color.
;
; The Copper resets COLOR00 to grey at the start of each band and raises a
; level 1 interrupt in the middle of the first line. The CPU waits in STOP and
; performs the band's write in the interrupt handler, so each band shows grey
; on the left and the written color on the right of its first line. STOP is
; privileged and MAIN runs in user mode (see ministartup.i), so the program
; enters supervisor mode with TRAP #0 and never returns.
;
;   band 1  move.b #$0F,COLOR00       byte write to the high byte (reference)
;   band 2  move.b #$0A,COLOR00+1     byte write to the low byte  (reference)
;   band 3  move.w #$0F0A,COLOR00     word write                  (reference)
;   band 4  unpk -(a0),-(a2),#0       source byte $FA, result $0F0A
;
; EXPECTED (band 4 compared with the reference bands):
;
;   band 4 = band 3                  UNPK writes one word
;   band 4 = band 1                  two byte writes, low byte first, then the
;                                    high byte; the first line may show the
;                                    color of band 2 for a few pixels
;   band 4 = band 2                  two byte writes, high byte first
;
; Result (A1200): Band 4 shows the color of band 3. UNPK writes one word.
;

	include "../../../../include/registers.i"
	include "../../../../include/ministartup.i"

LVL1_INT_VECTOR     equ $64
LVL3_INT_VECTOR     equ $6C
TRAP0_VECTOR        equ $80

LINE0               equ $40
BANDLINES           equ $20
HP_BASE             equ $01
HP_IRQ              equ $61

GREY                equ $444
FRAME_COLOR         equ $006

MAIN:
	lea     CUSTOM,a1

	move.w  #$0200,BPLCON0(a1)
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01

	lea     irq1(pc),a0
	move.l  a0,LVL1_INT_VECTOR
	lea     irq3(pc),a0
	move.l  a0,LVL3_INT_VECTOR
	lea     mainLoop(pc),a0
	move.l  a0,TRAP0_VECTOR

	lea     copper(pc),a0
	move.l  a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	move.w  #$8280,DMACON(a1)       ; Copper DMA
	move.w  #$C024,INTENA(a1)       ; master, VBlank (3), software (1)

	trap    #0                      ; continue in supervisor mode

mainLoop:
	stop    #$2000                  ; wait for the next interrupt
	bra.b   mainLoop

; ---------------------------------------------------------------------------
; Level 1, raised by the Copper at the start of each band
; ---------------------------------------------------------------------------

irq1:
	movem.l d0-a6,-(sp)
	lea     CUSTOM,a1

	lea     band(pc),a3
	move.w  (a3),d0
	addq.w  #1,(a3)

	cmp.w   #0,d0
	bne.s   .band2
	move.b  #$0F,COLOR00(a1)
	bra.s   .done
.band2:
	cmp.w   #1,d0
	bne.s   .band3
	move.b  #$0A,COLOR00+1(a1)
	bra.s   .done
.band3:
	cmp.w   #2,d0
	bne.s   .band4
	move.w  #$0F0A,COLOR00(a1)
	bra.s   .done
.band4:
	lea     source+1(pc),a0
	lea     COLOR00+2(a1),a2
	unpk    -(a0),-(a2),#0

.done:
	move.w  #$0004,INTREQ(a1)
	movem.l (sp)+,d0-a6
	rte

; ---------------------------------------------------------------------------
; Level 3, vertical blank
; ---------------------------------------------------------------------------

irq3:
	move.w  #0,band
	move.w  #$0020,CUSTOM+INTREQ
	rte

band:
	dc.w    0
source:
	dc.b    $FA, 0
	even

; ---------------------------------------------------------------------------
; The copper list
; ---------------------------------------------------------------------------

copper:
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,FRAME_COLOR

CLINE   set     LINE0
	rept    4
	dc.w    ((CLINE<<8)|HP_BASE),$FFFE
	dc.w    COLOR00,GREY
	dc.w    ((CLINE<<8)|HP_IRQ),$FFFE
	dc.w    INTREQ,$8004            ; raise level 1 for this band
CLINE   set     CLINE+BANDLINES
	endr

	dc.w    ((CLINE<<8)|HP_BASE),$FFFE
	dc.w    COLOR00,FRAME_COLOR

	ifgt    CLINE-255
	FAIL    "the bands run past raster line 255"
	endc

	dc.l    $FFFFFFFE
