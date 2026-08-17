	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

;
;
;
;
;
; bplam9.s -- bplam8 with a black Pacman body.
;
; bplam7 paints the body in colour[BPLAM] so that it disappears against the
; picture, and bplam8 thins that column out so there are sprite-free bands to
; compare against. Both hide the body on the PICTURE side of the window edge.
; This one hides it on the BORDER side instead: COLOR17 is $000, and half the
; subsections run with BRDRBLNK set, which forces the border to pure black.
;
; That inverts every contrast in the picture and gives the sweep a landmark it
; did not have before.
;
;   BRDRBLNK subsections, border black
;
;       Body and border are the same black, so the sprite has no edge on
;       the border side and the black simply runs on from the border into
;       the picture for as far as the sprite survived. What is readable is
;       therefore not one edge but the DIFFERENCE between two lines: a
;       sprite line and a sprite-free line of the same subsection, where
;       the sprite-free line gives the unextended window edge and the
;       sprite line gives edge plus surviving sprite.
;
;       Taken over the sixteen lines of a band that difference traces the
;       Pacman's left silhouette, one number per rasterline, with no colour
;       step anywhere near the window boundary being measured. In the super
;       hires "before" subsection of the recorded reference it reads
;
;           43 43 43 ...            the sprite-free lines
;           48 49 50 51 49 47 44 44 47 49 51 50 49 48 46 43
;
;       which is the figure, in screenshot columns, drawn by subtraction.
;
;   border-open subsections, border grey
;
;       The body is black against a grey border and a blue picture, so the
;       whole figure is legible on its own. This is the control: it shows
;       where the sprite is without needing the subtraction, in the same
;       three DIWSTRT positions.
;
; Read against bplam7 and bplam8 this closes the loop. Those two answer the
; question with the body matched to the picture, so an error shows up as blue
; appearing where border belongs. bplam9 answers it with the body matched to
; the border, so the same error shows up as black appearing where picture
; belongs. Two opposite colour schemes cannot both be biased the same way by
; monitor bleeding, and the ruler is common to all of them.
;
; The eyes stay in COLOR18 and COLOR19. Against a black body they are the one
; part of the figure with any brightness, so they also mark which sprite row
; a given rasterline is showing.
;
; Every second Pacman is left out, exactly as in bplam8: SPR_PERIOD 36 and
; SPR_REPS 8, sixteen lines with a sprite and twenty with none, so a band
; that has a sprite in it always has a sprite-free band above and below at
; the same window position.
;
BPLCON3             equ $106          ; AGA only
BPLCON4             equ $10C          ; AGA only
FMODEREG            equ $1FC          ; AGA only

FMODE               equ $0001         ; 4 planes have to fit in super hires

DDF_START           equ $0038
DDF_STOP            equ $00B0

; DIWSTRT is written per subsection; only the stop is global here.
DIW_VSTART          equ $2A00         ; vertical window start
DIW_STOP            equ $2CC1

LORES_BITS          equ $0201         ; lores, ECSENA
HIRES_BITS          equ $8201         ; hires, ECSENA
SHRES_BITS          equ $0241         ; super hires, ECSENA
BPLAM               equ $20           ; constant colour XOR, clear
                                      ; of the sprite palette
BPLCON4_VAL         equ (BPLAM<<8)|$11
BLACK               equ $000
BRDRBLNK            equ $0020         ; BPLCON3 bit 5
BACKGND             equ $444          ; not black: BRDRBLNK has to show
BPLCON0_OFF         equ $0201         ; no bitplanes, ECSENA

PLANE_SIZE          equ 8192

; Sprite columns
SPR_LEFT            equ $073          ; lores, where DIWSTRT sweeps
SPR_RIGHT           equ $1B9          ; lores, straddling DIWSTOP at $1C1
SPR_TOP             equ $02A          ; first line of the first Pacman
SPR_PERIOD          equ 36            ; 16 lines of Pacman, then 20 empty
SPR_REPS            equ 8             ; $2A + 7*36 = $126, still reaches
SPR_BUF_SIZE        equ SPR_REPS*(2+32)*2+8



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

	move.w  #FMODE,FMODEREG(a1)

	; Fill the four buffers, one repeating word each.
	lea     bitBuf0,a0
	move.w  #$5555,d1
	bsr     .fillWord
	lea     bitBuf1,a0
	move.w  #$3333,d1
	bsr     .fillWord
	lea     bitBuf2,a0
	move.w  #$0F0F,d1
	bsr     .fillWord
	lea     bitBuf3,a0
	move.w  #$00FF,d1
	bsr     .fillWord

	lea     CUSTOM,a1
	; Initialize all 256 AGA color registers (COLOR00-31 are banked 8 times
	; via BPLCON3's BANK bits, and each register's low nibble is written
	; separately with LOCT set). See .makeColor for the scheme.
	lea     CUSTOM,a1
	; Banks are processed 7 down to 0, so bank 0 (COLOR00-31, the only bank
	; OCS/ECS ever look at) is written *last*. On chipsets where BPLCON3's
	; BANK field is a no-op every "bank" write lands in the same physical 32
	; registers, so whichever bank is processed last is what sticks -- it has
	; to be bank 0, or the visible palette ends up being bank 7's.
	moveq   #7,d7                   ; d7 = bank (7 downto 0)
.colorBankLoop:
	move.w  d7,d0
	lsl.w   #8,d0                   ; BANK2-0 -> BPLCON3 bits 15-13
	lsl.w   #5,d0
	move.w  d0,BPLCON3(a1)          ; LOCT=0: write high nibble of R,G,B
	lea     COLOR00(a1),a2
	moveq   #0,d6                   ; d6 = register number within bank (0-31)
.colorHiLoop:
	move.w  d7,d5
	lsl.w   #5,d5
	or.w    d6,d5                   ; d5 = i = bank*32+reg (0-255)
	bsr     .makeColor              ; d5 -> d2
	move.w  d2,(a2)+
	addq.w  #1,d6
	cmp.w   #32,d6
	bne.s   .colorHiLoop

	or.w    #$0200,d0               ; LOCT=1: write low nibble of R,G,B
	move.w  d0,BPLCON3(a1)
	lea     COLOR00(a1),a2
	moveq   #0,d6
.colorLoLoop:
	move.w  d7,d5
	lsl.w   #5,d5
	or.w    d6,d5
	bsr     .makeColor
	move.w  d2,(a2)+
	addq.w  #1,d6
	cmp.w   #32,d6
	bne.s   .colorLoLoop

	dbra    d7,.colorBankLoop

	; COLOR00 is dark blue rather than black. It is the colour of the
	; display window wherever the bitplanes have not delivered data yet,
	; and with BRDRBLNK set it is no longer shared with the border, so the
	; window edge becomes visible. Written twice, LOCT=0 then LOCT=1, so
	; both nibbles of every channel are filled.
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT=0
	move.w  #BACKGND,COLOR00(a1)
	move.w  #$0200,BPLCON3(a1)      ; bank 0, LOCT=1
	move.w  #BACKGND,COLOR00(a1)
	move.w  #$0000,BPLCON3(a1)      ; leave BPLCON3 in a known state

	; Sprites 0 and 1 share colour registers 17 to 19. The palette loop
	; above has already filled them with whatever .makeColor produces, so
	; they are overwritten here. Both nibbles again, LOCT=0 then LOCT=1.
	; The body is black, which is what BRDRBLNK makes of the border. In
	; the blanked subsections the body therefore vanishes into the border
	; and shows only inside the window, so the sprite draws the window
	; edge itself. Both nibbles are written, so the register is $000 in
	; all eight bits per component and not merely in the high four.
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT=0
	move.w  #$0000,COLOR17(a1)      ; body: black, like a blanked border
	move.w  #$0F80,COLOR18(a1)      ; eyes
	move.w  #$0FFF,COLOR19(a1)      ; eyes
	move.w  #$0200,BPLCON3(a1)      ; bank 0, LOCT=1
	move.w  #$0000,COLOR17(a1)
	move.w  #$0F80,COLOR18(a1)
	move.w  #$0FFF,COLOR19(a1)
	move.w  #$0000,BPLCON3(a1)      ; leave BPLCON3 in a known state


	; Patch the four bitplane pointers into every block of the copper
	; list. There is one block per subsection: the planes are rewound
	; every 14 lines so that a super hires section cannot read past the
	; end of its buffer.
	lea     ptrBlocks(pc),a4
.blkLoop:
	move.l  (a4)+,d4
	beq.s   .blkDone
	move.l  d4,a2
	lea     planeTable(pc),a5
	moveq   #3,d6
.ptLoop:
	move.l  (a5)+,d3
	move.w  d3,6(a2)                ; low  word -> BPLxPTL move
	swap    d3
	move.w  d3,2(a2)                ; high word -> BPLxPTH move
	addq.l  #8,a2
	dbra    d6,.ptLoop
	bra.s   .blkLoop
.blkDone:


	; Build the two sprite lists and patch their addresses into the copper.
	lea     sprBuf0,a0
	move.w  #SPR_LEFT,d1
	bsr     .buildSprite
	lea     sprBuf1,a0
	move.w  #SPR_RIGHT,d1
	bsr     .buildSprite

	; All eight pointers are patched, not just the two that are used.
	; Sprite DMA is enabled for the whole channel set, so sprites 2 to 7
	; fetch from wherever their pointers happen to be left pointing and
	; paint whatever they find. They are aimed at an empty list instead.
	clr.l   sprNull
	clr.l   sprNull+4
	lea     sprPtrs(pc),a2
	lea     .sprTable(pc),a5
	moveq   #7,d6
.sprPtLoop:
	move.l  (a5)+,d3
	bsr     .patchPtr
	dbra    d6,.sprPtLoop
	lea     CUSTOM,a1

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

.patchPtr:
	; Patches the long word in d3 into the SPRxPT move pair at a2, and
	; advances a2 to the next pair.
	move.w  d3,6(a2)                ; low  word -> SPRxPTL move
	swap    d3
	move.w  d3,2(a2)                ; high word -> SPRxPTH move
	addq.l  #8,a2
	rts

.buildSprite:
	; Writes SPR_REPS copies of the Pacman to the buffer at a0, the first
	; at line SPR_TOP and the rest SPR_PERIOD lines apart, all of them at
	; the horizontal position in d1. Clobbers a0, a2, d1-d6.
	move.w  #SPR_TOP,d2             ; d2 = VSTART
	move.w  #SPR_REPS-1,d3
.bsLoop:
	move.w  d2,d4
	add.w   #16,d4                  ; d4 = VSTOP

	; SPRxPOS: VSTART bits 7-0, HSTART bits 8-1
	move.w  d2,d5
	and.w   #$00FF,d5
	lsl.w   #8,d5
	move.w  d1,d6
	lsr.w   #1,d6
	and.w   #$00FF,d6
	or.w    d6,d5
	move.w  d5,(a0)+

	; SPRxCTL: VSTOP bits 7-0, then VSTART bit 8, VSTOP bit 8, HSTART bit 0
	move.w  d4,d5
	and.w   #$00FF,d5
	lsl.w   #8,d5
	btst    #8,d2
	beq.s   .bsNoV8
	or.w    #$0004,d5
.bsNoV8:
	btst    #8,d4
	beq.s   .bsNoV9
	or.w    #$0002,d5
.bsNoV9:
	btst    #0,d1
	beq.s   .bsNoH0
	or.w    #$0001,d5
.bsNoH0:
	move.w  d5,(a0)+

	; 16 lines of image data, two words each
	lea     .pacman(pc),a2
	moveq   #15,d6
.bsImg:
	move.l  (a2)+,(a0)+
	dbra    d6,.bsImg

	add.w   #SPR_PERIOD,d2
	dbra    d3,.bsLoop

	clr.l   (a0)+                   ; end of list
	rts

.sprTable:
	; What each of the eight sprite pointers is aimed at.
	dc.l    sprBuf0,sprBuf1
	dc.l    sprNull,sprNull,sprNull,sprNull,sprNull,sprNull

.pacman:
	; The Pacman from Denise/Sprites/sprdrop/sprdrop_cop.i, image data
	; only -- the control words are computed in .buildSprite.
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

.fillWord:
	; Fills the buffer at a0 with the word in d1. clobbers a0, d0
	move.w  #(PLANE_SIZE/2)-1,d0
.fwLoop:
	move.w  d1,(a0)+
	dbra    d0,.fwLoop
	rts

.makeColor:
	; Maps colour index d5 (0-255) to a 12-bit $RGB value whose *hue* is
	; determined solely by the position p of the index's highest set bit,
	; i.e. by how many bitplanes it takes to produce that index:
	;   0        black
	;   1        red        (1 plane)
	;   2-3      orange     (2 planes)
	;   4-7      yellow     (3 planes)
	;   8-15     green      (4 planes)
	;   16-31    cyan       (5 planes)
	;   32-63    blue       (6 planes)
	;   64-127   magenta    (7 planes)
	;   128-255  white      (8 planes)
	; Bit 0 of the index -- and only bit 0, i.e. bitplane 1 -- picks between
	; half and full brightness. Every other bit affects the hue alone, so the
	; 2-pixel plane 1 ruler shows up as a crisp bright/dim alternation right
	; across the picture without ever making the bitplane count ambiguous.
	; in: d5=index (0-255); out: d2=12-bit RGB
	; clobbers: d0, d1, d3, d4, a3
	moveq   #0,d2
	tst.w   d5
	beq     .mcDone                 ; index 0 -> black

	; d3 = p = position of the highest set bit (0-7)
	move.w  d5,d1
	moveq   #0,d3
.mcTopBit:
	lsr.w   #1,d1
	beq.s   .mcGotP
	addq.w  #1,d3
	bra.s   .mcTopBit
.mcGotP:

	; d4 = brightness: full if the index is odd, half if it is even
	moveq   #8,d4
	btst    #0,d5
	beq.s   .mcGotB
	moveq   #15,d4
.mcGotB:

	; Fetch the hue for family p: three nibbles holding a per-channel code
	; (0 = off, 1 = half brightness, 2 = full brightness).
	lea     .hueTable(pc),a3
	add.w   d3,d3
	move.w  0(a3,d3.w),d1

	move.w  d1,d3
	lsr.w   #8,d3
	and.w   #$0F,d3
	bsr.s   .mcChannel
	lsl.w   #8,d0
	or.w    d0,d2                   ; red   -> bits 11-8

	move.w  d1,d3
	lsr.w   #4,d3
	and.w   #$0F,d3
	bsr.s   .mcChannel
	lsl.w   #4,d0
	or.w    d0,d2                   ; green -> bits 7-4

	move.w  d1,d3
	and.w   #$0F,d3
	bsr.s   .mcChannel
	or.w    d0,d2                   ; blue  -> bits 3-0
.mcDone:
	rts

.mcChannel:
	; in: d3=code (0/1/2), d4=brightness; out: d0=channel value
	moveq   #0,d0
	tst.w   d3
	beq.s   .mcChannelDone
	move.w  d4,d0
	cmp.w   #2,d3
	beq.s   .mcChannelDone
	lsr.w   #1,d0                   ; half brightness
.mcChannelDone:
	rts

.hueTable:
	dc.w    $0200                  ; red     (1 plane)
	dc.w    $0210                  ; orange  (2 planes)
	dc.w    $0220                  ; yellow  (3 planes)
	dc.w    $0020                  ; green   (4 planes)
	dc.w    $0022                  ; cyan    (5 planes)
	dc.w    $0002                  ; blue    (6 planes)
	dc.w    $0202                  ; magenta (7 planes)
	dc.w    $0222                  ; white   (8 planes)

planeTable:
	dc.l    bitBuf0,bitBuf1,bitBuf2,bitBuf3

copper:
sprPtrs:
	dc.w    SPR0PTH,$0000
	dc.w    SPR0PTL,$0000
	dc.w    SPR1PTH,$0000
	dc.w    SPR1PTL,$0000
	dc.w    SPR2PTH,$0000
	dc.w    SPR2PTL,$0000
	dc.w    SPR3PTH,$0000
	dc.w    SPR3PTL,$0000
	dc.w    SPR4PTH,$0000
	dc.w    SPR4PTL,$0000
	dc.w    SPR5PTH,$0000
	dc.w    SPR5PTL,$0000
	dc.w    SPR6PTH,$0000
	dc.w    SPR6PTL,$0000
	dc.w    SPR7PTH,$0000
	dc.w    SPR7PTL,$0000
	dc.w    FMODEREG,FMODE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024
	dc.w    BPLCON3,$0000
	dc.w    BPLCON4,BPLCON4_VAL     ; BPLAM held constant
	dc.w    DIWSTOP,DIW_STOP
	dc.w    DDFSTRT,DDF_START
	dc.w    DDFSTOP,DDF_STOP
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000
	dc.w    COLOR00,BACKGND

	;
	; LORES section, lines $2A-$7F. First bitplane pixel at lores $7F.
	;
	dc.w    $2A01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000           ; border open: BPU = 0 is all border
	dc.w    COLOR00,BLACK
	dc.w    $2B31,$FFFE
	dc.w    COLOR00,$F00
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
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$0F0
	dc.w    $2BE1,$FFFE
	dc.w    COLOR00,BLACK
	dc.w    COLOR00,BACKGND

	dc.w    $2C01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$77 ; before, border open
	dc.w    BPLCON0,(4<<12)|LORES_BITS
bplPtrsLORES0:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $3A01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$7F ; exact , border open
	dc.w    BPLCON0,(4<<12)|LORES_BITS
bplPtrsLORES1:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $4801,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$87 ; overlap, border open
	dc.w    BPLCON0,(4<<12)|LORES_BITS
bplPtrsLORES2:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $5601,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$77 ; before, border blanked
	dc.w    BPLCON0,(4<<12)|LORES_BITS
bplPtrsLORES3:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $6401,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$7F ; exact , border blanked
	dc.w    BPLCON0,(4<<12)|LORES_BITS
bplPtrsLORES4:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $7201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$87 ; overlap, border blanked
	dc.w    BPLCON0,(4<<12)|LORES_BITS
bplPtrsLORES5:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000

	dc.w    $7FE1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	;
	; HIRES section, lines $80-$D5. First bitplane pixel at lores $7F.
	;
	dc.w    $8001,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000           ; border open: BPU = 0 is all border
	dc.w    COLOR00,BLACK
	dc.w    $8131,$FFFE
	dc.w    COLOR00,$F00
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
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$0F0
	dc.w    $81E1,$FFFE
	dc.w    COLOR00,BLACK
	dc.w    COLOR00,BACKGND

	dc.w    $8201,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$77 ; before, border open
	dc.w    BPLCON0,(4<<12)|HIRES_BITS
bplPtrsHIRES0:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $9001,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$7F ; exact , border open
	dc.w    BPLCON0,(4<<12)|HIRES_BITS
bplPtrsHIRES1:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $9E01,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$87 ; overlap, border open
	dc.w    BPLCON0,(4<<12)|HIRES_BITS
bplPtrsHIRES2:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $AC01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$77 ; before, border blanked
	dc.w    BPLCON0,(4<<12)|HIRES_BITS
bplPtrsHIRES3:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $BA01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$7F ; exact , border blanked
	dc.w    BPLCON0,(4<<12)|HIRES_BITS
bplPtrsHIRES4:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $C801,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$87 ; overlap, border blanked
	dc.w    BPLCON0,(4<<12)|HIRES_BITS
bplPtrsHIRES5:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000

	dc.w    $D5E1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	;
	; SHRES section, lines $D6-$12B. First bitplane pixel at lores $73.
	;
	dc.w    $D601,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000           ; border open: BPU = 0 is all border
	dc.w    COLOR00,BLACK
	dc.w    $D731,$FFFE
	dc.w    COLOR00,$F00
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
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$0F0
	dc.w    $D7E1,$FFFE
	dc.w    COLOR00,BLACK
	dc.w    COLOR00,BACKGND

	dc.w    $D801,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$6B ; before, border open
	dc.w    BPLCON0,(4<<12)|SHRES_BITS
bplPtrsSHRES0:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $E601,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$73 ; exact , border open
	dc.w    BPLCON0,(4<<12)|SHRES_BITS
bplPtrsSHRES1:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $F401,$FFFE
	dc.w    BPLCON3,$0000
	dc.w    DIWSTRT,DIW_VSTART|$7B ; overlap, border open
	dc.w    BPLCON0,(4<<12)|SHRES_BITS
bplPtrsSHRES2:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $FFDF,$FFFE             ; cross the 8 bit vertical boundary
	dc.w    $0001,$FFFE             ; re-sync at the start of line 256
	dc.w    $0201,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$6B ; before, border blanked
	dc.w    BPLCON0,(4<<12)|SHRES_BITS
bplPtrsSHRES3:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $1001,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$73 ; exact , border blanked
	dc.w    BPLCON0,(4<<12)|SHRES_BITS
bplPtrsSHRES4:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000
	dc.w    $1E01,$FFFE
	dc.w    BPLCON3,BRDRBLNK
	dc.w    DIWSTRT,DIW_VSTART|$7B ; overlap, border blanked
	dc.w    BPLCON0,(4<<12)|SHRES_BITS
bplPtrsSHRES5:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000

	dc.w    $2BE1,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	dc.w    $2C01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000
	dc.l    $FFFFFFFE

; Every block of BPLxPT moves in the list above, terminated by zero.
ptrBlocks:
	dc.l    bplPtrsLORES0,bplPtrsLORES1,bplPtrsLORES2
	dc.l    bplPtrsLORES3,bplPtrsLORES4,bplPtrsLORES5
	dc.l    bplPtrsHIRES0,bplPtrsHIRES1,bplPtrsHIRES2
	dc.l    bplPtrsHIRES3,bplPtrsHIRES4,bplPtrsHIRES5
	dc.l    bplPtrsSHRES0,bplPtrsSHRES1,bplPtrsSHRES2
	dc.l    bplPtrsSHRES3,bplPtrsSHRES4,bplPtrsSHRES5
	dc.l    0

	cnop    0,8
sprBuf0: ds.b SPR_BUF_SIZE
	cnop    0,8
sprBuf1: ds.b SPR_BUF_SIZE
	cnop    0,8
sprNull: ds.b 8                 ; an empty list for the six unused sprites
	cnop    0,8
bitBuf0: ds.b PLANE_SIZE
	cnop    0,8
bitBuf1: ds.b PLANE_SIZE
	cnop    0,8
bitBuf2: ds.b PLANE_SIZE
	cnop    0,8
bitBuf3: ds.b PLANE_SIZE
