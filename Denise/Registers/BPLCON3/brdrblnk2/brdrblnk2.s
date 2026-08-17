; brdrblnk2.s -- BRDRBLNK with the bitplanes switched off.
;
; A companion to brdrblnk1. That test always has at least one bitplane
; enabled, so the display window is a real window and BRDRBLNK only ever
; touches the area outside it. This test removes the bitplanes entirely and
; asks a different question:
;
;   with BPU = 0, is the whole rasterline border?
;
; The suspicion is that it is. Nothing is fetched, nothing is displayed, and
; the display window never opens, so the area DIWSTRT and DIWSTOP delimit is
; border like everything else -- in which case BRDRBLNK blanks it too and a
; plane-less line is uniformly black no matter what COLOR00 holds.
;
; That is not an academic point. A Copper colour ruler is normally drawn on
; a plane-less line, precisely so that the Copper keeps every DMA slot and
; the stripe train runs undisturbed. If BPU = 0 means "all border", then a
; ruler drawn with BRDRBLNK set is invisible -- which is exactly what the
; Agnus/DDF/AGADDF suite ran into on real hardware.
;
;
; HOW THE SCREEN IS BUILT
; -----------------------
;
; No bitplanes are ever enabled and bitplane DMA is never switched on, so
; COLOR00 is the only colour register the machine can reach and every pixel
; on screen is whatever COLOR00 held at that moment -- unless BRDRBLNK
; blanks it to black.
;
; DIWSTRT and DIWSTOP are nevertheless set to ordinary values ($2C71 /
; $2CC1). They are the control. If a plane-less line is entirely border,
; BRDRBLNK blackens the full width and the display window leaves no trace.
; If instead the window still counts as window, the middle of the line
; survives in COLOR00 and appears as a coloured band with black on both
; sides. The two outcomes cannot be mistaken for one another.
;
; ECSENA (BPLCON0 bit 0) is set throughout, because BRDRBLNK does nothing
; without it.
;
;
; THE SIXTEEN BLOCKS
; ------------------
;
; The frame is divided into sixteen blocks of twelve lines, running from
; line $30 to line $EF, and every block has the same four-part shape:
;
;   line +0    BRDRBLNK clear, COLOR00 = dark blue     -- plain background
;   line +1    the Copper ruler, with a BRDRBLNK toggle in it
;   line +2,3  BRDRBLNK set for the whole line         -- expect solid black
;   line +4..  BRDRBLNK clear again                    -- background returns
;
; Lines +2 and +3 are the whole-line control: they answer the question above
; on their own, without any timing subtlety. If a plane-less line is all
; border, they are two solid black bars; if not, they show a dark blue band
; where the display window is.
;
; Line +1 is the measurement. It carries the usual forty back-to-back
; COLOR00 moves of the Agnus/DDF/ddf1 ruler, one move per four colour
; clocks, but with the stripes alternating YELLOW and RED instead of white
; and black -- black is what BRDRBLNK paints, and a ruler that already
; contains black could not be told apart from a blanked one. The first
; stripe is white and the last is green, marking where the scale begins and
; ends.
;
; One move of that train is replaced by a write of BRDRBLNK to BPLCON3, and
; that move sits two stripes further right in each successive block:
;
;   block 0   stripe 2      block 8    stripe 18
;   block 1   stripe 4      ...
;   ...                     block 15   stripe 32
;
; Replacing a move rather than inserting one is deliberate: the train stays
; exactly forty moves long and every stripe keeps its position, so all
; sixteen rulers share one scale. The replaced stripe simply keeps the
; previous colour for twice as long, and that double-width stripe is itself
; the marker for where the toggle happened.
;
; Every ruler then clears BRDRBLNK again at stripe 36, in the same
; substituting way, so the last few stripes and the green end marker come
; back on every line. That fixed right-hand edge is what proves the effect
; is reversible mid-line and not a one-way latch, and it gives each ruler a
; second landmark to measure the moving edge against.
;
;
; WHAT TO EXPECT
; --------------
;
; If the suspicion is right, each ruler reads: coloured stripes from the
; white marker up to the toggle, black from there to stripe 36, then
; coloured stripes again to the green marker. The black stretch grows by two
; stripes per block, so the sixteen rulers form a staircase down the screen,
; and lines +2 and +3 of every block are solid black.
;
; If instead a plane-less display window is not border, the ruler stripes
; survive across the window and only the two thin outer strips go black.

	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

FMODEREG            equ $1FC           ; AGA only
BPLCON3             equ $106           ; ECS and AGA
BPLCON4             equ $10C           ; AGA only

BRDRBLNK_OFF        equ $0000          ; border takes COLOR00
BRDRBLNK_ON         equ $0020          ; border forced to black (bit 5)

; No bitplanes anywhere in this test, but ECSENA (bit 0) is still needed for
; BRDRBLNK to have any effect at all.
BPLCON0_OFF         equ $0201          ; no planes, ECSENA

DIW_START           equ $2C71          ; ordinary window; see the note above
DIW_STOP            equ $2CC1

BACKGND             equ $008           ; dark blue, unmistakably not black
WHITE               equ $FFF           ; ruler start marker
GREEN               equ $0F0           ; ruler end marker
YELLOW              equ $FF0           ; ruler stripes
RED                 equ $F00

MAIN:
	lea     CUSTOM,a1

	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #BPLCON0_OFF,BPLCON0(a1)

	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	move.w  #$0000,FMODEREG(a1)

	; Clear all 256 AGA colour registers so nothing left behind by a
	; previous program can be mistaken for a result. Only COLOR00 is ever
	; used here, but the Copper writes it constantly and a stray colour
	; bank would send those writes to register 32, 64, ... instead; with
	; every register black, such a slip shows up as a black screen rather
	; than as a plausible looking picture. Banks run 7 down to 0 so bank 0
	; is written last.
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

	; COLOR00 dark blue, written twice, LOCT=0 then LOCT=1, so both
	; nibbles of every channel are filled.
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT=0
	move.w  #BACKGND,COLOR00(a1)
	move.w  #$0200,BPLCON3(a1)      ; bank 0, LOCT=1
	move.w  #BACKGND,COLOR00(a1)
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT=0, BRDRBLNK clear

	; Install Copper list and enable DMA. Bitplane DMA is deliberately
	; left off: there are no bitplanes and no buffer in this test.
	lea     copper(pc),a0
	move.l  a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	move.w  #$8080,DMACON(a1)   ; Copper DMA
	move.w  #$8200,DMACON(a1)   ; DMAEN

.mainLoop:
	bra.b   .mainLoop

copper:
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    BPLCON4,$0011           ; AGA defaults
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    DDFSTRT,$0038
	dc.w    DDFSTOP,$00C8


	;
	; Block 0, lines $30-$3B. BRDRBLNK is set at ruler stripe 2
	; and cleared again at stripe 36.
	;
	dc.w    $3001,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $3139,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 2
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $3201,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $3401,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 1, lines $3C-$47. BRDRBLNK is set at ruler stripe 4
	; and cleared again at stripe 36.
	;
	dc.w    $3C01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $3D39,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 4
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $3E01,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $4001,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 2, lines $48-$53. BRDRBLNK is set at ruler stripe 6
	; and cleared again at stripe 36.
	;
	dc.w    $4801,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $4939,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 6
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $4A01,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $4C01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 3, lines $54-$5F. BRDRBLNK is set at ruler stripe 8
	; and cleared again at stripe 36.
	;
	dc.w    $5401,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $5539,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 8
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $5601,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $5801,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 4, lines $60-$6B. BRDRBLNK is set at ruler stripe 10
	; and cleared again at stripe 36.
	;
	dc.w    $6001,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $6139,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 10
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $6201,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $6401,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 5, lines $6C-$77. BRDRBLNK is set at ruler stripe 12
	; and cleared again at stripe 36.
	;
	dc.w    $6C01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $6D39,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 12
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $6E01,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $7001,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 6, lines $78-$83. BRDRBLNK is set at ruler stripe 14
	; and cleared again at stripe 36.
	;
	dc.w    $7801,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $7939,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 14
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $7A01,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $7C01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 7, lines $84-$8F. BRDRBLNK is set at ruler stripe 16
	; and cleared again at stripe 36.
	;
	dc.w    $8401,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $8539,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 16
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $8601,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $8801,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 8, lines $90-$9B. BRDRBLNK is set at ruler stripe 18
	; and cleared again at stripe 36.
	;
	dc.w    $9001,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $9139,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 18
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $9201,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $9401,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 9, lines $9C-$A7. BRDRBLNK is set at ruler stripe 20
	; and cleared again at stripe 36.
	;
	dc.w    $9C01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $9D39,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 20
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $9E01,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $A001,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 10, lines $A8-$B3. BRDRBLNK is set at ruler stripe 22
	; and cleared again at stripe 36.
	;
	dc.w    $A801,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $A939,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 22
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $AA01,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $AC01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 11, lines $B4-$BF. BRDRBLNK is set at ruler stripe 24
	; and cleared again at stripe 36.
	;
	dc.w    $B401,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $B539,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 24
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $B601,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $B801,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 12, lines $C0-$CB. BRDRBLNK is set at ruler stripe 26
	; and cleared again at stripe 36.
	;
	dc.w    $C001,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $C139,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 26
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $C201,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $C401,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 13, lines $CC-$D7. BRDRBLNK is set at ruler stripe 28
	; and cleared again at stripe 36.
	;
	dc.w    $CC01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $CD39,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 28
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $CE01,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $D001,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 14, lines $D8-$E3. BRDRBLNK is set at ruler stripe 30
	; and cleared again at stripe 36.
	;
	dc.w    $D801,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $D939,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 30
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $DA01,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $DC01,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Block 15, lines $E4-$EF. BRDRBLNK is set at ruler stripe 32
	; and cleared again at stripe 36.
	;
	dc.w    $E401,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,BACKGND
	dc.w    $E539,$FFFE
	dc.w    COLOR00,WHITE
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_ON      ; stripe 32
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,YELLOW
	dc.w    BPLCON3,BRDRBLNK_OFF     ; stripe 36
	dc.w    COLOR00,YELLOW
	dc.w    COLOR00,RED
	dc.w    COLOR00,GREEN
	dc.w    $E601,$FFFE
	dc.w    COLOR00,BACKGND         ; the ruler left green here
	dc.w    BPLCON3,BRDRBLNK_ON     ; expect two solid black lines
	dc.w    $E801,$FFFE
	dc.w    BPLCON3,BRDRBLNK_OFF

	;
	; Done -- shut the display down again.
	;
	dc.w    $F001,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,BRDRBLNK_OFF
	dc.w    COLOR00,$0000

	dc.l    $fffffffe
