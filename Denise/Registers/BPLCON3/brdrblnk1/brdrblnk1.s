; brdrblnk1.s -- BPLCON3::BRDRBLNK, the blanked border (ECS and AGA).
;
; A companion test, brdrblnk2, asks what BRDRBLNK does when no bitplanes
; are enabled at all; this one always has at least one.
;
; BRDRBLNK is bit 5 of BPLCON3. With it clear, the border area outside the
; display window is painted in the background colour, COLOR00, exactly as
; on OCS. With it set, the border is forced to pure black instead, which is
; what lets a program use a non-black COLOR00 inside the display window
; without the whole screen surround taking that colour too.
;
; The bit only has an effect when ECSENA (BPLCON0 bit 0) is set, so ECSENA
; is on throughout this test, including on the lines where the bitplanes
; are switched off.
;
;
; HOW THE SCREEN IS BUILT
; -----------------------
;
; COLOR00 is orange and COLOR01 is blue, and a single bitplane is filled
; with solid $FFFF. So every pixel inside the display window is index 1 and
; comes out blue, and the border is the only thing COLOR00 can reach:
;
;   border, BRDRBLNK clear   orange
;   border, BRDRBLNK set     black
;   display window           blue, unaffected either way
;
; Three colours that cannot be confused, and the display window acts as a
; fixed landmark between the two border halves. On the lines where the
; bitplanes are disabled the window turns orange as well (index 0 reaches
; COLOR00 there), which makes the window edges themselves visible and is
; used by the last region below.
;
; The buffer repeats every single word, so BPLxMOD stays zero and pointer
; drift is invisible.
;
;
; THE FOUR REGIONS
; ----------------
;
; Region 1, lines $30-$4F -- LARGE border, whole-line switching.
;
;   A narrow display window (DIWSTRT $2CA1, DIWSTOP $2C41) leaves a wide
;   border on both sides. BRDRBLNK is switched at the very start of each
;   line and left alone for the rest of it, two lines set followed by two
;   lines clear, all the way down. The result is a horizontal bar pattern
;   in both borders.
;
;   Nothing else is written in this region -- in particular the display
;   window registers are not touched after the region begins. That matters:
;   an implementation that only recomputes its border mask when the display
;   window changes will show a single uniform border here instead of bars,
;   and this is the region that catches it.
;
; Region 2, lines $50-$8F -- LARGE border, mid-line switching.
;
;   Same narrow window. BRDRBLNK is now set part way across the line and
;   cleared again before the line ends, with both positions advancing four
;   colour clocks per block of four lines. The black stretch therefore
;   walks to the right as the eye travels down, forming a staircase across
;   both borders.
;
;   A machine that applies the register write at the pixel where it happens
;   draws that staircase. A machine that applies it to the whole rasterline
;   retroactively draws solid bars again, with no horizontal structure at
;   all. The two outcomes are not similar.
;
; Region 3, line $90 -- the Agnus/DDF/ddf1 Copper timing ruler.
;
; Region 4, lines $94-$D3 -- SMALL border, switching read against a ruler.
;
;   The window widens to the usual DIWSTRT $2C71 / DIWSTOP $2CC1, so the
;   border shrinks to a thin strip on each side. The region is built from
;   blocks of eight lines whose first line carries a Copper ruler with the
;   bitplanes disabled. On a ruler line the window interior is orange and
;   the border is black or orange according to BRDRBLNK, so the window edge
;   is directly visible and the ruler stripes give the horizontal scale to
;   measure it against.
;
;   BRDRBLNK is switched on at a position that advances by one ruler stripe
;   per block, which is what turns this region into a timing measurement:
;   the stripe at which the border changes colour can be counted off
;   directly, block by block.

	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

FMODEREG            equ $1FC           ; AGA only
BPLCON3             equ $106           ; ECS and AGA
BPLCON4             equ $10C           ; AGA only

BRDRBLNK_OFF        equ $0000          ; border takes COLOR00
BRDRBLNK_ON         equ $0020          ; border forced to black (bit 5)

; ECSENA (bit 0) must be set for BRDRBLNK to do anything, so it is included
; in every BPLCON0 value used here, the plane-less one included.
BPLCON0_ON          equ $1201          ; 1 plane, lores, ECSENA
BPLCON0_OFF         equ $0201          ; no planes, ECSENA

DIW_WIDE_STRT       equ $2C81          ; small border, but wide enough to see
DIW_WIDE_STOP       equ $2CA1
DIW_NARROW_STRT     equ $2CA1          ; large border
DIW_NARROW_STOP     equ $2C41

ORANGE              equ $F80
BLUE                equ $00F

BUF_SIZE            equ 8192

MAIN:
	lea     CUSTOM,a1

	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #BPLCON0_OFF,BPLCON0(a1)

	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	move.w  #$0001,FMODEREG(a1)     ; BPL32: 32-bit fetch

	; One bitplane buffer, solid, so the whole window is index 1.
	lea     planeData,a0
	move.w  #(BUF_SIZE/2)-1,d0
.fillSolid: move.w  #$FFFF,(a0)+
	dbra    d0,.fillSolid

	; Clear all 256 AGA colour registers so nothing left behind by a
	; previous program can be mistaken for a result. Banks run 7 down to 0
	; so bank 0 is written last.
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

	; COLOR00 orange (the border when BRDRBLNK is clear) and COLOR01 blue
	; (the display window). Both written twice, LOCT=0 then LOCT=1, so each
	; channel gets both nibbles.
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT=0
	move.w  #ORANGE,COLOR00(a1)
	move.w  #BLUE,COLOR01(a1)
	move.w  #$0200,BPLCON3(a1)      ; bank 0, LOCT=1
	move.w  #ORANGE,COLOR00(a1)
	move.w  #BLUE,COLOR01(a1)
	move.w  #$0000,BPLCON3(a1)      ; leave BPLCON3 in a known state

	; Patch the buffer address into the Copper list.
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

; Walks the Copper list and fills in every BPL1PTH/BPL1PTL pair it finds.
; WAIT instructions are skipped, so the scan cannot mistake a wait value for
; a register.
patchPointers:
	lea     copper(pc),a2
.loop:
	cmpi.l  #$FFFFFFFE,(a2)
	beq.s   .done
	move.w  (a2)+,d1
	btst    #0,d1                   ; bit 0 set -> this is a WAIT
	bne.s   .skip
	cmpi.w  #BPL1PTH,d1
	beq.s   .hi
	cmpi.w  #BPL1PTL,d1
	beq.s   .lo
.skip:
	addq.l  #2,a2
	bra.s   .loop
.hi:
	move.l  #planeData,d3
	swap    d3
	move.w  d3,(a2)+
	bra.s   .loop
.lo:
	move.l  #planeData,d3
	move.w  d3,(a2)+
	bra.s   .loop
.done:
	rts

copper:
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    BPLCON4,$0011           ; AGA defaults
	dc.w    DDFSTRT,$0038
	dc.w    DDFSTOP,$00C8
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000


	;
	; Region 1: LARGE border, BRDRBLNK switched on whole lines only.
	; Two lines set, two lines clear. The display window registers are
	; deliberately left untouched for the whole region.
	;
	dc.w    $3001,$FFFE
	dc.w    DIWSTRT,DIW_NARROW_STRT
	dc.w    DIWSTOP,DIW_NARROW_STOP
	dc.w    BPLCON0,BPLCON0_ON

	dc.w    $3001,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $3201,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $3401,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $3601,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $3801,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $3A01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $3C01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $3E01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $4001,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $4201,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $4401,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $4601,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $4801,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $4A01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $4C01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $4E01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Region 2: LARGE border, BRDRBLNK switched in mid-line. Both switch
	; positions advance by four colour clocks per block of four lines, so
	; the blanked stretch walks to the right down the screen.
	;
	dc.w    $5031,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $50A1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5131,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $51A1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5231,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $52A1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5331,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $53A1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5433,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $54A5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5533,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $55A5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5633,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $56A5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5733,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $57A5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5835,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $58A9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5935,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $59A9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5A35,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $5AA9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5B35,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $5BA9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5C37,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $5CAD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5D37,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $5DAD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5E37,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $5EAD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $5F37,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $5FAD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $6039,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $60B1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $6139,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $61B1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $6239,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $62B1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $6339,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $63B1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $643B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $64B5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $653B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $65B5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $663B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $66B5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $673B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $67B5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $683D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $68B9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $693D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $69B9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $6A3D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $6AB9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $6B3D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $6BB9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $6C3F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $6CBD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $6D3F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $6DBD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $6E3F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $6EBD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $6F3F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $6FBD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7041,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $70C1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7141,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $71C1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7241,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $72C1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7341,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $73C1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7443,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $74C5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7543,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $75C5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7643,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $76C5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7743,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $77C5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7845,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $78C9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7945,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $79C9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7A45,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $7AC9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7B45,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $7BC9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7C47,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $7CCD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7D47,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $7DCD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7E47,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $7ECD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $7F47,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $7FCD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $8049,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $80D1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $8149,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $81D1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $8249,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $82D1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $8349,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $83D1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $844B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $84D5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $854B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $85D5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $864B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $86D5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $874B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $87D5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $884D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $88D9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $894D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $89D9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $8A4D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $8AD9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $8B4D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $8BD9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $8C4F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $8CDD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $8D4F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $8DDD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $8E4F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $8EDD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $8F4F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $8FDD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	; Copper timing ruler (from ddf1), all bitplanes disabled.
	;
	dc.w    $9001,$FFFE            ; planes off
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    $9139,$FFFE            ; ruler starts where the data does
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
	; The ruler train leaves COLOR00 black; put the orange back so the
	; border is readable again below.
	dc.w    $91E1,$FFFE
	dc.w    COLOR00,ORANGE

	;
	; Region 4: SMALL border. Each block of eight lines opens with a ruler
	; line that has the bitplanes disabled, so the window interior shows
	; COLOR00 and the window edge is visible against the border. BRDRBLNK
	; switches on one ruler stripe further right in every block.
	;
	dc.w    $9301,$FFFE
	dc.w    DIWSTRT,DIW_WIDE_STRT
	dc.w    DIWSTOP,DIW_WIDE_STOP

	;
	; Block 0 (lines $94-$9B). Ruler on $95, then six lines
	; with BRDRBLNK set from h=$31 to h=$D1.
	;
	dc.w    $9401,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $9539,$FFFE            ; ruler starts where the data does
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
	dc.w    $95E1,$FFFE
	dc.w    COLOR00,ORANGE
	dc.w    $9601,$FFFE
	dc.w    BPLCON0,BPLCON0_ON
	dc.w    $9631,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $96D1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $9731,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $97D1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $9831,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $98D1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $9931,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $99D1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $9A31,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $9AD1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $9B31,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $9BD1,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	;
	; Block 1 (lines $9C-$A3). Ruler on $9D, then six lines
	; with BRDRBLNK set from h=$33 to h=$D3.
	;
	dc.w    $9C01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $9D39,$FFFE            ; ruler starts where the data does
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
	dc.w    $9DE1,$FFFE
	dc.w    COLOR00,ORANGE
	dc.w    $9E01,$FFFE
	dc.w    BPLCON0,BPLCON0_ON
	dc.w    $9E33,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $9ED3,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $9F33,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $9FD3,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $A033,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $A0D3,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $A133,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $A1D3,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $A233,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $A2D3,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $A333,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $A3D3,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	;
	; Block 2 (lines $A4-$AB). Ruler on $A5, then six lines
	; with BRDRBLNK set from h=$35 to h=$D5.
	;
	dc.w    $A401,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $A539,$FFFE            ; ruler starts where the data does
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
	dc.w    $A5E1,$FFFE
	dc.w    COLOR00,ORANGE
	dc.w    $A601,$FFFE
	dc.w    BPLCON0,BPLCON0_ON
	dc.w    $A635,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $A6D5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $A735,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $A7D5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $A835,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $A8D5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $A935,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $A9D5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $AA35,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $AAD5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $AB35,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $ABD5,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	;
	; Block 3 (lines $AC-$B3). Ruler on $AD, then six lines
	; with BRDRBLNK set from h=$37 to h=$D7.
	;
	dc.w    $AC01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $AD39,$FFFE            ; ruler starts where the data does
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
	dc.w    $ADE1,$FFFE
	dc.w    COLOR00,ORANGE
	dc.w    $AE01,$FFFE
	dc.w    BPLCON0,BPLCON0_ON
	dc.w    $AE37,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $AED7,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $AF37,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $AFD7,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $B037,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $B0D7,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $B137,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $B1D7,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $B237,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $B2D7,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $B337,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $B3D7,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	;
	; Block 4 (lines $B4-$BB). Ruler on $B5, then six lines
	; with BRDRBLNK set from h=$39 to h=$D9.
	;
	dc.w    $B401,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $B539,$FFFE            ; ruler starts where the data does
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
	dc.w    $B5E1,$FFFE
	dc.w    COLOR00,ORANGE
	dc.w    $B601,$FFFE
	dc.w    BPLCON0,BPLCON0_ON
	dc.w    $B639,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $B6D9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $B739,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $B7D9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $B839,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $B8D9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $B939,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $B9D9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $BA39,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $BAD9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $BB39,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $BBD9,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	;
	; Block 5 (lines $BC-$C3). Ruler on $BD, then six lines
	; with BRDRBLNK set from h=$3B to h=$DB.
	;
	dc.w    $BC01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $BD39,$FFFE            ; ruler starts where the data does
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
	dc.w    $BDE1,$FFFE
	dc.w    COLOR00,ORANGE
	dc.w    $BE01,$FFFE
	dc.w    BPLCON0,BPLCON0_ON
	dc.w    $BE3B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $BEDB,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $BF3B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $BFDB,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $C03B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $C0DB,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $C13B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $C1DB,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $C23B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $C2DB,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $C33B,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $C3DB,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	;
	; Block 6 (lines $C4-$CB). Ruler on $C5, then six lines
	; with BRDRBLNK set from h=$3D to h=$DD.
	;
	dc.w    $C401,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $C539,$FFFE            ; ruler starts where the data does
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
	dc.w    $C5E1,$FFFE
	dc.w    COLOR00,ORANGE
	dc.w    $C601,$FFFE
	dc.w    BPLCON0,BPLCON0_ON
	dc.w    $C63D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $C6DD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $C73D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $C7DD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $C83D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $C8DD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $C93D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $C9DD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $CA3D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $CADD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $CB3D,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $CBDD,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	;
	; Block 7 (lines $CC-$D3). Ruler on $CD, then six lines
	; with BRDRBLNK set from h=$3F to h=$DF.
	;
	dc.w    $CC01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $CD39,$FFFE            ; ruler starts where the data does
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
	dc.w    $CDE1,$FFFE
	dc.w    COLOR00,ORANGE
	dc.w    $CE01,$FFFE
	dc.w    BPLCON0,BPLCON0_ON
	dc.w    $CE3F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $CEDF,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $CF3F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $CFDF,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $D03F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $D0DF,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $D13F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $D1DF,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $D23F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $D2DF,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    $D33F,$FFFE
	dc.w    BPLCON3,BRDRBLNK_ON
	dc.w    $D3DF,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Done -- shut the display down again.
	;
	dc.w    $D801,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,BRDRBLNK_OFF

	dc.l    $fffffffe

	cnop    0,8                     ; 32-bit fetch wants aligned pointers
planeData:  ds.b BUF_SIZE
