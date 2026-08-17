; bplam2.s -- BPLCON4::BPLAM changed in the middle of a rasterline.
;
; The bplam test sweeps BPLAM through a range of values, one value per
; block of lines, and every value is written while the display is off. It
; therefore says nothing about WHEN a write takes effect. This test is the
; companion: BPLAM changes in the middle of a line, and the value in force
; at the end of a line is deliberately carried over into the next one.
;
; Four bitplanes are enabled, with neither HAM nor DPF set. The bitplane
; data is the killehb trick, one plane narrower:
;
;   plane 1      solid $FFFF, so bit 0 of the colour index is always set,
;                contributing a fixed 1
;   planes 2-4   all three point at ONE shared $FF00 buffer, so bits 1-3
;                rise and fall together, contributing 0 or 2 + 4 + 8 = 14
;
; Every pixel is therefore either index 1 or index 15, and the picture is
; an 8-pixel-wide stripe pattern. Both buffers repeat every single word, so
; drift in the bitplane pointers is invisible: BPLxMOD stays zero and there
; is no fetch-count arithmetic to get wrong.
;
;
; WHAT THE TWO BPLAM VALUES DO
; ----------------------------
;
; The test never lets BPLAM be zero. It alternates between two non-zero
; values, and the palette is arranged so that the two are told apart by
; presence versus absence of a pattern rather than by a shade:
;
;   BPLAM $10   indices 1 and 15 become 17 and 31
;               COLOR17 is blue, COLOR31 is yellow   -> STRIPES
;
;   BPLAM $20   indices 1 and 15 become 33 and 47
;               COLOR33 and COLOR47 are both red     -> FLAT RED
;
; So $10 is the resting value and $20 punches a red stretch into the
; stripes. Neither value is reachable by the four bitplanes on their own,
; which is the point: BPLAM is translating the picture into a different
; block of colour registers, not merely permuting it.
;
; COLOR01 and COLOR15 -- the registers the picture would use if BPLAM were
; lost and fell back to zero -- are set to green and magenta. They appear
; nowhere in a correct run. A green or magenta stripe anywhere on screen
; means BPLAM was zero for those pixels, which is a far louder failure than
; a wrong shade of red would be.
;
;
; THE CROSS-OVER
; --------------
;
; The Copper drives BPLCON4 from a block placed on every 4th line, and the
; blocks are written so that a change is NEVER undone before the line ends:
;
;   line L     starts striped (BPLAM $10, inherited), switches to $20 part
;              way across, and ENDS THAT WAY.
;   line L+1   receives no write at the start of the line at all. It is red
;              from its first pixel only because $20 carried over the line
;              boundary. Part way across it switches back to $10.
;   L+2, L+3   no writes at all -- fully striped, inherited from L+1.
;
; So each block reads as a red stretch that begins in the middle of one
; line, runs off the right hand edge, resumes at the left hand edge of the
; next line and ends in the middle of it. The switch positions advance
; steadily down the screen, so the red forms a staircase rather than a
; block, and every step spans a line boundary.
;
; This is what makes the test worth having. A run that resets BPLCON4 at
; the start of each line draws each red stretch entirely inside line L and
; leaves L+1 striped from the left edge. A run that applies the register
; write to the whole line retroactively colours all of line L red and all
; of L+1 striped. Both failures are obvious at a glance and neither can be
; mistaken for the other.
;
; The screen is a LORES stripe field, then the Agnus/DDF/ddf1 Copper timing
; ruler with all bitplanes disabled, then a HIRES stripe field. The ruler
; gives the absolute horizontal scale for reading off where each switch
; landed.

	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

FMODEREG            equ $1FC           ; AGA only
BPLCON3             equ $106           ; AGA only
BPLCON4             equ $10C           ; AGA only

BPLAM_STRIPES       equ $1011          ; BPLAM = $10, ESPRM/OSPRM = $11
BPLAM_RED           equ $2011          ; BPLAM = $20, ESPRM/OSPRM = $11

BPLCON0_LORES       equ $4200          ; 4 planes, lores
BPLCON0_HIRES       equ $C200          ; 4 planes, hires
BPLCON0_OFF         equ $0200          ; no planes

BLUE                equ $00F
YELLOW              equ $FF0
RED                 equ $F00
GREEN               equ $0F0
MAGENTA             equ $F0F

BUF_SIZE            equ 16384

MAIN:
	lea     CUSTOM,a1

	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #BPLCON0_OFF,BPLCON0(a1)

	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Baseline only -- the Copper drives BPLCON4 from here on.
	move.w  #BPLAM_STRIPES,BPLCON4(a1)

	; A 32-bit fetch. Four planes would fit in a 16-bit lores fetch, but
	; the hires region needs the wider fetch unit to keep all four.
	move.w  #$0001,FMODEREG(a1)     ; BPL32: 32-bit fetch

	; Bitplane data: two buffers, shared by all four planes.
	lea     solidData,a0
	move.w  #(BUF_SIZE/2)-1,d0
.fillSolid: move.w  #$FFFF,(a0)+
	dbra    d0,.fillSolid

	lea     stripeData,a0
	move.w  #(BUF_SIZE/2)-1,d0
.fillStripe: move.w  #$FF00,(a0)+
	dbra    d0,.fillStripe

	; Clear all 256 AGA colour registers. Only six are used, but an
	; untouched register keeps whatever the previously running program left
	; in it, and stray garbage on screen is indistinguishable from a real
	; failure. Banks run 7 down to 0 so bank 0 is written last.
	moveq   #7,d7                   ; d7 = bank (7 downto 0)
.colorBankLoop:
	move.w  d7,d0
	lsl.w   #8,d0                   ; BANK2-0 -> BPLCON3 bits 15-13
	lsl.w   #5,d0
	move.w  d0,BPLCON3(a1)          ; LOCT=0: high nibble of R,G,B
	lea     COLOR00(a1),a2
	moveq   #31,d6
.colorHiLoop:
	move.w  #$0000,(a2)+
	dbra    d6,.colorHiLoop

	or.w    #$0200,d0               ; LOCT=1: low nibble of R,G,B
	move.w  d0,BPLCON3(a1)
	lea     COLOR00(a1),a2
	moveq   #31,d6
.colorLoLoop:
	move.w  #$0000,(a2)+
	dbra    d6,.colorLoLoop

	dbra    d7,.colorBankLoop

	; Bank 0 registers 17 and 31 are COLOR17 and COLOR31 -- what indices 1
	; and 15 reach once BPLAM $10 is XORed in. Blue and yellow, so the
	; resting state is a full-brightness stripe pattern. Each register is
	; written twice (LOCT=0 then LOCT=1) to fill both nibbles of every
	; channel, giving a true $FF component rather than $F0.
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT=0
	move.w  #BLUE,COLOR17(a1)
	move.w  #YELLOW,COLOR31(a1)
	move.w  #$0200,BPLCON3(a1)      ; bank 0, LOCT=1
	move.w  #BLUE,COLOR17(a1)
	move.w  #YELLOW,COLOR31(a1)

	; Bank 0 registers 1 and 15 are COLOR01 and COLOR15 -- the registers
	; the picture would land on if BPLAM were zero. Green and magenta, so a
	; lost BPLAM shows up as a colour that belongs nowhere on this screen.
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT=0
	move.w  #GREEN,COLOR01(a1)
	move.w  #MAGENTA,COLOR15(a1)
	move.w  #$0200,BPLCON3(a1)      ; bank 0, LOCT=1
	move.w  #GREEN,COLOR01(a1)
	move.w  #MAGENTA,COLOR15(a1)

	; Bank 1 registers 1 and 15 are COLOR33 and COLOR47 -- what indices 1
	; and 15 reach once BPLAM $20 is XORed in. BOTH are red, so wherever
	; $20 is in force the two stripe indices collapse onto one colour and
	; the pattern disappears into a flat red stretch.
	move.w  #$2000,BPLCON3(a1)      ; bank 1, LOCT=0
	move.w  #RED,COLOR01(a1)        ; COLOR33
	move.w  #RED,COLOR15(a1)        ; COLOR47
	move.w  #$2200,BPLCON3(a1)      ; bank 1, LOCT=1
	move.w  #RED,COLOR01(a1)
	move.w  #RED,COLOR15(a1)
	move.w  #$0000,BPLCON3(a1)      ; leave BPLCON3 in a known state

	; Patch the two buffer addresses into both regions' pointer blocks.
	; Plane 1 takes the solid buffer, planes 2-4 share the stripe buffer.
	lea     copper(pc),a2
	bsr     patchPointers

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

; Walks the Copper list and fills in every BPLxPTH/BPLxPTL pair it finds.
; Plane 1 gets the solid buffer, planes 2 to 4 get the stripe buffer. WAIT
; instructions are skipped, so the scan cannot mistake a wait value for a
; register.
patchPointers:
	lea     copper(pc),a2
.loop:
	cmpi.l  #$FFFFFFFE,(a2)
	beq.s   .done
	move.w  (a2)+,d1
	btst    #0,d1                   ; bit 0 set -> this is a WAIT
	bne.s   .skip
	cmpi.w  #BPL1PTH,d1
	beq.s   .solidHi
	cmpi.w  #BPL1PTL,d1
	beq.s   .solidLo
	cmpi.w  #BPL2PTH,d1
	beq.s   .stripeHi
	cmpi.w  #BPL2PTL,d1
	beq.s   .stripeLo
	cmpi.w  #BPL3PTH,d1
	beq.s   .stripeHi
	cmpi.w  #BPL3PTL,d1
	beq.s   .stripeLo
	cmpi.w  #BPL4PTH,d1
	beq.s   .stripeHi
	cmpi.w  #BPL4PTL,d1
	beq.s   .stripeLo
.skip:
	addq.l  #2,a2
	bra.s   .loop
.solidHi:
	move.l  #solidData,d3
	swap    d3
	move.w  d3,(a2)+
	bra.s   .loop
.solidLo:
	move.l  #solidData,d3
	move.w  d3,(a2)+
	bra.s   .loop
.stripeHi:
	move.l  #stripeData,d3
	swap    d3
	move.w  d3,(a2)+
	bra.s   .loop
.stripeLo:
	move.l  #stripeData,d3
	move.w  d3,(a2)+
	bra.s   .loop
.done:
	rts

copper:
	dc.w    BPLCON0,BPLCON0_OFF     ; planes off until the lores region
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024
	dc.w    BPLCON3,$0000
	dc.w    BPLCON4,BPLAM_STRIPES
	dc.w    DIWSTRT,$2C71
	dc.w    DIWSTOP,$2CC1

	; One DDF window for the whole frame -- the hires region simply uses
	; the lores values, giving a slightly narrower picture there. Nothing
	; changes DDF mid-frame.
	dc.w    DDFSTRT,$0038
	dc.w    DDFSTOP,$00C8
	dc.w    BPL1MOD,$0000           ; see the bitplane data note in MAIN
	dc.w    BPL2MOD,$0000

	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000


	;
	; LORES stripe field
	;
	dc.w    $3001,$FFFE
	dc.w    BPLCON0,BPLCON0_LORES

	;
	; Block 0 (lines $30 and $31): red starts mid-line $30,
	; runs over the line end and stops mid-line $31.
	;
	dc.w    $3041,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $3181,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 1 (lines $34 and $35): red starts mid-line $34,
	; runs over the line end and stops mid-line $35.
	;
	dc.w    $3445,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $3585,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 2 (lines $38 and $39): red starts mid-line $38,
	; runs over the line end and stops mid-line $39.
	;
	dc.w    $3849,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $3989,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 3 (lines $3C and $3D): red starts mid-line $3C,
	; runs over the line end and stops mid-line $3D.
	;
	dc.w    $3C4D,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $3D8D,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 4 (lines $40 and $41): red starts mid-line $40,
	; runs over the line end and stops mid-line $41.
	;
	dc.w    $4051,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $4191,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 5 (lines $44 and $45): red starts mid-line $44,
	; runs over the line end and stops mid-line $45.
	;
	dc.w    $4455,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $4595,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 6 (lines $48 and $49): red starts mid-line $48,
	; runs over the line end and stops mid-line $49.
	;
	dc.w    $4859,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $4999,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 7 (lines $4C and $4D): red starts mid-line $4C,
	; runs over the line end and stops mid-line $4D.
	;
	dc.w    $4C5D,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $4D9D,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 8 (lines $50 and $51): red starts mid-line $50,
	; runs over the line end and stops mid-line $51.
	;
	dc.w    $5061,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $51A1,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 9 (lines $54 and $55): red starts mid-line $54,
	; runs over the line end and stops mid-line $55.
	;
	dc.w    $5465,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $55A5,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 10 (lines $58 and $59): red starts mid-line $58,
	; runs over the line end and stops mid-line $59.
	;
	dc.w    $5869,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $59A9,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 11 (lines $5C and $5D): red starts mid-line $5C,
	; runs over the line end and stops mid-line $5D.
	;
	dc.w    $5C6D,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $5DAD,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 12 (lines $60 and $61): red starts mid-line $60,
	; runs over the line end and stops mid-line $61.
	;
	dc.w    $6071,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $61B1,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 13 (lines $64 and $65): red starts mid-line $64,
	; runs over the line end and stops mid-line $65.
	;
	dc.w    $6475,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $65B5,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 14 (lines $68 and $69): red starts mid-line $68,
	; runs over the line end and stops mid-line $69.
	;
	dc.w    $6879,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $69B9,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 15 (lines $6C and $6D): red starts mid-line $6C,
	; runs over the line end and stops mid-line $6D.
	;
	dc.w    $6C7D,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $6DBD,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES


	; Copper timing ruler (from ddf1), all bitplanes disabled.
	; Written to COLOR16: BPLAM $10 maps the index 0 background there.
	;
	dc.w    $7001,$FFFE            ; planes off
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    $7139,$FFFE            ; ruler starts where the data does
	dc.w    COLOR16,$F00
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$FFF
	dc.w    COLOR16,$000
	dc.w    COLOR16,$0F0
	dc.w    COLOR16,$000

	;
	; HIRES stripe field. Pointers are reloaded while the planes are
	; still off, then the region is switched on one line later.
	;
	dc.w    $7301,$FFFE
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    BPLCON0,BPLCON0_HIRES

	;
	; Block 16 (lines $74 and $75): red starts mid-line $74,
	; runs over the line end and stops mid-line $75.
	;
	dc.w    $7441,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $7581,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 17 (lines $78 and $79): red starts mid-line $78,
	; runs over the line end and stops mid-line $79.
	;
	dc.w    $7845,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $7985,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 18 (lines $7C and $7D): red starts mid-line $7C,
	; runs over the line end and stops mid-line $7D.
	;
	dc.w    $7C49,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $7D89,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 19 (lines $80 and $81): red starts mid-line $80,
	; runs over the line end and stops mid-line $81.
	;
	dc.w    $804D,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $818D,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 20 (lines $84 and $85): red starts mid-line $84,
	; runs over the line end and stops mid-line $85.
	;
	dc.w    $8451,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $8591,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 21 (lines $88 and $89): red starts mid-line $88,
	; runs over the line end and stops mid-line $89.
	;
	dc.w    $8855,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $8995,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 22 (lines $8C and $8D): red starts mid-line $8C,
	; runs over the line end and stops mid-line $8D.
	;
	dc.w    $8C59,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $8D99,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 23 (lines $90 and $91): red starts mid-line $90,
	; runs over the line end and stops mid-line $91.
	;
	dc.w    $905D,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $919D,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 24 (lines $94 and $95): red starts mid-line $94,
	; runs over the line end and stops mid-line $95.
	;
	dc.w    $9461,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $95A1,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 25 (lines $98 and $99): red starts mid-line $98,
	; runs over the line end and stops mid-line $99.
	;
	dc.w    $9865,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $99A5,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 26 (lines $9C and $9D): red starts mid-line $9C,
	; runs over the line end and stops mid-line $9D.
	;
	dc.w    $9C69,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $9DA9,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 27 (lines $A0 and $A1): red starts mid-line $A0,
	; runs over the line end and stops mid-line $A1.
	;
	dc.w    $A06D,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $A1AD,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 28 (lines $A4 and $A5): red starts mid-line $A4,
	; runs over the line end and stops mid-line $A5.
	;
	dc.w    $A471,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $A5B1,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 29 (lines $A8 and $A9): red starts mid-line $A8,
	; runs over the line end and stops mid-line $A9.
	;
	dc.w    $A875,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $A9B5,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 30 (lines $AC and $AD): red starts mid-line $AC,
	; runs over the line end and stops mid-line $AD.
	;
	dc.w    $AC79,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $ADB9,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES
	;
	; Block 31 (lines $B0 and $B1): red starts mid-line $B0,
	; runs over the line end and stops mid-line $B1.
	;
	dc.w    $B07D,$FFFE
	dc.w    BPLCON4,BPLAM_RED
	; No write at the start of the next line: it is red only
	; because BPLAM $20 carried across the line boundary.
	dc.w    $B1BD,$FFFE
	dc.w    BPLCON4,BPLAM_STRIPES

	;
	; Done -- shut the display down again.
	;
	dc.w    $B801,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON4,BPLAM_STRIPES

	dc.l    $fffffffe

	cnop    0,8                     ; 32-bit fetch wants aligned pointers
solidData:  ds.b BUF_SIZE
	cnop    0,8
stripeData: ds.b BUF_SIZE
