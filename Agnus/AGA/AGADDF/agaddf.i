;
; This file is included by agaddf1.s, agaddf2.s, ... Each of those defines
; DDF_START, DDF_STOP and FMODE and then includes this body.
;
; agaddf.i -- DDFSTRT / DDFSTOP behaviour on AGA.
;
; The AGA counterpart of the Agnus/DDF/DDF suite. Those tests hold DDFSTRT
; fixed within a frame, sweep DDFSTOP across the subsections, and draw two
; sections: one lores, one hires, both with a single bitplane. This suite
; generalises all three of those axes:
;
;   three sections instead of two    lores, hires and super hires
;   eight subsections instead of a   1, 2, 3 ... 8 bitplanes
;     DDFSTOP sweep
;   two Copper rulers instead of one one between each pair of sections
;
; and lifts DDFSTRT, DDFSTOP and FMODE out into the wrapper, so a single
; frame answers "where does the data start and stop" for one (DDFSTRT,
; DDFSTOP, FMODE) triple across every resolution and every bitplane count
; the chipset offers.
;
;
; READING THE PICTURE
; -------------------
;
; BRDRBLNK (BPLCON3 bit 5) is set for the whole frame apart from the two
; ruler lines, so the border is forced to pure black, and COLOR00 -- the
; colour of the display window wherever the bitplanes have not delivered
; data -- is dark grey. The ruler lines are the exception because they have
; no bitplanes enabled, and with BPU = 0 the whole rasterline is border, so
; a blanked border would swallow the ruler entirely; see the note there and
; the Denise/Registers/BPLCON3/brdrblnk2 test. ECSENA (BPLCON0 bit 0) is set
; throughout, because BRDRBLNK does nothing without it. Every rasterline
; therefore reads as four zones:
;
;   black         border, up to the first bitplane pixel
;   a flat hue    the bitplane data
;   dark grey     data finished, window still open
;   black         border, right of DIWSTOP
;
; The picture is asymmetric on purpose. DIWSTRT does not open the display
; window on its own: the window opens at the first BPL1DAT write and stays
; open until DIWSTOP, so there is no grey zone on the left while the one on
; the right is real. Denise/Sprites/clip/diwclip measures that directly.
;
; The two inner edges are what this suite measures. The left one is the
; first pixel DDFSTRT produces, the right one is the last pixel DDFSTOP
; allows, and both are read against the Copper rulers. Without BRDRBLNK the
; outer pair of edges would be invisible, because COLOR00 would paint the
; border as well and the dark grey zones would merge into it.
;
; The display window is deliberately wider than any data DDF can produce,
; so DIW never clips the picture and every edge on screen belongs to DDF.
;
;
; THE BITPLANE DATA
; -----------------
;
; All eight bitplanes point at ONE buffer filled with the $AA pattern the
; original ddf tests use, so every plane carries identical bits and the
; colour index alternates between 0 and 2^N-1 with N planes enabled. Each
; subsection is therefore a fine vertical comb in its own colour, and the
; eight subsections of a section run through a blue to magenta ramp:
;
;   1 plane  index   1  $66F        5 planes index  31  $E6F
;   2 planes index   3  $86F        6 planes index  63  $F6F
;   3 planes index   7  $A6F        7 planes index 127  $F6C
;   4 planes index  15  $C6F        8 planes index 255  $F69
;
; The comb's dark pixels are index 0, which is COLOR00 -- the same colour
; as the zone where no data has arrived. That is exactly how the original
; suite behaves, and it is what makes the subsection markers work: because
; index 0 occurs right across the data, a marker written to COLOR00 shows
; through the comb and spans the full width of the window rather than only
; the gaps at either end.
;
; The pattern repeats every single word, so BPLxMOD stays zero, pointer
; drift cannot shear anything, and no fetch-count arithmetic has to be
; right for the picture to be readable. The pointers are reloaded at the
; start of every subsection anyway, which bounds the drift to six lines.
;
; KILLEHB (BPLCON2 bit 9) is set for the whole frame. Six enabled bitplanes
; with neither HAM nor DPF set is exactly the condition for Extra
; Half-Brite, so without it the six plane subsection would draw index 63 as
; a halved COLOR31 instead of COLOR63 and would come out a different colour
; from the one the palette says. That is a genuine AGA behaviour, but it
; belongs to Denise/Registers/BPLCON2/killehb, not here.
;
;
; WHAT TO EXPECT AT LOW FMODE
; ---------------------------
;
; The subsections are not all expected to draw. A fetch unit has eight
; slots, and the number of planes that fit depends on how long one word
; lasts in the current resolution:
;
;   FMODE 0     lores 8   hires 4   super hires 2
;   FMODE 1, 2  lores 8   hires 8   super hires 4
;   FMODE 3     lores 8   hires 8   super hires 8
;
; Subsections above that limit fetch nothing and stay dark grey across
; the full width of the window. That is the correct result, not a failure,
; and it is why the suite is worth running at all four FMODE values.


FMODEREG            equ $1FC           ; AGA only
BPLCON3             equ $106           ; ECS and AGA
BPLCON4             equ $10C           ; AGA only
BPL7PTH             equ $F8            ; AGA only
BPL7PTL             equ $FA            ; AGA only
BPL8PTH             equ $FC            ; AGA only
BPL8PTL             equ $FE            ; AGA only

BRDRBLNK            equ $0020          ; BPLCON3 bit 5, border forced black

; ECSENA (bit 0) must be set for BRDRBLNK to work, so it is part of every
; BPLCON0 value below, the plane-less one included. Note that eight planes
; are selected by BPU3 in bit 4, not by bits 14-12.
BPLCON0_OFF         equ $0201
LORES_BITS          equ $0201
HIRES_BITS          equ $8201
SHRES_BITS          equ $0241          ; bit 6 alone selects super hires

; The display window is wider than anything DDF can produce, so every edge
; in the picture belongs to DDF rather than to DIW.
DIW_START           equ $2C71
DIW_STOP            equ $2CC1

DARKGREY            equ $444           ; window, before and after the data
MARKER              equ $600           ; first line of each subsection
BLACK               equ $000           ; COLOR00 around the Copper rulers,
                                       ; where the border is not blanked

; The stripe colours, a blue to magenta ramp in the spirit of the original
; ddf tests, which cycle COLOR01 through $66F, $B6F, $F6F and $F6B.
BAND1               equ $66F           ; index   1, 1 plane
BAND2               equ $86F           ; index   3, 2 planes
BAND3               equ $A6F           ; index   7, 3 planes
BAND4               equ $C6F           ; index  15, 4 planes
BAND5               equ $E6F           ; index  31, 5 planes
BAND6               equ $F6F           ; index  63, 6 planes
BAND7               equ $F6C           ; index 127, 7 planes
BAND8               equ $F69           ; index 255, 8 planes

BUF_SIZE            equ 16384

MAIN:
	lea     CUSTOM,a1

	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #BPLCON0_OFF,BPLCON0(a1)

	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	move.w  #FMODE,FMODEREG(a1)

	; One buffer, shared by all eight bitplanes, filled with the $AA
	; pattern the original ddf tests use. Every plane therefore carries
	; identical bits and the colour index alternates between 0 and 2^N-1.
	lea     planeData,a0
	move.w  #(BUF_SIZE/2)-1,d0
.fillStripes: move.w  #$AAAA,(a0)+
	dbra    d0,.fillStripes

	; Clear all 256 AGA colour registers. Only nine are used, but an
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

	; The eight band colours. Indices 1, 3, 7, 15 and 31 all live in bank
	; 0; 63, 127 and 255 are register 31 of banks 1, 3 and 7. Every
	; register is written twice, LOCT=0 then LOCT=1, so both nibbles of
	; each channel are filled and the result is a true $FF rather than $F0.
	move.w  #$E000,BPLCON3(a1)      ; bank 7, LOCT=0
	move.w  #BAND8,COLOR31(a1)      ; index 255
	move.w  #$E200,BPLCON3(a1)      ; bank 7, LOCT=1
	move.w  #BAND8,COLOR31(a1)

	move.w  #$6000,BPLCON3(a1)      ; bank 3, LOCT=0
	move.w  #BAND7,COLOR31(a1)      ; index 127
	move.w  #$6200,BPLCON3(a1)      ; bank 3, LOCT=1
	move.w  #BAND7,COLOR31(a1)

	move.w  #$2000,BPLCON3(a1)      ; bank 1, LOCT=0
	move.w  #BAND6,COLOR31(a1)      ; index 63
	move.w  #$2200,BPLCON3(a1)      ; bank 1, LOCT=1
	move.w  #BAND6,COLOR31(a1)

	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT=0
	move.w  #DARKGREY,COLOR00(a1)
	move.w  #BAND1,COLOR01(a1)
	move.w  #BAND2,COLOR03(a1)
	move.w  #BAND3,COLOR07(a1)
	move.w  #BAND4,COLOR15(a1)
	move.w  #BAND5,COLOR31(a1)
	move.w  #$0200,BPLCON3(a1)      ; bank 0, LOCT=1
	move.w  #DARKGREY,COLOR00(a1)
	move.w  #BAND1,COLOR01(a1)
	move.w  #BAND2,COLOR03(a1)
	move.w  #BAND3,COLOR07(a1)
	move.w  #BAND4,COLOR15(a1)
	move.w  #BAND5,COLOR31(a1)

	; Leave BRDRBLNK set. The Copper only touches BPLCON3 again on the two
	; ruler lines, where the border has to be unblanked for the stripes to
	; be visible at all; everywhere else the border stays black.
	move.w  #BRDRBLNK,BPLCON3(a1)

	; Patch the buffer address into every BPLxPT pair in the Copper list.
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
; All eight planes share one buffer. WAIT instructions are skipped, so the
; scan cannot mistake a wait value for a register.
patchPointers:
	lea     copper(pc),a2
	move.l  #planeData,d3
	move.l  d3,d4
	swap    d4
.loop:
	cmpi.l  #$FFFFFFFE,(a2)
	beq.s   .done
	move.w  (a2)+,d1
	btst    #0,d1                   ; bit 0 set -> this is a WAIT
	bne.s   .skip
	cmpi.w  #BPL1PTH,d1
	blt.s   .skip
	cmpi.w  #BPL8PTL,d1
	bgt.s   .skip
	btst    #1,d1                   ; PTH pairs are on 4-byte boundaries
	bne.s   .lo
.hi:
	move.w  d4,(a2)+
	bra.s   .loop
.lo:
	move.w  d3,(a2)+
	bra.s   .loop
.skip:
	addq.l  #2,a2
	bra.s   .loop
.done:
	rts

copper:
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0224           ; KILLEHB: see the note in the header
	dc.w    BPLCON4,$0011           ; AGA defaults
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    DDFSTRT,DDF_START
	dc.w    DDFSTOP,DDF_STOP
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000

	;
	; LORES section, 8 bitplanes per subsection
	;
	;
	; LORES, 1 bitplane (lines $30-$39)
	;
	dc.w    $3001,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(1<<12)|LORES_BITS
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
	dc.w    $30E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; LORES, 2 bitplanes (lines $3A-$43)
	;
	dc.w    $3A01,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(2<<12)|LORES_BITS
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
	dc.w    $3AE1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; LORES, 3 bitplanes (lines $44-$4D)
	;
	dc.w    $4401,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(3<<12)|LORES_BITS
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
	dc.w    $44E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; LORES, 4 bitplanes (lines $4E-$57)
	;
	dc.w    $4E01,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(4<<12)|LORES_BITS
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
	dc.w    $4EE1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; LORES, 5 bitplanes (lines $58-$61)
	;
	dc.w    $5801,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(5<<12)|LORES_BITS
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
	dc.w    $58E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; LORES, 6 bitplanes (lines $62-$6B)
	;
	dc.w    $6201,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(6<<12)|LORES_BITS
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
	dc.w    $62E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; LORES, 7 bitplanes (lines $6C-$75)
	;
	dc.w    $6C01,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(7<<12)|LORES_BITS
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
	dc.w    $6CE1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; LORES, 8 bitplanes (lines $76-$7F)
	;
	dc.w    $7601,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,LORES_BITS|$0010
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
	dc.w    $76E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; Copper timing ruler (from Agnus/DDF/ddf1), bitplanes disabled.
	; One stripe line, as in the original suite.
	;
	; BRDRBLNK is switched OFF for these two lines and set again
	; afterwards. With BPU = 0 the whole rasterline is border -- the
	; display window never opens, so there is no window for COLOR00 to
	; reach -- and a blanked border swallows the ruler completely. The
	; stripes are drawn on real hardware only while BRDRBLNK is clear.
	; See Denise/Registers/BPLCON3/brdrblnk2, which isolates exactly this behaviour.
	;
	; The bank is re-asserted in the same write. Nothing else in this
	; list moves BPLCON3, but the ruler goes to COLOR00 and a stray
	; bank would send it to register 32, 64, ... instead of register 0.
	;
	dc.w    $8001,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000           ; bank 0, LOCT=0, BRDRBLNK off
	; With the border unblanked, COLOR00 reaches the full width of
	; these lines, and the dark grey it normally holds would draw a
	; grey band right across the ruler's surroundings. Black is what
	; the blanked border either side of the ruler shows anyway, so
	; setting it by hand keeps the seam invisible.
	dc.w    COLOR00,BLACK
	dc.w    $8139,$FFFE
	dc.w    COLOR00,$F00
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
	dc.w    COLOR00,$00A
	dc.w    $81E1,$FFFE
	dc.w    COLOR00,BLACK
	dc.w    BPLCON3,BRDRBLNK        ; border blanked again
	;
	; HIRES section, 8 bitplanes per subsection
	;
	;
	; HIRES, 1 bitplane (lines $84-$8D)
	;
	dc.w    $8401,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(1<<12)|HIRES_BITS
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
	dc.w    $84E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; HIRES, 2 bitplanes (lines $8E-$97)
	;
	dc.w    $8E01,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(2<<12)|HIRES_BITS
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
	dc.w    $8EE1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; HIRES, 3 bitplanes (lines $98-$A1)
	;
	dc.w    $9801,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(3<<12)|HIRES_BITS
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
	dc.w    $98E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; HIRES, 4 bitplanes (lines $A2-$AB)
	;
	dc.w    $A201,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(4<<12)|HIRES_BITS
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
	dc.w    $A2E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; HIRES, 5 bitplanes (lines $AC-$B5)
	;
	dc.w    $AC01,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(5<<12)|HIRES_BITS
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
	dc.w    $ACE1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; HIRES, 6 bitplanes (lines $B6-$BF)
	;
	dc.w    $B601,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(6<<12)|HIRES_BITS
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
	dc.w    $B6E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; HIRES, 7 bitplanes (lines $C0-$C9)
	;
	dc.w    $C001,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(7<<12)|HIRES_BITS
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
	dc.w    $C0E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; HIRES, 8 bitplanes (lines $CA-$D3)
	;
	dc.w    $CA01,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,HIRES_BITS|$0010
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
	dc.w    $CAE1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; Copper timing ruler (from Agnus/DDF/ddf1), bitplanes disabled.
	; One stripe line, as in the original suite.
	;
	; BRDRBLNK is switched OFF for these two lines and set again
	; afterwards. With BPU = 0 the whole rasterline is border -- the
	; display window never opens, so there is no window for COLOR00 to
	; reach -- and a blanked border swallows the ruler completely. The
	; stripes are drawn on real hardware only while BRDRBLNK is clear.
	; See Denise/Registers/BPLCON3/brdrblnk2, which isolates exactly this behaviour.
	;
	; The bank is re-asserted in the same write. Nothing else in this
	; list moves BPLCON3, but the ruler goes to COLOR00 and a stray
	; bank would send it to register 32, 64, ... instead of register 0.
	;
	dc.w    $D401,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000           ; bank 0, LOCT=0, BRDRBLNK off
	; With the border unblanked, COLOR00 reaches the full width of
	; these lines, and the dark grey it normally holds would draw a
	; grey band right across the ruler's surroundings. Black is what
	; the blanked border either side of the ruler shows anyway, so
	; setting it by hand keeps the seam invisible.
	dc.w    COLOR00,BLACK
	dc.w    $D539,$FFFE
	dc.w    COLOR00,$F00
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
	dc.w    COLOR00,$00A
	dc.w    $D5E1,$FFFE
	dc.w    COLOR00,BLACK
	dc.w    BPLCON3,BRDRBLNK        ; border blanked again
	;
	; SHRES section, 8 bitplanes per subsection
	;
	;
	; SHRES, 1 bitplane (lines $D8-$E1)
	;
	dc.w    $D801,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(1<<12)|SHRES_BITS
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
	dc.w    $D8E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; SHRES, 2 bitplanes (lines $E2-$EB)
	;
	dc.w    $E201,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(2<<12)|SHRES_BITS
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
	dc.w    $E2E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; SHRES, 3 bitplanes (lines $EC-$F5)
	;
	dc.w    $EC01,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(3<<12)|SHRES_BITS
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
	dc.w    $ECE1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; SHRES, 4 bitplanes (lines $F6-$FF)
	;
	dc.w    $F601,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(4<<12)|SHRES_BITS
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
	dc.w    $F6E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; SHRES, 5 bitplanes (lines $100-$109)
	;
	; Past line 255: wait out the vertical boundary once, after
	; which a WAIT on the low byte alone matches lines 256 and up.
	dc.w    $FFDF,$FFFE
	dc.w    $0001,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(5<<12)|SHRES_BITS
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
	dc.w    $00E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; SHRES, 6 bitplanes (lines $10A-$113)
	;
	dc.w    $0A01,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(6<<12)|SHRES_BITS
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
	dc.w    $0AE1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; SHRES, 7 bitplanes (lines $114-$11D)
	;
	dc.w    $1401,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,(7<<12)|SHRES_BITS
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
	dc.w    $14E1,$FFFE
	dc.w    COLOR00,DARKGREY
	;
	; SHRES, 8 bitplanes (lines $11E-$127)
	;
	dc.w    $1E01,$FFFE
	dc.w    COLOR00,MARKER
	dc.w    BPLCON0,SHRES_BITS|$0010
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
	dc.w    $1EE1,$FFFE
	dc.w    COLOR00,DARKGREY

	;
	; Done -- shut the display down again.
	;
	dc.w    $2801,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	dc.l    $fffffffe

	cnop    0,8                     ; wide fetches want aligned pointers
planeData:  ds.b BUF_SIZE
