; agasprites.i -- shared body for the Agnus/AGA agasprites tests.
;
; The including file must have already included registers.i,
; hardware/dmabits.i, hardware/intbits.i and ministartup.s (see
; simple1/simple1.s for the exact boilerplate) -- this file has no includes
; of its own so it stays agnostic of the including file's directory depth.
;
; The sprite artwork is the Pacman and the ghost from
; Denise/Sprites/sprdrop/sprdrop_cop.i, unchanged.
;
;
; WHAT IS UNDER TEST
; ------------------
;
; AGA widens a sprite from 16 pixels to 32 or 64, selected by FMODE bits 3
; and 2, and can scan double it vertically, selected by FMODE bit 15
; together with bit 7 of the sprite's own POS word:
;
;     FMODE bits 3-2    words per DMA read    sprite width
;         00                   1                 16 px
;         01, 10               2                 32 px
;         11                   4                 64 px
;
; A sprite performs exactly two DMA reads per rasterline (data A and data
; B), each of that width, and the pointer advances by the full width on
; every read. So a 64 bit sprite consumes eight words per line rather than
; two, and the leftmost 16 pixels come from the first word.
;
; The frame shows six sections, one per combination:
;
;     section 1   16 px                sprite 0
;     section 2   32 px                sprite 1
;     section 3   64 px                sprite 2
;     section 4   16 px, scan doubled  sprite 3
;     section 5   32 px, scan doubled  sprite 4
;     section 6   64 px, scan doubled  sprite 5
;
; Each section gets its own sprite channel, so no sprite is ever reused and
; there is no pointer chaining between sections. The copper switches FMODE
; on the first line of each section, before that section's sprite starts.
;
;
; READING THE RESULT
; ------------------
;
; The wide sprites are not a scaled up Pacman but a row of figures packed
; into one sprite, alternating Pacman and ghost:
;
;     16 px    P
;     32 px    P G
;     64 px    P G P G
;
; That makes the result readable at a glance and unambiguous about word
; order: the leftmost figure is always the Pacman from word 0, and if the
; extension words ever arrived out of order the P G P G rhythm would break
; rather than merely widening. A 32 or 64 bit sprite that comes out as a
; lone Pacman means the extension words never reached Denise at all.
;
; The three scan doubled sections use exactly the same 16 lines of data as
; the three above them, so they must come out twice as tall and otherwise
; identical. Scan doubling works by suppressing the data fetch on every
; second line, the parity being anchored at VSTART, so the first line of
; the sprite is the first line of a doubled pair.
;
; All six sprites are given the same HSTART, so they should line up in one
; column. A copper ruler sits on the first line of every section: the same
; stripe train as the Agnus/DDF/ddf1 test, one MOVE per 4 color clocks and
; therefore one stripe per 8 lores pixels, starting where the playfield
; starts. Bitplane DMA is switched off on those lines so the copper keeps
; every slot and the stripes stay evenly spaced. Count stripes from the red
; one to read a sprite's absolute position off the screen.
;
;
; THE TWO AWKWARD BITS
; --------------------
;
; POS bit 7 does double duty. Normally it is bit 8 of HSTART, worth 256;
; with FMODE's SSCAN2 set it instead means "scan double this sprite". The
; horizontal comparator does not merely subtract that bit, it stops
; evaluating it -- which shortens the comparator by one bit, so the sprite
; is matched TWICE per line, 256 lores pixels apart. Sections 4 to 6
; therefore show a second copy of each sprite 256 pixels to the right of
; the first, and that is correct behaviour rather than a fault in the test.
;
; Two consequences worth keeping in mind when reading the source:
;
;   - the second match is driven by FMODE bit 15 alone, not by the
;     per-sprite POS bit, so in a scan doubled section EVERY armed sprite
;     doubles horizontally, whether or not it is doubled vertically;
;
;   - because the bit is ignored rather than subtracted, $50 and $D0 in the
;     low byte of POS put the sprite in exactly the same two columns. The
;     doubled sections carry $D0 purely to set the scan doubling flag; the
;     extra 256 is not a position correction. HSTART is kept below 256 all
;     the same, since bit 8 of it can no longer be used for anything.
;
; The control words of every sprite are fetched on one single line (25 on
; PAL, where the vertical trigger of all eight sprites is reset), so they
; are all fetched at whatever FMODE happens to be set at that moment, not
; at the FMODE of the section the sprite belongs to. The copper therefore
; sets the 64 bit width at the top of the list, and EVERY control block
; below is laid out with the 4 word stride -- POS followed by three pad
; words, CTL followed by three pad words -- regardless of how wide the data
; that follows it is. The terminating control block at the end of a sprite
; is different: it is read on the sprite's VSTOP line, inside its own
; section, so it uses that section's stride.

BPLCON3             equ $106          ; AGA only
BPLCON4             equ $10C          ; AGA only
FMODEREG            equ $1FC          ; AGA only

	IFND SPR_HSTART
SPR_HSTART          equ 160           ; must stay below 256, see above
	ENDC

DDF_START           equ $0038
DDF_STOP            equ $00D0

; Vertical: the sections run from line $30 to $FB, so the window has to stay
; open past line 251. DIWSTOP's vstop carries an implicit bit 8 that is the
; complement of bit 7, so $2C means line 300 while sprdrop's $F4 would mean
; 244 and cut the last two sections off.
DIW_START           equ $2C81
DIW_STOP            equ $2CC1

BPLCON0_ON          equ $1200         ; 1 bitplane, lores
BPLCON0_OFF         equ $0200

PLANE_SIZE          equ 16384


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

	; A solid playfield, purely so the display window is visible as a
	; rectangle and the sprites can be seen to sit inside it. One bitplane,
	; every bit set, so COLOR01 fills the window and COLOR00 the border.
	; Sprites are not drawn over the border unless BPLCON3's BRDSPRT is set,
	; which this test deliberately does not rely on.
	lea     bitplane1,a0
	move.w  #(PLANE_SIZE/2)-1,d0
.fill:
	move.w  #$FFFF,(a0)+
	dbra    d0,.fill

	; Colours. The sprite palette is the one from sprdrop, repeated for all
	; three sprite pairs so that a difference between two sections is never
	; a difference in colour.
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT = 0
	move.w  #$0000,COLOR00(a1)      ; border
	move.w  #$0224,COLOR01(a1)      ; playfield
	move.w  #$0FF8,COLOR17(a1)
	move.w  #$0444,COLOR18(a1)
	move.w  #$0F00,COLOR19(a1)
	move.w  #$0FF8,COLOR21(a1)
	move.w  #$0444,COLOR22(a1)
	move.w  #$0F00,COLOR23(a1)
	move.w  #$0FF8,COLOR25(a1)
	move.w  #$0444,COLOR26(a1)
	move.w  #$0F00,COLOR27(a1)

	; Patch the pointers into the copper list. Every entry of ptrTable is
	; the address of a MOVE pair followed by the address it should carry.
	; They are reloaded from the copper on every frame because sprite and
	; bitplane DMA leave them advanced past the end of their data.
	lea     ptrTable(pc),a4
.ptLoop:
	move.l  (a4)+,d0
	beq.s   .ptDone
	move.l  d0,a2
	move.l  (a4)+,d3
	move.w  d3,6(a2)                ; low  word -> xxxPTL move
	swap    d3
	move.w  d3,2(a2)                ; high word -> xxxPTH move
	bra.s   .ptLoop
.ptDone:

	; Install Copper list and enable DMA
	lea 	CUSTOM,a1
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	move.w	#$8080,DMACON(a1)   ; Copper DMA
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA
	move.w	#$8020,DMACON(a1)   ; Sprite DMA
	move.w	#$8200,DMACON(a1)   ; DMAEN

.mainLoop:
	bra.b	.mainLoop


ptrTable:
	dc.l    bplPtr,bitplane1
	dc.l    spr16Ptr,spr16Data
	dc.l    spr32Ptr,spr32Data
	dc.l    spr64Ptr,spr64Data
	dc.l    spr16dPtr,spr16dData
	dc.l    spr32dPtr,spr32dData
	dc.l    spr64dPtr,spr64dData
	dc.l    spr6Ptr,nullSprData
	dc.l    spr7Ptr,nullSprData
	dc.l    0


copper:
	; The sprite control words of ALL sprites are fetched on one and the
	; same line (25 on PAL), so they are all fetched at whatever FMODE is
	; set here -- 64 bit, the widest. Every header below is therefore laid
	; out with the 4 word stride, whatever the width of the data that
	; follows it. See the header comment.
	dc.w    FMODEREG,$000C
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024           ; sprites in front of the playfield
	dc.w    BPLCON3,$0000           ; SPRES = 00: sprite pixels track the bitplanes
	dc.w    BPLCON4,$0011           ; AGA defaults (sprite palette base $10)
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    DDFSTRT,DDF_START
	dc.w    DDFSTOP,DDF_STOP
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000

	; Pointers, reloaded every frame because the DMA leaves them advanced.
bplPtr:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
spr16Ptr:
	dc.w    SPR0PTH,$0000
	dc.w    SPR0PTL,$0000
spr32Ptr:
	dc.w    SPR1PTH,$0000
	dc.w    SPR1PTL,$0000
spr64Ptr:
	dc.w    SPR2PTH,$0000
	dc.w    SPR2PTL,$0000
spr16dPtr:
	dc.w    SPR3PTH,$0000
	dc.w    SPR3PTL,$0000
spr32dPtr:
	dc.w    SPR4PTH,$0000
	dc.w    SPR4PTL,$0000
spr64dPtr:
	dc.w    SPR5PTH,$0000
	dc.w    SPR5PTL,$0000
	; Sprites 6 and 7 are not used by any section, but DMACON enables sprite
	; DMA for all eight channels at once and every channel fetches control
	; words on line 25. Left unpointed they would fetch whatever their
	; pointers happened to contain and display random memory, so they are
	; parked on a block whose VSTART and VSTOP are both zero.
spr6Ptr:
	dc.w    SPR6PTH,$0000
	dc.w    SPR6PTL,$0000
spr7Ptr:
	dc.w    SPR7PTH,$0000
	dc.w    SPR7PTL,$0000

	;
	; Section 1 (lines $30-$51): sprite 0, 16 bit sprites
	; FMODE = $0000.  Pacman
	;
	dc.w    $3001,$FFFE
	dc.w    FMODEREG,$0000
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,$000
	dc.w    $3000+DDF_START+1,$FFFE ; ruler starts where the playfield does
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
	dc.w    $3101,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 2 (lines $52-$73): sprite 1, 32 bit sprites
	; FMODE = $0004.  Pacman | Ghost
	;
	dc.w    $5201,$FFFE
	dc.w    FMODEREG,$0004
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,$000
	dc.w    $5200+DDF_START+1,$FFFE ; ruler starts where the playfield does
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
	dc.w    $5301,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 3 (lines $74-$95): sprite 2, 64 bit sprites
	; FMODE = $000C.  Pacman | Ghost | Pacman | Ghost
	;
	dc.w    $7401,$FFFE
	dc.w    FMODEREG,$000C
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,$000
	dc.w    $7400+DDF_START+1,$FFFE ; ruler starts where the playfield does
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
	dc.w    $7501,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 4 (lines $96-$B7): sprite 3, 16 bit sprites, scan doubled
	; FMODE = $8000.  Pacman
	;
	dc.w    $9601,$FFFE
	dc.w    FMODEREG,$8000
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,$000
	dc.w    $9600+DDF_START+1,$FFFE ; ruler starts where the playfield does
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
	dc.w    $9701,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 5 (lines $B8-$D9): sprite 4, 32 bit sprites, scan doubled
	; FMODE = $8004.  Pacman | Ghost
	;
	dc.w    $B801,$FFFE
	dc.w    FMODEREG,$8004
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,$000
	dc.w    $B800+DDF_START+1,$FFFE ; ruler starts where the playfield does
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
	dc.w    $B901,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 6 (lines $DA-$FB): sprite 5, 64 bit sprites, scan doubled
	; FMODE = $800C.  Pacman | Ghost | Pacman | Ghost
	;
	dc.w    $DA01,$FFFE
	dc.w    FMODEREG,$800C
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,$000
	dc.w    $DA00+DDF_START+1,$FFFE ; ruler starts where the playfield does
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
	dc.w    $DB01,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Done -- shut the display down again.
	;
	dc.w    $FC01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    FMODEREG,$0000

	dc.l    $fffffffe


; Sprite data. Each block is:
;   8 words of control block  (POS + 3 pad, CTL + 3 pad -- always the 64
;                              bit stride, see above)
;   16 lines of data          (2, 4 or 8 words each, per this section)
;   one terminating control block at this section's stride, so the sprite
;   stays switched off after VSTOP

	cnop    0,8
spr16Data:
	dc.w    $3150,$0000,$0000,$0000   ; VSTART $31, HSTART 160
	dc.w    $4100,$0000,$0000,$0000   ; VSTOP $41
	dc.w    $03C0,$0000
	dc.w    $0FF0,$0000
	dc.w    $1C78,$0380
	dc.w    $3DFC,$0380
	dc.w    $7DFE,$0380
	dc.w    $7FF8,$0000
	dc.w    $FFE0,$0000
	dc.w    $FF00,$0000
	dc.w    $FF00,$0000
	dc.w    $FFE0,$0000
	dc.w    $7FF8,$0000
	dc.w    $7FFE,$0000
	dc.w    $3FFC,$0000
	dc.w    $1FF8,$0000
	dc.w    $0FF0,$0000
	dc.w    $03C0,$0000
	dc.w    $0000   ; terminator: VSTART 0
	dc.w    $0000   ; terminator: VSTOP 0

	cnop    0,8
spr32Data:
	dc.w    $5350,$0000,$0000,$0000   ; VSTART $53, HSTART 160
	dc.w    $6300,$0000,$0000,$0000   ; VSTOP $63
	dc.w    $03C0,$07E0,$0000,$0000
	dc.w    $0FF0,$1FF8,$0000,$0000
	dc.w    $1C78,$3FFC,$0380,$0000
	dc.w    $3DFC,$3FFC,$0380,$0E70
	dc.w    $7DFE,$39CC,$0380,$0E70
	dc.w    $7FF8,$79CE,$0000,$0E70
	dc.w    $FFE0,$7FFE,$0000,$0000
	dc.w    $FF00,$7FFE,$0000,$0000
	dc.w    $FF00,$7FFE,$0000,$0000
	dc.w    $FFE0,$7FFE,$0000,$0000
	dc.w    $7FF8,$7FFE,$0000,$0000
	dc.w    $7FFE,$7FFE,$0000,$0000
	dc.w    $3FFC,$7FFE,$0000,$0000
	dc.w    $1FF8,$7BDE,$0000,$0000
	dc.w    $0FF0,$7BDE,$0000,$0000
	dc.w    $03C0,$318C,$0000,$0000
	dc.w    $0000,$0000   ; terminator: VSTART 0
	dc.w    $0000,$0000   ; terminator: VSTOP 0

	cnop    0,8
spr64Data:
	dc.w    $7550,$0000,$0000,$0000   ; VSTART $75, HSTART 160
	dc.w    $8500,$0000,$0000,$0000   ; VSTOP $85
	dc.w    $03C0,$07E0,$03C0,$07E0,$0000,$0000,$0000,$0000
	dc.w    $0FF0,$1FF8,$0FF0,$1FF8,$0000,$0000,$0000,$0000
	dc.w    $1C78,$3FFC,$1C78,$3FFC,$0380,$0000,$0380,$0000
	dc.w    $3DFC,$3FFC,$3DFC,$3FFC,$0380,$0E70,$0380,$0E70
	dc.w    $7DFE,$39CC,$7DFE,$39CC,$0380,$0E70,$0380,$0E70
	dc.w    $7FF8,$79CE,$7FF8,$79CE,$0000,$0E70,$0000,$0E70
	dc.w    $FFE0,$7FFE,$FFE0,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $FF00,$7FFE,$FF00,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $FF00,$7FFE,$FF00,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $FFE0,$7FFE,$FFE0,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $7FF8,$7FFE,$7FF8,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $7FFE,$7FFE,$7FFE,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $3FFC,$7FFE,$3FFC,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $1FF8,$7BDE,$1FF8,$7BDE,$0000,$0000,$0000,$0000
	dc.w    $0FF0,$7BDE,$0FF0,$7BDE,$0000,$0000,$0000,$0000
	dc.w    $03C0,$318C,$03C0,$318C,$0000,$0000,$0000,$0000
	dc.w    $0000,$0000,$0000,$0000   ; terminator: VSTART 0
	dc.w    $0000,$0000,$0000,$0000   ; terminator: VSTOP 0

	cnop    0,8
spr16dData:
	dc.w    $97D0,$0000,$0000,$0000   ; VSTART $97, HSTART 160, SSCAN2 (POS bit 7)
	dc.w    $B700,$0000,$0000,$0000   ; VSTOP $B7
	dc.w    $03C0,$0000
	dc.w    $0FF0,$0000
	dc.w    $1C78,$0380
	dc.w    $3DFC,$0380
	dc.w    $7DFE,$0380
	dc.w    $7FF8,$0000
	dc.w    $FFE0,$0000
	dc.w    $FF00,$0000
	dc.w    $FF00,$0000
	dc.w    $FFE0,$0000
	dc.w    $7FF8,$0000
	dc.w    $7FFE,$0000
	dc.w    $3FFC,$0000
	dc.w    $1FF8,$0000
	dc.w    $0FF0,$0000
	dc.w    $03C0,$0000
	dc.w    $0000   ; terminator: VSTART 0
	dc.w    $0000   ; terminator: VSTOP 0

	cnop    0,8
spr32dData:
	dc.w    $B9D0,$0000,$0000,$0000   ; VSTART $B9, HSTART 160, SSCAN2 (POS bit 7)
	dc.w    $D900,$0000,$0000,$0000   ; VSTOP $D9
	dc.w    $03C0,$07E0,$0000,$0000
	dc.w    $0FF0,$1FF8,$0000,$0000
	dc.w    $1C78,$3FFC,$0380,$0000
	dc.w    $3DFC,$3FFC,$0380,$0E70
	dc.w    $7DFE,$39CC,$0380,$0E70
	dc.w    $7FF8,$79CE,$0000,$0E70
	dc.w    $FFE0,$7FFE,$0000,$0000
	dc.w    $FF00,$7FFE,$0000,$0000
	dc.w    $FF00,$7FFE,$0000,$0000
	dc.w    $FFE0,$7FFE,$0000,$0000
	dc.w    $7FF8,$7FFE,$0000,$0000
	dc.w    $7FFE,$7FFE,$0000,$0000
	dc.w    $3FFC,$7FFE,$0000,$0000
	dc.w    $1FF8,$7BDE,$0000,$0000
	dc.w    $0FF0,$7BDE,$0000,$0000
	dc.w    $03C0,$318C,$0000,$0000
	dc.w    $0000,$0000   ; terminator: VSTART 0
	dc.w    $0000,$0000   ; terminator: VSTOP 0

	cnop    0,8
spr64dData:
	dc.w    $DBD0,$0000,$0000,$0000   ; VSTART $DB, HSTART 160, SSCAN2 (POS bit 7)
	dc.w    $FB00,$0000,$0000,$0000   ; VSTOP $FB
	dc.w    $03C0,$07E0,$03C0,$07E0,$0000,$0000,$0000,$0000
	dc.w    $0FF0,$1FF8,$0FF0,$1FF8,$0000,$0000,$0000,$0000
	dc.w    $1C78,$3FFC,$1C78,$3FFC,$0380,$0000,$0380,$0000
	dc.w    $3DFC,$3FFC,$3DFC,$3FFC,$0380,$0E70,$0380,$0E70
	dc.w    $7DFE,$39CC,$7DFE,$39CC,$0380,$0E70,$0380,$0E70
	dc.w    $7FF8,$79CE,$7FF8,$79CE,$0000,$0E70,$0000,$0E70
	dc.w    $FFE0,$7FFE,$FFE0,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $FF00,$7FFE,$FF00,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $FF00,$7FFE,$FF00,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $FFE0,$7FFE,$FFE0,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $7FF8,$7FFE,$7FF8,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $7FFE,$7FFE,$7FFE,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $3FFC,$7FFE,$3FFC,$7FFE,$0000,$0000,$0000,$0000
	dc.w    $1FF8,$7BDE,$1FF8,$7BDE,$0000,$0000,$0000,$0000
	dc.w    $0FF0,$7BDE,$0FF0,$7BDE,$0000,$0000,$0000,$0000
	dc.w    $03C0,$318C,$03C0,$318C,$0000,$0000,$0000,$0000
	dc.w    $0000,$0000,$0000,$0000   ; terminator: VSTART 0
	dc.w    $0000,$0000,$0000,$0000   ; terminator: VSTOP 0


	; An unused sprite still fetches two control words on line 25, at the 64
	; bit stride set at the top of the copper list. Both read zero, so the
	; sprite never switches on.
	cnop    0,8
nullSprData:
	dc.w    $0000,$0000,$0000,$0000   ; VSTART 0
	dc.w    $0000,$0000,$0000,$0000   ; VSTOP 0

	cnop    0,8
bitplane1: ds.b PLANE_SIZE
