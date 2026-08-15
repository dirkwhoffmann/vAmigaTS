;
; This file is included by diwclip1.s, diwclip2.s, ... Each of those defines
; DDF_START and then includes this body.
;
; diwclip.i -- is the drawable sprite area delimited by DIW alone?
;
; The companion of newclip1 ... newclip8 in this same directory. Those tests
; park a sprite at the left edge of the display window, hold DDFSTRT fixed
; within a frame and sweep BPLCON1 down the screen. This suite holds the
; sprite still and sweeps the DISPLAY WINDOW across it instead, block by
; block, while DDFSTRT is what varies from test to test.
;
;
; THE QUESTION
; ------------
;
; Denise stops drawing sprites outside the display window, but the display
; window has two gates, not one. DIWSTRT and DIWSTOP set a horizontal
; flipflop, and the first write to BPL1DAT in a rasterline arms the output.
; A sprite could plausibly be clipped by either, and the two only differ in
; the stretch between DIWSTRT and the first bitplane word -- which is why
; the sweep here deliberately starts LEFT of the data and ends right of it.
;
;   clipped by DIW alone     the bar's left edge follows DIWSTRT for the
;                            whole sweep, one step per block
;
;   clipped by BPL1DAT too   the bar's left edge sits still at the first
;                            data pixel while DIWSTRT is left of it, and
;                            only starts moving once DIWSTRT passes it
;
; The second reading puts a knee in the staircase, and the position of that
; knee measures where the bitplane data begins. Moving DDFSTRT from test to
; test moves the knee; it cannot move a staircase that has no knee.
;
;
; READING THE PICTURE
; -------------------
;
; BRDRBLNK (BPLCON3 bit 5) is set for the whole frame apart from the ruler
; lines, so the border is pure black, while COLOR00 inside the window is
; dark grey. ECSENA (BPLCON0 bit 0) is set throughout, because BRDRBLNK
; does nothing without it. One bitplane is enabled and its buffer is filled
; with $FFFF, so the data is a flat hue rather than a comb: every edge on
; screen is a window edge or a sprite edge, and none of them is a texture.
;
; Each rasterline therefore reads as
;
;   black         border
;   a flat hue    the bitplane data
;   dark grey     data finished, window still open
;   black         border
;
; and the dark grey stretch between DIWSTRT and the data -- the one the
; first reading above predicts and the second forbids -- is the second,
; independent answer to the same question. It needs no sprite at all.
;
;
; THE TWO PROBES
; --------------
;
; Sprites 0 to 3 sit side by side from $06F, forming one solid 64 pixel bar,
; and DIWSTRT sweeps $6F ... $AB across it in steps of four. This is the
; measurement. At DDFSTRT $38 the data begins at $7F, four lores pixels
; further right for every step DDFSTRT takes, so the sweep starts left of
; the data in all eight tests and ends right of it in all eight, and the
; knee walks down the screen from block 4 in diwclip1 to block 11 in
; diwclip8.
;
; Sprites 4 to 7 do the same from $181, with DIWSTOP sweeping $181 ... $1BD
; across them. This is the control. BPL1DAT has long
; since been written by the time the beam arrives there, so both readings
; predict the same thing -- the bar's right edge tracks DIWSTOP exactly --
; and a right probe that does not behave means the sweep itself is wrong,
; not that anything has been learnt about the left one.
;
; DIWSTOP never exceeds $1C7, the largest value Denise's counter can match.
;
;
; BORDER SPRITES
; --------------
;
; diwclip1a is diwclip1 with BRDRSPRT, BPLCON3 bit 1, set for the whole
; frame. That bit is supposed to let sprites be drawn in the border area,
; and both emulators say it cannot do so here:
;
;   it is AGA only         so on the ECS Denise these tests record their
;                          references on, it does nothing whatever
;
;   BRDRBLNK overrules it  a blanked border takes no sprites, whatever
;                          BRDRSPRT says
;
; Neither claim has ever been checked against hardware, and the second one
; is the interesting one, so diwclip1a asks both questions in a single
; frame. BRDRSPRT is set throughout, and the border stays blanked for the
; lores and hires sections but is UNBLANKED for the super hires section.
;
;   lores, hires    if BRDRBLNK really does overrule BRDRSPRT, these two
;                   sections are pixel for pixel identical to diwclip1
;
;   super hires     with nothing to overrule it, BRDRSPRT should take
;                   effect on AGA: the bar stops being clipped at the
;                   window edge and the staircase goes flat
;
; On the ECS reference the super hires section still shows the staircase,
; with the border in dark grey rather than black because COLOR00 paints it.
; A flat bar there would mean the emulation has begun honouring an AGA bit
; on a chipset that does not have it.
;
;
; THE BLOCKS
; ----------
;
; Three sections of sixteen four-line blocks: lores, hires and super hires,
; with a Copper ruler between each pair. A block writes DIWSTRT and DIWSTOP
; on its first line and carries a three-line slice of both bars on the rest,
; so the window advances by four lores pixels from one bar slice to the next
; and the bars come out as staircases.
;
; The rulers are the ddf1 stripe train started at h=$31 and run out to 44
; stripes, so that the scale covers both probes rather than only the middle
; of the line. They are drawn on plane-less lines with BRDRBLNK cleared,
; because a plane-less line is border across its full width.
;

	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

LVL3_INT_VECTOR     equ $6C

BPLCON3             equ $106           ; ECS and AGA
BRDRBLNK            equ $0020          ; BPLCON3 bit 5
BRDRSPRT            equ $0002          ; BPLCON3 bit 1, AGA only

; ECSENA (bit 0) must be set for BRDRBLNK to do anything, so it is part
; of every BPLCON0 value used here, the plane-less one included.
BPLCON0_OFF         equ $0201
LORES_BITS          equ $0201
HIRES_BITS          equ $8201
SHRES_BITS          equ $0241          ; bit 6 alone selects super hires

DDF_STOP            equ $00D0
DIW_STRT0           equ $6F
DIW_STOP0           equ $81

DARKGREY            equ $444           ; window, where no data arrived
BLACK               equ $000           ; COLOR00 around the rulers
SPR_LEFT            equ $FF0           ; the DIWSTRT probe
SPR_RIGHT           equ $0FF           ; the DIWSTOP probe
HUE_LORES           equ $66F
HUE_HIRES           equ $B6F
HUE_SHRES           equ $F6F

BUF_SIZE            equ 16384

MAIN:
	lea     CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #BPLCON0_OFF,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01

	; Install the interrupt handler
	lea     irq3(pc),a3
	move.l  a3,LVL3_INT_VECTOR

	; Fill the bitplane buffer with solid ones, so the data is a flat
	; hue and every edge in the picture is a window or a sprite edge
	lea     bitplanes(pc),a0
	move.w  #(BUF_SIZE/2)-1,d0
.fill:
	move.w  #$FFFF,(a0)+
	dbra    d0,.fill

	; Fill in the three bitplane pointer reloads in the Copper list
	lea     bitplanes(pc),a0
	move.l  a0,d0
	lea     bplptr_lores(pc),a2
	move.w  d0,6(a2)            ; low word  -> BPL1PTL
	swap    d0
	move.w  d0,2(a2)            ; high word -> BPL1PTH
	move.l  a0,d0
	lea     bplptr_hires(pc),a2
	move.w  d0,6(a2)            ; low word  -> BPL1PTL
	swap    d0
	move.w  d0,2(a2)            ; high word -> BPL1PTH
	move.l  a0,d0
	lea     bplptr_shres(pc),a2
	move.w  d0,6(a2)            ; low word  -> BPL1PTL
	swap    d0
	move.w  d0,2(a2)            ; high word -> BPL1PTH

	; Install the Copper list
	lea     copper(pc),a0
	move.l  a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w  #$8020,DMACON(a1)   ; Sprite DMA
	move.w  #$8080,DMACON(a1)   ; Copper DMA
	move.w  #$8100,DMACON(a1)   ; Bitplane DMA
	move.w  #$8200,DMACON(a1)   ; DMAEN

	move.w  #$C020,INTENA(a1)
.mainLoop:
	bra.b   .mainLoop

irq3:
	movem.l d0-a6,-(sp)
	move.w  #$3FFF,INTREQ(a1)

	lea     bitplanes(pc),a2
	lea     BPL1PTH(a1),a3
	move.l  a2,(a3)

	lea     sprite0(pc),a2
	lea     SPR0PTH(a1),a3
	move.l  a2,(a3)
	lea     sprite1(pc),a2
	lea     SPR1PTH(a1),a3
	move.l  a2,(a3)
	lea     sprite2(pc),a2
	lea     SPR2PTH(a1),a3
	move.l  a2,(a3)
	lea     sprite3(pc),a2
	lea     SPR3PTH(a1),a3
	move.l  a2,(a3)
	lea     sprite4(pc),a2
	lea     SPR4PTH(a1),a3
	move.l  a2,(a3)
	lea     sprite5(pc),a2
	lea     SPR5PTH(a1),a3
	move.l  a2,(a3)
	lea     sprite6(pc),a2
	lea     SPR6PTH(a1),a3
	move.l  a2,(a3)
	lea     sprite7(pc),a2
	lea     SPR7PTH(a1),a3
	move.l  a2,(a3)

	movem.l (sp)+,d0-a6
	rte

copper:
	dc.w    BPLCON1,$0000           ; no scroll anywhere in this test
	dc.w    BPLCON2,$0024           ; both playfields behind all sprites
	dc.w    BPLCON3,CON3_MAIN
	dc.w    DDFSTRT,DDF_START
	dc.w    DDFSTOP,DDF_STOP
	dc.w    DIWSTRT,$2C00|DIW_STRT0
	dc.w    DIWSTOP,$2C00|DIW_STOP0
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000
	dc.w    COLOR00,DARKGREY
	dc.w    COLOR17,SPR_LEFT        ; sprites 0-3 make one 64 pixel bar
	dc.w    COLOR21,SPR_LEFT
	dc.w    COLOR25,SPR_RIGHT       ; sprites 4-7 make the other
	dc.w    COLOR29,SPR_RIGHT

	;
	; LORES section, lines $30-$6F
	;
	dc.w    $3001,$FFFE
	dc.w    BPLCON0,(1<<12)|LORES_BITS
	dc.w    COLOR01,HUE_LORES
	; A preceding ruler leaves COLOR00 black, and the super hires
	; section may run with the border unblanked, where COLOR00 is
	; what paints it.
	dc.w    COLOR00,DARKGREY
	; The bitplane pointer is reloaded here rather than once per frame.
	; Super hires fetches four times as many words per line as lores, so
	; a single frame would read past the end of a modest buffer; this
	; bounds the drift to one section. The two words are filled in by
	; MAIN, which is the only place that knows where the buffer landed.
bplptr_lores:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000

	dc.w    $3001,$FFFE
	dc.w    DIWSTRT,$2C00|$6F
	dc.w    DIWSTOP,$2C00|$81      ; window $6F ... $181
	dc.w    $3401,$FFFE
	dc.w    DIWSTRT,$2C00|$73
	dc.w    DIWSTOP,$2C00|$85      ; window $73 ... $185
	dc.w    $3801,$FFFE
	dc.w    DIWSTRT,$2C00|$77
	dc.w    DIWSTOP,$2C00|$89      ; window $77 ... $189
	dc.w    $3C01,$FFFE
	dc.w    DIWSTRT,$2C00|$7B
	dc.w    DIWSTOP,$2C00|$8D      ; window $7B ... $18D
	dc.w    $4001,$FFFE
	dc.w    DIWSTRT,$2C00|$7F
	dc.w    DIWSTOP,$2C00|$91      ; window $7F ... $191
	dc.w    $4401,$FFFE
	dc.w    DIWSTRT,$2C00|$83
	dc.w    DIWSTOP,$2C00|$95      ; window $83 ... $195
	dc.w    $4801,$FFFE
	dc.w    DIWSTRT,$2C00|$87
	dc.w    DIWSTOP,$2C00|$99      ; window $87 ... $199
	dc.w    $4C01,$FFFE
	dc.w    DIWSTRT,$2C00|$8B
	dc.w    DIWSTOP,$2C00|$9D      ; window $8B ... $19D
	dc.w    $5001,$FFFE
	dc.w    DIWSTRT,$2C00|$8F
	dc.w    DIWSTOP,$2C00|$A1      ; window $8F ... $1A1
	dc.w    $5401,$FFFE
	dc.w    DIWSTRT,$2C00|$93
	dc.w    DIWSTOP,$2C00|$A5      ; window $93 ... $1A5
	dc.w    $5801,$FFFE
	dc.w    DIWSTRT,$2C00|$97
	dc.w    DIWSTOP,$2C00|$A9      ; window $97 ... $1A9
	dc.w    $5C01,$FFFE
	dc.w    DIWSTRT,$2C00|$9B
	dc.w    DIWSTOP,$2C00|$AD      ; window $9B ... $1AD
	dc.w    $6001,$FFFE
	dc.w    DIWSTRT,$2C00|$9F
	dc.w    DIWSTOP,$2C00|$B1      ; window $9F ... $1B1
	dc.w    $6401,$FFFE
	dc.w    DIWSTRT,$2C00|$A3
	dc.w    DIWSTOP,$2C00|$B5      ; window $A3 ... $1B5
	dc.w    $6801,$FFFE
	dc.w    DIWSTRT,$2C00|$A7
	dc.w    DIWSTOP,$2C00|$B9      ; window $A7 ... $1B9
	dc.w    $6C01,$FFFE
	dc.w    DIWSTRT,$2C00|$AB
	dc.w    DIWSTOP,$2C00|$BD      ; window $AB ... $1BD

	dc.w    $7001,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000           ; bank 0, LOCT=0, BRDRBLNK off
	; With no bitplanes the whole rasterline is border, so a blanked
	; border would swallow the ruler; see Denise/Registers/BPLCON3/brdrblnk2.
	; COLOR00 is forced to black so the unblanked border matches the
	; blanked lines above and below instead of showing the dark grey.
	dc.w    COLOR00,BLACK
	dc.w    $7131,$FFFE
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
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$0F0
	dc.w    $7201,$FFFE
	dc.w    COLOR00,BLACK
	dc.w    BPLCON3,CON3_MAIN       ; border configuration restored

	;
	; HIRES section, lines $74-$B3
	;
	dc.w    $7401,$FFFE
	dc.w    BPLCON0,(1<<12)|HIRES_BITS
	dc.w    COLOR01,HUE_HIRES
	; A preceding ruler leaves COLOR00 black, and the super hires
	; section may run with the border unblanked, where COLOR00 is
	; what paints it.
	dc.w    COLOR00,DARKGREY
	; The bitplane pointer is reloaded here rather than once per frame.
	; Super hires fetches four times as many words per line as lores, so
	; a single frame would read past the end of a modest buffer; this
	; bounds the drift to one section. The two words are filled in by
	; MAIN, which is the only place that knows where the buffer landed.
bplptr_hires:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000

	dc.w    $7401,$FFFE
	dc.w    DIWSTRT,$2C00|$6F
	dc.w    DIWSTOP,$2C00|$81      ; window $6F ... $181
	dc.w    $7801,$FFFE
	dc.w    DIWSTRT,$2C00|$73
	dc.w    DIWSTOP,$2C00|$85      ; window $73 ... $185
	dc.w    $7C01,$FFFE
	dc.w    DIWSTRT,$2C00|$77
	dc.w    DIWSTOP,$2C00|$89      ; window $77 ... $189
	dc.w    $8001,$FFFE
	dc.w    DIWSTRT,$2C00|$7B
	dc.w    DIWSTOP,$2C00|$8D      ; window $7B ... $18D
	dc.w    $8401,$FFFE
	dc.w    DIWSTRT,$2C00|$7F
	dc.w    DIWSTOP,$2C00|$91      ; window $7F ... $191
	dc.w    $8801,$FFFE
	dc.w    DIWSTRT,$2C00|$83
	dc.w    DIWSTOP,$2C00|$95      ; window $83 ... $195
	dc.w    $8C01,$FFFE
	dc.w    DIWSTRT,$2C00|$87
	dc.w    DIWSTOP,$2C00|$99      ; window $87 ... $199
	dc.w    $9001,$FFFE
	dc.w    DIWSTRT,$2C00|$8B
	dc.w    DIWSTOP,$2C00|$9D      ; window $8B ... $19D
	dc.w    $9401,$FFFE
	dc.w    DIWSTRT,$2C00|$8F
	dc.w    DIWSTOP,$2C00|$A1      ; window $8F ... $1A1
	dc.w    $9801,$FFFE
	dc.w    DIWSTRT,$2C00|$93
	dc.w    DIWSTOP,$2C00|$A5      ; window $93 ... $1A5
	dc.w    $9C01,$FFFE
	dc.w    DIWSTRT,$2C00|$97
	dc.w    DIWSTOP,$2C00|$A9      ; window $97 ... $1A9
	dc.w    $A001,$FFFE
	dc.w    DIWSTRT,$2C00|$9B
	dc.w    DIWSTOP,$2C00|$AD      ; window $9B ... $1AD
	dc.w    $A401,$FFFE
	dc.w    DIWSTRT,$2C00|$9F
	dc.w    DIWSTOP,$2C00|$B1      ; window $9F ... $1B1
	dc.w    $A801,$FFFE
	dc.w    DIWSTRT,$2C00|$A3
	dc.w    DIWSTOP,$2C00|$B5      ; window $A3 ... $1B5
	dc.w    $AC01,$FFFE
	dc.w    DIWSTRT,$2C00|$A7
	dc.w    DIWSTOP,$2C00|$B9      ; window $A7 ... $1B9
	dc.w    $B001,$FFFE
	dc.w    DIWSTRT,$2C00|$AB
	dc.w    DIWSTOP,$2C00|$BD      ; window $AB ... $1BD

	dc.w    $B401,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON3,$0000           ; bank 0, LOCT=0, BRDRBLNK off
	; With no bitplanes the whole rasterline is border, so a blanked
	; border would swallow the ruler; see Denise/Registers/BPLCON3/brdrblnk2.
	; COLOR00 is forced to black so the unblanked border matches the
	; blanked lines above and below instead of showing the dark grey.
	dc.w    COLOR00,BLACK
	dc.w    $B531,$FFFE
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
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$00A
	dc.w    COLOR00,$0F0
	dc.w    $B601,$FFFE
	dc.w    COLOR00,BLACK
	dc.w    BPLCON3,CON3_MAIN       ; border configuration restored

	;
	; SHRES section, lines $B8-$F7
	;
	dc.w    $B801,$FFFE
	dc.w    BPLCON0,(1<<12)|SHRES_BITS
	dc.w    COLOR01,HUE_SHRES
	; A preceding ruler leaves COLOR00 black, and the super hires
	; section may run with the border unblanked, where COLOR00 is
	; what paints it.
	dc.w    COLOR00,DARKGREY
	dc.w    BPLCON3,CON3_SHRES
	; The bitplane pointer is reloaded here rather than once per frame.
	; Super hires fetches four times as many words per line as lores, so
	; a single frame would read past the end of a modest buffer; this
	; bounds the drift to one section. The two words are filled in by
	; MAIN, which is the only place that knows where the buffer landed.
bplptr_shres:
	dc.w    BPL1PTH,$0000
	dc.w    BPL1PTL,$0000

	dc.w    $B801,$FFFE
	dc.w    DIWSTRT,$2C00|$6F
	dc.w    DIWSTOP,$2C00|$81      ; window $6F ... $181
	dc.w    $BC01,$FFFE
	dc.w    DIWSTRT,$2C00|$73
	dc.w    DIWSTOP,$2C00|$85      ; window $73 ... $185
	dc.w    $C001,$FFFE
	dc.w    DIWSTRT,$2C00|$77
	dc.w    DIWSTOP,$2C00|$89      ; window $77 ... $189
	dc.w    $C401,$FFFE
	dc.w    DIWSTRT,$2C00|$7B
	dc.w    DIWSTOP,$2C00|$8D      ; window $7B ... $18D
	dc.w    $C801,$FFFE
	dc.w    DIWSTRT,$2C00|$7F
	dc.w    DIWSTOP,$2C00|$91      ; window $7F ... $191
	dc.w    $CC01,$FFFE
	dc.w    DIWSTRT,$2C00|$83
	dc.w    DIWSTOP,$2C00|$95      ; window $83 ... $195
	dc.w    $D001,$FFFE
	dc.w    DIWSTRT,$2C00|$87
	dc.w    DIWSTOP,$2C00|$99      ; window $87 ... $199
	dc.w    $D401,$FFFE
	dc.w    DIWSTRT,$2C00|$8B
	dc.w    DIWSTOP,$2C00|$9D      ; window $8B ... $19D
	dc.w    $D801,$FFFE
	dc.w    DIWSTRT,$2C00|$8F
	dc.w    DIWSTOP,$2C00|$A1      ; window $8F ... $1A1
	dc.w    $DC01,$FFFE
	dc.w    DIWSTRT,$2C00|$93
	dc.w    DIWSTOP,$2C00|$A5      ; window $93 ... $1A5
	dc.w    $E001,$FFFE
	dc.w    DIWSTRT,$2C00|$97
	dc.w    DIWSTOP,$2C00|$A9      ; window $97 ... $1A9
	dc.w    $E401,$FFFE
	dc.w    DIWSTRT,$2C00|$9B
	dc.w    DIWSTOP,$2C00|$AD      ; window $9B ... $1AD
	dc.w    $E801,$FFFE
	dc.w    DIWSTRT,$2C00|$9F
	dc.w    DIWSTOP,$2C00|$B1      ; window $9F ... $1B1
	dc.w    $EC01,$FFFE
	dc.w    DIWSTRT,$2C00|$A3
	dc.w    DIWSTOP,$2C00|$B5      ; window $A3 ... $1B5
	dc.w    $F001,$FFFE
	dc.w    DIWSTRT,$2C00|$A7
	dc.w    DIWSTOP,$2C00|$B9      ; window $A7 ... $1B9
	dc.w    $F401,$FFFE
	dc.w    DIWSTRT,$2C00|$AB
	dc.w    DIWSTOP,$2C00|$BD      ; window $AB ... $1BD

	dc.w    $F801,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.l    $FFFFFFFE

sprite0:
	; left probe, pixels $06F-$07E
	dc.w    $3137,$3401          ; block at line $31
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $3537,$3801          ; block at line $35
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $3937,$3C01          ; block at line $39
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $3D37,$4001          ; block at line $3D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4137,$4401          ; block at line $41
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4537,$4801          ; block at line $45
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4937,$4C01          ; block at line $49
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4D37,$5001          ; block at line $4D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5137,$5401          ; block at line $51
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5537,$5801          ; block at line $55
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5937,$5C01          ; block at line $59
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5D37,$6001          ; block at line $5D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6137,$6401          ; block at line $61
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6537,$6801          ; block at line $65
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6937,$6C01          ; block at line $69
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6D37,$7001          ; block at line $6D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $7537,$7801          ; block at line $75
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $7937,$7C01          ; block at line $79
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $7D37,$8001          ; block at line $7D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8137,$8401          ; block at line $81
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8537,$8801          ; block at line $85
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8937,$8C01          ; block at line $89
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8D37,$9001          ; block at line $8D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9137,$9401          ; block at line $91
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9537,$9801          ; block at line $95
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9937,$9C01          ; block at line $99
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9D37,$A001          ; block at line $9D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A137,$A401          ; block at line $A1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A537,$A801          ; block at line $A5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A937,$AC01          ; block at line $A9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $AD37,$B001          ; block at line $AD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B137,$B401          ; block at line $B1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B937,$BC01          ; block at line $B9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $BD37,$C001          ; block at line $BD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C137,$C401          ; block at line $C1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C537,$C801          ; block at line $C5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C937,$CC01          ; block at line $C9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $CD37,$D001          ; block at line $CD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D137,$D401          ; block at line $D1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D537,$D801          ; block at line $D5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D937,$DC01          ; block at line $D9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $DD37,$E001          ; block at line $DD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E137,$E401          ; block at line $E1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E537,$E801          ; block at line $E5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E937,$EC01          ; block at line $E9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $ED37,$F001          ; block at line $ED
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F137,$F401          ; block at line $F1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F537,$F801          ; block at line $F5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $0000,$0000          ; end of list

sprite1:
	; left probe, pixels $07F-$08E
	dc.w    $313F,$3401          ; block at line $31
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $353F,$3801          ; block at line $35
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $393F,$3C01          ; block at line $39
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $3D3F,$4001          ; block at line $3D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $413F,$4401          ; block at line $41
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $453F,$4801          ; block at line $45
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $493F,$4C01          ; block at line $49
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4D3F,$5001          ; block at line $4D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $513F,$5401          ; block at line $51
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $553F,$5801          ; block at line $55
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $593F,$5C01          ; block at line $59
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5D3F,$6001          ; block at line $5D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $613F,$6401          ; block at line $61
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $653F,$6801          ; block at line $65
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $693F,$6C01          ; block at line $69
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6D3F,$7001          ; block at line $6D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $753F,$7801          ; block at line $75
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $793F,$7C01          ; block at line $79
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $7D3F,$8001          ; block at line $7D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $813F,$8401          ; block at line $81
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $853F,$8801          ; block at line $85
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $893F,$8C01          ; block at line $89
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8D3F,$9001          ; block at line $8D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $913F,$9401          ; block at line $91
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $953F,$9801          ; block at line $95
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $993F,$9C01          ; block at line $99
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9D3F,$A001          ; block at line $9D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A13F,$A401          ; block at line $A1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A53F,$A801          ; block at line $A5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A93F,$AC01          ; block at line $A9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $AD3F,$B001          ; block at line $AD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B13F,$B401          ; block at line $B1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B93F,$BC01          ; block at line $B9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $BD3F,$C001          ; block at line $BD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C13F,$C401          ; block at line $C1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C53F,$C801          ; block at line $C5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C93F,$CC01          ; block at line $C9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $CD3F,$D001          ; block at line $CD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D13F,$D401          ; block at line $D1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D53F,$D801          ; block at line $D5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D93F,$DC01          ; block at line $D9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $DD3F,$E001          ; block at line $DD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E13F,$E401          ; block at line $E1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E53F,$E801          ; block at line $E5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E93F,$EC01          ; block at line $E9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $ED3F,$F001          ; block at line $ED
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F13F,$F401          ; block at line $F1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F53F,$F801          ; block at line $F5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $0000,$0000          ; end of list

sprite2:
	; left probe, pixels $08F-$09E
	dc.w    $3147,$3401          ; block at line $31
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $3547,$3801          ; block at line $35
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $3947,$3C01          ; block at line $39
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $3D47,$4001          ; block at line $3D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4147,$4401          ; block at line $41
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4547,$4801          ; block at line $45
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4947,$4C01          ; block at line $49
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4D47,$5001          ; block at line $4D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5147,$5401          ; block at line $51
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5547,$5801          ; block at line $55
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5947,$5C01          ; block at line $59
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5D47,$6001          ; block at line $5D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6147,$6401          ; block at line $61
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6547,$6801          ; block at line $65
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6947,$6C01          ; block at line $69
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6D47,$7001          ; block at line $6D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $7547,$7801          ; block at line $75
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $7947,$7C01          ; block at line $79
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $7D47,$8001          ; block at line $7D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8147,$8401          ; block at line $81
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8547,$8801          ; block at line $85
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8947,$8C01          ; block at line $89
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8D47,$9001          ; block at line $8D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9147,$9401          ; block at line $91
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9547,$9801          ; block at line $95
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9947,$9C01          ; block at line $99
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9D47,$A001          ; block at line $9D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A147,$A401          ; block at line $A1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A547,$A801          ; block at line $A5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A947,$AC01          ; block at line $A9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $AD47,$B001          ; block at line $AD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B147,$B401          ; block at line $B1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B947,$BC01          ; block at line $B9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $BD47,$C001          ; block at line $BD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C147,$C401          ; block at line $C1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C547,$C801          ; block at line $C5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C947,$CC01          ; block at line $C9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $CD47,$D001          ; block at line $CD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D147,$D401          ; block at line $D1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D547,$D801          ; block at line $D5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D947,$DC01          ; block at line $D9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $DD47,$E001          ; block at line $DD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E147,$E401          ; block at line $E1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E547,$E801          ; block at line $E5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E947,$EC01          ; block at line $E9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $ED47,$F001          ; block at line $ED
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F147,$F401          ; block at line $F1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F547,$F801          ; block at line $F5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $0000,$0000          ; end of list

sprite3:
	; left probe, pixels $09F-$0AE
	dc.w    $314F,$3401          ; block at line $31
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $354F,$3801          ; block at line $35
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $394F,$3C01          ; block at line $39
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $3D4F,$4001          ; block at line $3D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $414F,$4401          ; block at line $41
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $454F,$4801          ; block at line $45
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $494F,$4C01          ; block at line $49
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4D4F,$5001          ; block at line $4D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $514F,$5401          ; block at line $51
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $554F,$5801          ; block at line $55
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $594F,$5C01          ; block at line $59
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5D4F,$6001          ; block at line $5D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $614F,$6401          ; block at line $61
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $654F,$6801          ; block at line $65
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $694F,$6C01          ; block at line $69
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6D4F,$7001          ; block at line $6D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $754F,$7801          ; block at line $75
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $794F,$7C01          ; block at line $79
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $7D4F,$8001          ; block at line $7D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $814F,$8401          ; block at line $81
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $854F,$8801          ; block at line $85
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $894F,$8C01          ; block at line $89
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8D4F,$9001          ; block at line $8D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $914F,$9401          ; block at line $91
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $954F,$9801          ; block at line $95
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $994F,$9C01          ; block at line $99
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9D4F,$A001          ; block at line $9D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A14F,$A401          ; block at line $A1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A54F,$A801          ; block at line $A5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A94F,$AC01          ; block at line $A9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $AD4F,$B001          ; block at line $AD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B14F,$B401          ; block at line $B1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B94F,$BC01          ; block at line $B9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $BD4F,$C001          ; block at line $BD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C14F,$C401          ; block at line $C1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C54F,$C801          ; block at line $C5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C94F,$CC01          ; block at line $C9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $CD4F,$D001          ; block at line $CD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D14F,$D401          ; block at line $D1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D54F,$D801          ; block at line $D5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D94F,$DC01          ; block at line $D9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $DD4F,$E001          ; block at line $DD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E14F,$E401          ; block at line $E1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E54F,$E801          ; block at line $E5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E94F,$EC01          ; block at line $E9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $ED4F,$F001          ; block at line $ED
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F14F,$F401          ; block at line $F1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F54F,$F801          ; block at line $F5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $0000,$0000          ; end of list

sprite4:
	; right probe, pixels $181-$190
	dc.w    $31C0,$3401          ; block at line $31
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $35C0,$3801          ; block at line $35
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $39C0,$3C01          ; block at line $39
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $3DC0,$4001          ; block at line $3D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $41C0,$4401          ; block at line $41
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $45C0,$4801          ; block at line $45
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $49C0,$4C01          ; block at line $49
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4DC0,$5001          ; block at line $4D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $51C0,$5401          ; block at line $51
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $55C0,$5801          ; block at line $55
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $59C0,$5C01          ; block at line $59
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5DC0,$6001          ; block at line $5D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $61C0,$6401          ; block at line $61
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $65C0,$6801          ; block at line $65
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $69C0,$6C01          ; block at line $69
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6DC0,$7001          ; block at line $6D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $75C0,$7801          ; block at line $75
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $79C0,$7C01          ; block at line $79
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $7DC0,$8001          ; block at line $7D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $81C0,$8401          ; block at line $81
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $85C0,$8801          ; block at line $85
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $89C0,$8C01          ; block at line $89
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8DC0,$9001          ; block at line $8D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $91C0,$9401          ; block at line $91
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $95C0,$9801          ; block at line $95
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $99C0,$9C01          ; block at line $99
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9DC0,$A001          ; block at line $9D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A1C0,$A401          ; block at line $A1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A5C0,$A801          ; block at line $A5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A9C0,$AC01          ; block at line $A9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $ADC0,$B001          ; block at line $AD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B1C0,$B401          ; block at line $B1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B9C0,$BC01          ; block at line $B9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $BDC0,$C001          ; block at line $BD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C1C0,$C401          ; block at line $C1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C5C0,$C801          ; block at line $C5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C9C0,$CC01          ; block at line $C9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $CDC0,$D001          ; block at line $CD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D1C0,$D401          ; block at line $D1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D5C0,$D801          ; block at line $D5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D9C0,$DC01          ; block at line $D9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $DDC0,$E001          ; block at line $DD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E1C0,$E401          ; block at line $E1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E5C0,$E801          ; block at line $E5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E9C0,$EC01          ; block at line $E9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $EDC0,$F001          ; block at line $ED
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F1C0,$F401          ; block at line $F1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F5C0,$F801          ; block at line $F5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $0000,$0000          ; end of list

sprite5:
	; right probe, pixels $191-$1A0
	dc.w    $31C8,$3401          ; block at line $31
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $35C8,$3801          ; block at line $35
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $39C8,$3C01          ; block at line $39
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $3DC8,$4001          ; block at line $3D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $41C8,$4401          ; block at line $41
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $45C8,$4801          ; block at line $45
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $49C8,$4C01          ; block at line $49
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4DC8,$5001          ; block at line $4D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $51C8,$5401          ; block at line $51
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $55C8,$5801          ; block at line $55
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $59C8,$5C01          ; block at line $59
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5DC8,$6001          ; block at line $5D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $61C8,$6401          ; block at line $61
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $65C8,$6801          ; block at line $65
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $69C8,$6C01          ; block at line $69
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6DC8,$7001          ; block at line $6D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $75C8,$7801          ; block at line $75
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $79C8,$7C01          ; block at line $79
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $7DC8,$8001          ; block at line $7D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $81C8,$8401          ; block at line $81
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $85C8,$8801          ; block at line $85
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $89C8,$8C01          ; block at line $89
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8DC8,$9001          ; block at line $8D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $91C8,$9401          ; block at line $91
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $95C8,$9801          ; block at line $95
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $99C8,$9C01          ; block at line $99
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9DC8,$A001          ; block at line $9D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A1C8,$A401          ; block at line $A1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A5C8,$A801          ; block at line $A5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A9C8,$AC01          ; block at line $A9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $ADC8,$B001          ; block at line $AD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B1C8,$B401          ; block at line $B1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B9C8,$BC01          ; block at line $B9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $BDC8,$C001          ; block at line $BD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C1C8,$C401          ; block at line $C1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C5C8,$C801          ; block at line $C5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C9C8,$CC01          ; block at line $C9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $CDC8,$D001          ; block at line $CD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D1C8,$D401          ; block at line $D1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D5C8,$D801          ; block at line $D5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D9C8,$DC01          ; block at line $D9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $DDC8,$E001          ; block at line $DD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E1C8,$E401          ; block at line $E1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E5C8,$E801          ; block at line $E5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E9C8,$EC01          ; block at line $E9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $EDC8,$F001          ; block at line $ED
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F1C8,$F401          ; block at line $F1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F5C8,$F801          ; block at line $F5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $0000,$0000          ; end of list

sprite6:
	; right probe, pixels $1A1-$1B0
	dc.w    $31D0,$3401          ; block at line $31
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $35D0,$3801          ; block at line $35
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $39D0,$3C01          ; block at line $39
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $3DD0,$4001          ; block at line $3D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $41D0,$4401          ; block at line $41
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $45D0,$4801          ; block at line $45
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $49D0,$4C01          ; block at line $49
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4DD0,$5001          ; block at line $4D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $51D0,$5401          ; block at line $51
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $55D0,$5801          ; block at line $55
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $59D0,$5C01          ; block at line $59
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5DD0,$6001          ; block at line $5D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $61D0,$6401          ; block at line $61
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $65D0,$6801          ; block at line $65
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $69D0,$6C01          ; block at line $69
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6DD0,$7001          ; block at line $6D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $75D0,$7801          ; block at line $75
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $79D0,$7C01          ; block at line $79
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $7DD0,$8001          ; block at line $7D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $81D0,$8401          ; block at line $81
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $85D0,$8801          ; block at line $85
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $89D0,$8C01          ; block at line $89
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8DD0,$9001          ; block at line $8D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $91D0,$9401          ; block at line $91
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $95D0,$9801          ; block at line $95
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $99D0,$9C01          ; block at line $99
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9DD0,$A001          ; block at line $9D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A1D0,$A401          ; block at line $A1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A5D0,$A801          ; block at line $A5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A9D0,$AC01          ; block at line $A9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $ADD0,$B001          ; block at line $AD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B1D0,$B401          ; block at line $B1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B9D0,$BC01          ; block at line $B9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $BDD0,$C001          ; block at line $BD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C1D0,$C401          ; block at line $C1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C5D0,$C801          ; block at line $C5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C9D0,$CC01          ; block at line $C9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $CDD0,$D001          ; block at line $CD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D1D0,$D401          ; block at line $D1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D5D0,$D801          ; block at line $D5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D9D0,$DC01          ; block at line $D9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $DDD0,$E001          ; block at line $DD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E1D0,$E401          ; block at line $E1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E5D0,$E801          ; block at line $E5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E9D0,$EC01          ; block at line $E9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $EDD0,$F001          ; block at line $ED
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F1D0,$F401          ; block at line $F1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F5D0,$F801          ; block at line $F5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $0000,$0000          ; end of list

sprite7:
	; right probe, pixels $1B1-$1C0
	dc.w    $31D8,$3401          ; block at line $31
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $35D8,$3801          ; block at line $35
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $39D8,$3C01          ; block at line $39
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $3DD8,$4001          ; block at line $3D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $41D8,$4401          ; block at line $41
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $45D8,$4801          ; block at line $45
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $49D8,$4C01          ; block at line $49
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $4DD8,$5001          ; block at line $4D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $51D8,$5401          ; block at line $51
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $55D8,$5801          ; block at line $55
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $59D8,$5C01          ; block at line $59
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $5DD8,$6001          ; block at line $5D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $61D8,$6401          ; block at line $61
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $65D8,$6801          ; block at line $65
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $69D8,$6C01          ; block at line $69
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $6DD8,$7001          ; block at line $6D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $75D8,$7801          ; block at line $75
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $79D8,$7C01          ; block at line $79
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $7DD8,$8001          ; block at line $7D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $81D8,$8401          ; block at line $81
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $85D8,$8801          ; block at line $85
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $89D8,$8C01          ; block at line $89
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $8DD8,$9001          ; block at line $8D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $91D8,$9401          ; block at line $91
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $95D8,$9801          ; block at line $95
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $99D8,$9C01          ; block at line $99
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $9DD8,$A001          ; block at line $9D
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A1D8,$A401          ; block at line $A1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A5D8,$A801          ; block at line $A5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $A9D8,$AC01          ; block at line $A9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $ADD8,$B001          ; block at line $AD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B1D8,$B401          ; block at line $B1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $B9D8,$BC01          ; block at line $B9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $BDD8,$C001          ; block at line $BD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C1D8,$C401          ; block at line $C1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C5D8,$C801          ; block at line $C5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $C9D8,$CC01          ; block at line $C9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $CDD8,$D001          ; block at line $CD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D1D8,$D401          ; block at line $D1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D5D8,$D801          ; block at line $D5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $D9D8,$DC01          ; block at line $D9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $DDD8,$E001          ; block at line $DD
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E1D8,$E401          ; block at line $E1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E5D8,$E801          ; block at line $E5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $E9D8,$EC01          ; block at line $E9
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $EDD8,$F001          ; block at line $ED
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F1D8,$F401          ; block at line $F1
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $F5D8,$F801          ; block at line $F5
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $FFFF,$0000
	dc.w    $0000,$0000          ; end of list

bitplanes:
	ds.b    BUF_SIZE

