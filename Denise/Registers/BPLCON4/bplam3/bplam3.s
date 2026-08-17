	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; bplam3.s -- BPLAM read against a blanked border.
;
; Identical to bplam -- same four bitplanes, same pixel-position data, same
; ten section sweep of BPLCON4's colour XOR -- with two changes:
;
;   COLOR00 is dark blue instead of black
;   BRDRBLNK (BPLCON3 bit 5) is set, so the border is forced to black
;
; and ECSENA (BPLCON0 bit 0) is set throughout, because BRDRBLNK does
; nothing without it.
;
;
; WHY
; ---
;
; In bplam the border and the part of the display window that lies before
; the bitplane data arrives are both black, and they are therefore
; indistinguishable. That matters, because BPLAM makes the second of those
; two areas visible: inside the window the colour index is 0 until data
; arrives, and 0 XOR BPLAM is a real palette entry. Every section of bplam
; consequently opens with a solid stretch of colour[BPLAM] whose left edge
; cannot be located -- it runs into the black border with no seam.
;
; Blanking the border separates them. The border is now pure black no
; matter what COLOR00 holds, while the window interior takes COLOR00, which
; is dark blue. The line therefore reads as three zones with two hard
; edges:
;
;   black             the border, up to DIWSTRT
;   solid colour      the window, before the bitplane data arrives
;   the 16 step ramp  the window, once data arrives
;
; The first edge is the display window opening, the second is the first
; bitplane pixel, and the gap between them is the DDF-to-first-pixel
; latency, measured directly rather than inferred. Neither edge is legible
; in bplam.
;
; The dark blue matters in the first section only, where BPLAM is $00 and
; the pre-data zone falls on COLOR00 itself; in every other section that
; zone falls on colour[BPLAM] and is some other hue. Either way it is not
; black, which is the whole point -- black now means border and nothing
; else.
;
; One consequence to expect: with COLOR00 no longer black, step 0 of the
; ramp is dark blue rather than black, so the ramp starts one visible shade
; above where it did in bplam.
;
; The Copper ruler is unchanged except for its final write, which restores
; the dark blue rather than leaving COLOR00 black. Without that the zone
; the test exists to show would be black again on every line below the
; first ruler.

BPLCON3             equ $106          ; AGA only
BPLCON4             equ $10C          ; AGA only
FMODEREG            equ $1FC          ; AGA only

FMODE               equ $0000         ; 16-bit fetch throughout

DDF_START           equ $0038
DDF_STOP            equ $00B0

DIW_START           equ $2C00+(DDF_START*2)+9
DIW_STOP            equ $2CC1

BPLCON0_ON          equ $4201         ; 4 bitplanes, lores, ECSENA
BRDRBLNK            equ $0020         ; BPLCON3 bit 5
DARKBLUE            equ $006
BPLCON0_OFF         equ $0201         ; no bitplanes, ECSENA

PLANE_SIZE          equ 8192


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
	move.w  #DARKBLUE,COLOR00(a1)
	move.w  #$0200,BPLCON3(a1)      ; bank 0, LOCT=1
	move.w  #DARKBLUE,COLOR00(a1)
	move.w  #$0000,BPLCON3(a1)      ; leave BPLCON3 in a known state


	; Patch the four bitplane pointers into the copper list.
	lea     bplPtrs(pc),a2
	lea     planeTable(pc),a5
	moveq   #3,d6
.ptLoop:
	move.l  (a5)+,d3
	move.w  d3,6(a2)                ; low  word -> BPLxPTL move
	swap    d3
	move.w  d3,2(a2)                ; high word -> BPLxPTH move
	addq.l  #8,a2
	dbra    d6,.ptLoop

	; Install Copper list and enable DMA
	lea 	CUSTOM,a1
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	move.w	#$8080,DMACON(a1)   ; Copper DMA
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA
	move.w	#$8200,DMACON(a1)   ; DMAEN

.mainLoop:
	bra.b	.mainLoop

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
	dc.w    FMODEREG,FMODE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024
	dc.w    BPLCON3,BRDRBLNK        ; border forced to black
	dc.w    BPLCON4,$0011           ; BPLAM = $00 to begin with
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    DDFSTRT,DDF_START
	dc.w    DDFSTOP,DDF_STOP
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000

	; The four bitplane pointers, set once and then left to run: the data
	; repeats every word, so where in the buffer a line starts cannot be
	; seen.
bplPtrs:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000
	dc.w    BPL2PTH,$0000
	dc.w    BPL2PTL,$0000
	dc.w    BPL3PTH,$0000
	dc.w    BPL3PTL,$0000
	dc.w    BPL4PTH,$0000
	dc.w    BPL4PTL,$0000

	;
	; Section 1 (lines $30-$43): BPLAM = $00 -- reference: a plain four bitplane ramp
	;
	dc.w    $3001,$FFFE
	dc.w    BPLCON4,$0011           ; BPLAM = $00
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,DARKBLUE        ; put the background back
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
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $3101,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 2 (lines $44-$57): BPLAM = $01 -- permutes the ramp within its own range
	;
	dc.w    $4401,$FFFE
	dc.w    BPLCON4,$0111           ; BPLAM = $01
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $4400+DDF_START+1,$FFFE
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
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $4501,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 3 (lines $58-$6B): BPLAM = $02 -- permutes the ramp within its own range
	;
	dc.w    $5801,$FFFE
	dc.w    BPLCON4,$0211           ; BPLAM = $02
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $5800+DDF_START+1,$FFFE
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
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $5901,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 4 (lines $6C-$7F): BPLAM = $04 -- permutes the ramp within its own range
	;
	dc.w    $6C01,$FFFE
	dc.w    BPLCON4,$0411           ; BPLAM = $04
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $6C00+DDF_START+1,$FFFE
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
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $6D01,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 5 (lines $80-$93): BPLAM = $08 -- permutes the ramp within its own range
	;
	dc.w    $8001,$FFFE
	dc.w    BPLCON4,$0811           ; BPLAM = $08
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $8000+DDF_START+1,$FFFE
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
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $8101,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 6 (lines $94-$A7): BPLAM = $10 -- lifts the whole ramp into a higher register block
	;
	dc.w    $9401,$FFFE
	dc.w    BPLCON4,$1011           ; BPLAM = $10
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $9400+DDF_START+1,$FFFE
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
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $9501,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 7 (lines $A8-$BB): BPLAM = $20 -- lifts the whole ramp into a higher register block
	;
	dc.w    $A801,$FFFE
	dc.w    BPLCON4,$2011           ; BPLAM = $20
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $A800+DDF_START+1,$FFFE
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
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $A901,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 8 (lines $BC-$CF): BPLAM = $40 -- lifts the whole ramp into a higher register block
	;
	dc.w    $BC01,$FFFE
	dc.w    BPLCON4,$4011           ; BPLAM = $40
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $BC00+DDF_START+1,$FFFE
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
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $BD01,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 9 (lines $D0-$E3): BPLAM = $80 -- lifts the whole ramp into a higher register block
	;
	dc.w    $D001,$FFFE
	dc.w    BPLCON4,$8011           ; BPLAM = $80
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $D000+DDF_START+1,$FFFE
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
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $D101,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Section 10 (lines $E4-$F7): BPLAM = $FF -- every bit inverted
	;
	dc.w    $E401,$FFFE
	dc.w    BPLCON4,$FF11           ; BPLAM = $FF
	dc.w    BPLCON0,BPLCON0_OFF     ; ruler line: give the copper every slot
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $E400+DDF_START+1,$FFFE
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
	dc.w    COLOR00,DARKBLUE        ; put the background back
	dc.w    $E501,$FFFE
	dc.w    BPLCON0,BPLCON0_ON

	;
	; Done -- shut the display down again.
	;
	dc.w    $F801,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON4,$0011

	dc.l    $fffffffe

	cnop    0,8
bitBuf0: ds.b PLANE_SIZE
	cnop    0,8
bitBuf1: ds.b PLANE_SIZE
	cnop    0,8
bitBuf2: ds.b PLANE_SIZE
	cnop    0,8
bitBuf3: ds.b PLANE_SIZE
