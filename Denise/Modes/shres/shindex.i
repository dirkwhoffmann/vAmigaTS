; shindex.i -- shared body for the Denise/Modes shindex1 to shindex5 tests.
;
; The including file must define, before "include"-ing this:
;   INDEX_BIT   which bit of the colour index this test probes (0 to 4)
; and may optionally define:
;   SHRES_BPU   how many bitplanes to enable (default 2)
;
; SHRES_BPU exists for the sh1bpl family, which repeats this sweep with a
; single bitplane. With one plane the pixel value carries only bitplane 1, so
; sections sharing the same bitplane 1 bits should become indistinguishable --
; and shres00 hints that one plane does not simply behave like two planes with
; the second one zero.
;
;
; WHAT IS UNDER TEST
; ------------------
;
; Which colour register a super hires pixel actually reaches, read out
; completely rather than inferred.
;
; The predecessor family, shspot, packed several different indices into
; each section and asked which registers lit up. That failed for a reason
; worth recording: at super hires a feature two pixels wide does not
; survive the trip through a CRT and a camera. A single black pixel
; between blue ones bleeds away to a ripple of a few percent -- visible
; as a faint wobble in what looks like a solid blue block, but nowhere
; near readable as black. Any test whose answer lives in fine detail is
; unreadable on real hardware, however clean it looks in an emulator.
;
; So this family makes every section FLAT.
;
; Section k repeats just two pixel values, a and b, alternating:
;
;     a b a b a b a b ...      a = k & 3,  b = (k >> 2) & 3
;
; The pattern has period two, so any colour function of a window of
; neighbouring pixels -- whatever its width, whatever its phase -- is also
; period two, and the whole section comes out as ONE colour. That holds
; without assuming anything about how Denise builds the index, which is
; the point: the previous families all baked in a model that turned out to
; be wrong.
;
; Sixteen sections cover every (a, b) combination, including the four
; constant ones where a = b.
;
;
; READING THE INDEX OFF
; ---------------------
;
; Rather than lighting one register at a time and needing 32 tests, the
; palette encodes the register number in binary. In test j every register
; whose bit j is set is yellow, and every other register is blue. Five
; tests then give five bits, so the index of each section is read straight
; out of which tests show that section yellow:
;
;     shindex1 -> bit 0, shindex2 -> bit 1, ... shindex5 -> bit 4
;
; A section that is blue in all five tests is index 0. Both colours are
; built from nibbles $0 and $F so they survive Denise's nibble split, and
; yellow against blue is the most legible pair through a camera.
;
;
; ORIENTATION
; -----------
;
; The sections are deliberately NOT symmetric top to bottom: the bar above
; section 0 is four lines thick and the bar below section 15 is two, while
; every bar between sections is one. Photographs of this machine come out
; rotated as often as not, and with sixteen identical looking bands there
; is otherwise nothing to tell which end is which -- an ambiguity that
; silently inverted the reading of the shspot photographs.

	IFND DDF_START
DDF_START           equ $0038
	ENDC
	IFND DDF_STOP
DDF_STOP            equ $00B0
	ENDC

	IFND SHRES_BPU
SHRES_BPU           equ 2
	ENDC

BPLCON0_VAL         equ (SHRES_BPU*$1000)+$0240

DIW_START           equ $2C00+(DDF_START*2)+9
DIW_STOP            equ $2CC1

; A section is nine display lines and super hires pulls about 122 bytes
; per line per plane, so under 1100 bytes. Only four buffers are needed in
; total, because every section's plane is one of four repeating words, and
; each section re-points to the start of whichever it needs.
PLANE_SIZE          equ 2048

BAR_COLOR           equ $FFF
YES_COLOR           equ $FF0                ; register has this bit set
NO_COLOR            equ $00F                ; register has it clear


MAIN:
	lea     CUSTOM,a1

	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01

	; The four repeating words every section is built from
	lea     bufA,a0
	move.w  #$0000,d1
	bsr     .fill
	lea     bufB,a0
	move.w  #$5555,d1
	bsr     .fill
	lea     bufC,a0
	move.w  #$AAAA,d1
	bsr     .fill
	lea     bufD,a0
	move.w  #$FFFF,d1
	bsr     .fill

	; Palette: register r is yellow when bit INDEX_BIT of r is set.
	lea     COLOR00(a1),a2
	moveq   #0,d0                   ; d0 = register number
.palLoop:
	move.w  #NO_COLOR,d1
	btst    #INDEX_BIT,d0
	beq.s   .palPut
	move.w  #YES_COLOR,d1
.palPut:
	move.w  d1,(a2)+
	addq.w  #1,d0
	cmp.w   #32,d0
	bne.s   .palLoop

	; Bitplanes 3 to 6 are never enabled, so they are never fetched and
	; their data registers would keep whatever Kickstart left behind.
	move.w  #$0000,DPL3DATA(a1)
	move.w  #$0000,DPL4DATA(a1)
	move.w  #$0000,DPL5DATA(a1)
	move.w  #$0000,DPL6DATA(a1)

	; Patch each section's two bitplane pointers into its copper block
	lea     sectionPtrTable(pc),a4
.ptLoop:
	move.l  (a4)+,d0
	beq.s   .ptDone
	move.l  d0,a2
	move.l  (a4)+,d3
	move.w  d3,6(a2)
	swap    d3
	move.w  d3,2(a2)
	move.l  (a4)+,d3
	move.w  d3,14(a2)
	swap    d3
	move.w  d3,10(a2)
	bra.s   .ptLoop
.ptDone:

	lea     CUSTOM,a1
	lea     copper(pc),a0
	move.l  a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #$8080,DMACON(a1)
	move.w  #$8100,DMACON(a1)
	move.w  #$8200,DMACON(a1)
.mainLoop:
	bra.b   .mainLoop

.fill:
	move.w  #(PLANE_SIZE/2)-1,d0
.fillLoop:
	move.w  d1,(a0)+
	dbra    d0,.fillLoop
	rts

sectionPtrTable:
	dc.l    sec0,bufA,bufA
	dc.l    sec1,bufC,bufA
	dc.l    sec2,bufA,bufC
	dc.l    sec3,bufC,bufC
	dc.l    sec4,bufB,bufA
	dc.l    sec5,bufD,bufA
	dc.l    sec6,bufB,bufC
	dc.l    sec7,bufD,bufC
	dc.l    sec8,bufA,bufB
	dc.l    sec9,bufC,bufB
	dc.l    sec10,bufA,bufD
	dc.l    sec11,bufC,bufD
	dc.l    sec12,bufB,bufB
	dc.l    sec13,bufD,bufB
	dc.l    sec14,bufB,bufD
	dc.l    sec15,bufD,bufD
	dc.l    0

copper:
	dc.w    BPLCON0,$0200
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    DDFSTRT,DDF_START
	dc.w    DDFSTOP,DDF_STOP
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000

	; Four line bar above section 0 -- marks the TOP of the picture
	dc.w    $3001,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $3401,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 0: pixels alternate 0,0
sec0:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $3401,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $3D01,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $3E01,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 1: pixels alternate 1,0
sec1:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $3E01,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $4701,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $4801,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 2: pixels alternate 2,0
sec2:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $4801,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $5101,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $5201,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 3: pixels alternate 3,0
sec3:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $5201,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $5B01,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $5C01,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 4: pixels alternate 0,1
sec4:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $5C01,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $6501,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $6601,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 5: pixels alternate 1,1
sec5:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $6601,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $6F01,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $7001,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 6: pixels alternate 2,1
sec6:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $7001,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $7901,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $7A01,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 7: pixels alternate 3,1
sec7:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $7A01,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $8301,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $8401,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 8: pixels alternate 0,2
sec8:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $8401,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $8D01,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $8E01,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 9: pixels alternate 1,2
sec9:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $8E01,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $9701,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $9801,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 10: pixels alternate 2,2
sec10:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $9801,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $A101,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $A201,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 11: pixels alternate 3,2
sec11:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $A201,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $AB01,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $AC01,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 12: pixels alternate 0,3
sec12:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $AC01,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $B501,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $B601,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 13: pixels alternate 1,3
sec13:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $B601,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $BF01,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $C001,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 14: pixels alternate 2,3
sec14:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $C001,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres
	dc.w    $C901,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $CA01,$FFFE
	dc.w    COLOR00,NO_COLOR

	; Section 15: pixels alternate 3,3
sec15:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    $CA01,$FFFE
	dc.w    BPLCON0,BPLCON0_VAL     ; SHRES_BPU bitplanes, shres

	; Two line bar below section 15 -- marks the BOTTOM
	dc.w    $D301,$FFFE
	dc.w    BPLCON0,$0200
	dc.w    COLOR00,BAR_COLOR
	dc.w    $D501,$FFFE
	dc.w    COLOR00,$0000

	dc.l    $fffffffe

	cnop    0,8
bufA: ds.b PLANE_SIZE
	cnop    0,8
bufB: ds.b PLANE_SIZE
	cnop    0,8
bufC: ds.b PLANE_SIZE
	cnop    0,8
bufD: ds.b PLANE_SIZE
