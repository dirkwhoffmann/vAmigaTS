; spres.i -- shared body for the Agnus/AGA agasprites SPRES tests.
;
; The including file must have already included registers.i,
; hardware/dmabits.i, hardware/intbits.i and ministartup.s (see
; simple2/simple2.s for the exact boilerplate).
;
; Companion to agasprites.i. That one varies the sprite WIDTH in memory
; (FMODE bits 3-2) and the vertical scan doubling (FMODE bit 15); this one
; holds both fixed and varies the sprite RESOLUTION instead, BPLCON3 bits
; 7-6:
;
;     00   sprite pixels track the bitplanes
;     01   lores
;     10   hires
;     11   super hires
;
; Resolution is independent of how many bits of data a sprite fetches. All
; four sections below display the same 64 bit sprite -- the same four
; figures, the same sixteen lines, the same eight words per line -- and
; only the width of a sprite pixel changes. So the row must get narrower
; from section to section while keeping its shape:
;
;     section 1   SPRES 00   the playfield is lores, so: 64 lores pixels
;     section 2   SPRES 01   lores, 64 lores pixels
;     section 3   SPRES 10   hires, 32 lores pixels
;     section 4   SPRES 11   super hires, 16 lores pixels
;
; Sections 1 and 2 are a built-in control: the playfield is lores, so
; "track the bitplanes" and "lores" have to come out identical. If they do
; not, the SPRES field is not being decoded the way this test assumes and
; nothing below it means anything.
;
; Sections 3 and 4 are the point. vAmiga's Denise::sprPixelWidth returns 1
; for BOTH the hires and the super hires code:
;
;     case 0b01: return 2;    // Lores
;     case 0b10: return 1;    // Hires
;     case 0b11: return 1;    // Super Hires
;
; so it draws sections 3 and 4 at the same width. A machine that halves the
; pixel again for super hires paints section 4 at half the width of section
; 3, and the four sections come out as a 4:4:2:1 staircase rather than
; 4:4:2:2. One screenshot decides it.
;
; Everything else is deliberately identical to agasprites.i: same Pacman
; and ghost artwork from Denise/Sprites/sprdrop, same copper ruler on the
; first line of every section, same solid one bitplane playfield so the
; display window shows as a rectangle and sprites are not asked to draw
; over the border. FMODE is set once at the top of the copper list and
; never changed, so unlike simple1 there is no interaction with the line 25
; control word fetch to reason about: every control block and every data
; line uses the same 4 word stride.

BPLCON3             equ $106          ; AGA only
BPLCON4             equ $10C          ; AGA only
FMODEREG            equ $1FC          ; AGA only

	IFND SPR_HSTART
SPR_HSTART          equ 160
	ENDC

DDF_START           equ $0038
DDF_STOP            equ $00D0

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
	; rectangle and the sprites can be seen to sit inside it.
	lea     bitplane1,a0
	move.w  #(PLANE_SIZE/2)-1,d0
.fill:
	move.w  #$FFFF,(a0)+
	dbra    d0,.fill

	; Colours, identical to agasprites.i for all sprite pairs.
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT = 0, SPRES = 00
	move.w  #$0000,COLOR00(a1)      ; border
	move.w  #$0224,COLOR01(a1)      ; playfield
	move.w  #$0FF8,COLOR17(a1)
	move.w  #$0444,COLOR18(a1)
	move.w  #$0F00,COLOR19(a1)
	move.w  #$0FF8,COLOR21(a1)
	move.w  #$0444,COLOR22(a1)
	move.w  #$0F00,COLOR23(a1)

	; Patch the pointers into the copper list.
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
	dc.l    sprAPtr,sprAData
	dc.l    sprBPtr,sprBData
	dc.l    sprCPtr,sprCData
	dc.l    sprDPtr,sprDData
	dc.l    spr4Ptr,nullSprData
	dc.l    spr5Ptr,nullSprData
	dc.l    spr6Ptr,nullSprData
	dc.l    spr7Ptr,nullSprData
	dc.l    0


copper:
	; FMODE is set once and never changed: 64 bit sprites for the whole
	; frame, so every control block and every data line uses the same 4
	; word stride and sprite width is not a variable here.
	dc.w    FMODEREG,$000C
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024           ; sprites in front of the playfield
	dc.w    BPLCON3,$0000
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
sprAPtr:
	dc.w    SPR0PTH,$0000
	dc.w    SPR0PTL,$0000
sprBPtr:
	dc.w    SPR1PTH,$0000
	dc.w    SPR1PTL,$0000
sprCPtr:
	dc.w    SPR2PTH,$0000
	dc.w    SPR2PTL,$0000
sprDPtr:
	dc.w    SPR3PTH,$0000
	dc.w    SPR3PTL,$0000
	; Sprites 4 to 7 are unused, but sprite DMA is enabled for all eight
	; channels at once and every channel fetches control words on line 25.
	; Left unpointed they would display random memory.
spr4Ptr:
	dc.w    SPR4PTH,$0000
	dc.w    SPR4PTL,$0000
spr5Ptr:
	dc.w    SPR5PTH,$0000
	dc.w    SPR5PTL,$0000
spr6Ptr:
	dc.w    SPR6PTH,$0000
	dc.w    SPR6PTL,$0000
spr7Ptr:
	dc.w    SPR7PTH,$0000
	dc.w    SPR7PTL,$0000

	;
	; Section 1 (lines $30-$47): sprite 0, SPRES = 00, as the bitplanes (lores here)
	;
	dc.w    $3001,$FFFE
	dc.w    BPLCON3,$0000           ; SPRES = 00
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,$000
	dc.w    $3000+DDF_START+1,$FFFE
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
	; Section 2 (lines $48-$5F): sprite 1, SPRES = 01, lores
	;
	dc.w    $4801,$FFFE
	dc.w    BPLCON3,$0040           ; SPRES = 01
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,$000
	dc.w    $4800+DDF_START+1,$FFFE
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
	dc.w    $4901,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 3 (lines $60-$77): sprite 2, SPRES = 10, hires
	;
	dc.w    $6001,$FFFE
	dc.w    BPLCON3,$0080           ; SPRES = 10
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,$000
	dc.w    $6000+DDF_START+1,$FFFE
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
	dc.w    $6101,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 4 (lines $78-$8F): sprite 3, SPRES = 11, super hires
	;
	dc.w    $7801,$FFFE
	dc.w    BPLCON3,$00C0           ; SPRES = 11
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,$000
	dc.w    $7800+DDF_START+1,$FFFE
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
	dc.w    $7901,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Done -- shut the display down again.
	;
	dc.w    $9001,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000

	dc.l    $fffffffe


; Sprite data. FMODE is $000C throughout, so every control block and
; every data line is 4 words per read: 8 words of control block, then 16
; lines of 8 words, then a terminating control block.

	cnop    0,8
sprAData:
	dc.w    $3150,$0000,$0000,$0000   ; VSTART $31, HSTART 160
	dc.w    $4100,$0000,$0000,$0000   ; VSTOP $41
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
sprBData:
	dc.w    $4950,$0000,$0000,$0000   ; VSTART $49, HSTART 160
	dc.w    $5900,$0000,$0000,$0000   ; VSTOP $59
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
sprCData:
	dc.w    $6150,$0000,$0000,$0000   ; VSTART $61, HSTART 160
	dc.w    $7100,$0000,$0000,$0000   ; VSTOP $71
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
sprDData:
	dc.w    $7950,$0000,$0000,$0000   ; VSTART $79, HSTART 160
	dc.w    $8900,$0000,$0000,$0000   ; VSTOP $89
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
nullSprData:
	dc.w    $0000,$0000,$0000,$0000   ; VSTART 0
	dc.w    $0000,$0000,$0000,$0000   ; VSTOP 0

	cnop    0,8
bitplane1: ds.b PLANE_SIZE
