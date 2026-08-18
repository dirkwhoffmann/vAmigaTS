; killehb2.s -- BPLCON2::KILLEHB across all three AGA resolutions.
;
; killehb established that vAmiga switched KILLEHB too early, and that the
; correction differs between LORES and HIRES: measured against an A1200,
; hardware puts its HIRES edge 16.6 screenshot columns after its LORES one
; while vAmiga put it at exactly 16. That left a fitted, unexplained half
; column in Denise::setBPLCON2, and one obvious gap -- SUPER HIRES was never
; tested at all.
;
; This test closes the gap and, unlike killehb, makes the three regions
; directly comparable.
;
; WHAT IS DIFFERENT FROM killehb
; ------------------------------
;
; killehb keeps the stripe 8 pixels wide in whatever the current resolution
; is, so its HIRES stripes are physically half the width of its LORES ones.
; That is fine for reading a single region but useless for comparing them:
; the eye has no common ruler. Here every region gets a stripe that is 8
; LORES PIXELS WIDE ON SCREEN, using a different bitplane pattern per region
;
;   LORES   $FF00                      8 lores pixels
;   HIRES   $FFFF,$0000               16 hires pixels  = 8 lores pixels
;   SHRES   $FFFF,$FFFF,$0000,$0000   32 shres pixels  = 8 lores pixels
;
; so the three regions paint the same physical stripe and a switch position
; can be compared across them by eye, without measuring anything.
;
; FMODE IS $0003, AND IT HAS TO BE
; --------------------------------
;
; Extra Half-Brite needs exactly six bitplanes, and six bitplanes in super
; hires need the 64 bit fetch: at FMODE $0001 a super hires line has slots
; for at most four planes. Denise/Modes/shres/shres11 shows an A1200
; painting all eight sections at FMODE $0003, so six is reachable there.
;
; FMODE $0003 also removes the fetch-count arithmetic that the FMODE tests
; had to fight. Every fetch moves a pointer by eight bytes, so a line always
; advances a plane by a multiple of eight -- and the three stripe patterns
; have periods of 2, 4 and 8 bytes, every one of which divides 8. So no
; matter how many fetches a line makes, it ends on a period boundary, the
; next line starts in phase, and the picture stands still with BPL1MOD and
; BPL2MOD at zero. The pointers are simply left to run from line to line and
; are reloaded only when a region starts.
;
; The 64 bit fetch does want its pointers 64 bit aligned (see
; Agnus/Registers/FMODE/fmode11a and friends for what happens otherwise),
; hence the cnop before each buffer.
;
; THE LORES DIAGONAL WOBBLES, AND THAT IS NOT A FAULT
; ---------------------------------------------------
;
; In vAmiga the HIRES and SHRES notches step by exactly 32 screenshot
; columns per pair of blocks and are all exactly 96 wide. The LORES ones do
; not: their steps run 24, 32, 40, 32 and their widths 96, 104, 96, 88, in a
; pattern that repeats every four blocks.
;
; That is Copper contention, not a broken block. At FMODE $0003 a LORES
; fetch unit is 32 colour clocks, against 8 for HIRES and SHRES, so the six
; bitplane slots bunch up at the head of a long unit and a MOVE requested
; inside the bunch waits for the next free cycle. The delay is a function of
; the requested position modulo the fetch unit, so it repeats, and the
; blocks advance four colour clocks at a time -- hence a period of four.
;
; This is worth having rather than designing away. It is a precise,
; deterministic prediction about how Agnus hands cycles to the Copper, and
; the photograph either reproduces it or does not. If it does, the Copper
; model is sound and any residual disagreement in the switch position
; belongs to Denise. If it does not, the wobble is the finding.
;
; HOW TO READ IT
; --------------
;
; As in killehb, the picture is presence versus absence of a pattern rather
; than a difference in shade:
;
;   blue/yellow stripes   EHB is killed   (KILLEHB = 1)
;   flat red              EHB is active   (KILLEHB = 0)
;
; Planes 1 and 6 are solid, planes 2 to 5 carry the stripe, so every pixel is
; colour index 33 or 63. With EHB killed those address COLOR33 and COLOR63,
; set to blue and yellow. With EHB active Denise substitutes COLOR(n-32) at
; half brightness -- COLOR01 for 33 and COLOR31 for 63, both set to red -- so
; the two indices collapse and the stripes vanish into a flat red line.
;
; Three regions of 16 blocks, one block every fourth line, a copper ruler
; between them:
;
;     lines $30-$6F   LORES
;     line  $70       ruler
;     lines $75-$B4   HIRES
;     line  $B5       ruler
;     lines $BA-$F9   SHRES
;
; Even blocks hold KILLEHB set, drop it, and raise it again: a red notch in a
; striped line. Odd blocks are the inverse. Both end the line with KILLEHB
; set, so the three lines between blocks are always striped and every block
; is read against the same background. The switch positions advance by four
; colour clocks per block, so the notches form a diagonal, and the SAME
; diagonal appears in all three regions -- any difference between them is the
; thing under test.

	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

FMODEREG            equ $1FC           ; AGA only
BPLCON3             equ $106           ; AGA only
BPLCON4             equ $10C           ; AGA only

KILLEHB_OFF         equ $0024          ; EHB on
KILLEHB_ON          equ $0224          ; EHB off (bit 9 set)

BPLCON0_LORES       equ $6200          ; 6 planes, lores
BPLCON0_HIRES       equ $E200          ; 6 planes, hires (bit 15)
BPLCON0_SHRES       equ $6240          ; 6 planes, super hires (bit 6; bit 15 clear)
BPLCON0_OFF         equ $0200          ; no planes

BLUE                equ $00F
YELLOW              equ $FF0
RED                 equ $F00

BUF_SIZE            equ 16384

MAIN:
	lea     CUSTOM,a1

	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #BPLCON0_OFF,BPLCON0(a1)

	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Baseline only -- the Copper drives BPLCON2 from here on.
	move.w  #KILLEHB_ON,BPLCON2(a1)

	; 64 bit fetch. See the header: six planes in super hires need it, and
	; it is what lets all three stripe periods tile a line exactly.
	move.w  #$0003,FMODEREG(a1)

	; Bitplane data. One solid buffer for planes 1 and 6, and one stripe
	; buffer per region for planes 2 to 5, each patterned so that the
	; stripe comes out eight lores pixels wide on screen.
	lea     solidData,a0
	move.w  #(BUF_SIZE/2)-1,d0
.fillSolid:
	move.w  #$FFFF,(a0)+
	dbra    d0,.fillSolid

	lea     stripeLores,a0
	move.w  #(BUF_SIZE/2)-1,d0
.fillLores:
	move.w  #$FF00,(a0)+
	dbra    d0,.fillLores

	lea     stripeHires,a0
	move.w  #(BUF_SIZE/4)-1,d0
.fillHires:
	move.w  #$FFFF,(a0)+
	move.w  #$0000,(a0)+
	dbra    d0,.fillHires

	lea     stripeShres,a0
	move.w  #(BUF_SIZE/8)-1,d0
.fillShres:
	move.w  #$FFFF,(a0)+
	move.w  #$FFFF,(a0)+
	move.w  #$0000,(a0)+
	move.w  #$0000,(a0)+
	dbra    d0,.fillShres

	; Clear all 256 AGA colour registers. Only four are used, but an
	; untouched register keeps whatever the previously running program left
	; in it, and stray garbage on screen is indistinguishable from a real
	; failure. Banks run 7 down to 0 so bank 0 is written last.
	moveq   #7,d7
.colorBankLoop:
	move.w  d7,d0
	lsl.w   #8,d0
	lsl.w   #5,d0
	move.w  d0,BPLCON3(a1)          ; LOCT=0
	lea     COLOR00(a1),a2
	moveq   #31,d6
.colorHiLoop:
	move.w  #$0000,(a2)+
	dbra    d6,.colorHiLoop

	or.w    #$0200,d0               ; LOCT=1
	move.w  d0,BPLCON3(a1)
	lea     COLOR00(a1),a2
	moveq   #31,d6
.colorLoLoop:
	move.w  #$0000,(a2)+
	dbra    d6,.colorLoLoop

	dbra    d7,.colorBankLoop

	; Bank 1 registers 1 and 31 are COLOR33 and COLOR63 -- what the two
	; stripe indices show once EHB is killed. Written twice (LOCT=0 then 1)
	; so every channel gets both nibbles and the result is a true $FF.
	move.w  #$2000,BPLCON3(a1)
	move.w  #BLUE,COLOR01(a1)
	move.w  #YELLOW,COLOR31(a1)
	move.w  #$2200,BPLCON3(a1)
	move.w  #BLUE,COLOR01(a1)
	move.w  #YELLOW,COLOR31(a1)

	; Bank 0 registers 1 and 31 are what EHB substitutes for those indices.
	; Both red, so wherever EHB is active the stripes collapse to one hue.
	move.w  #$0000,BPLCON3(a1)
	move.w  #RED,COLOR01(a1)
	move.w  #RED,COLOR31(a1)
	move.w  #$0200,BPLCON3(a1)
	move.w  #RED,COLOR01(a1)
	move.w  #RED,COLOR31(a1)
	move.w  #$0000,BPLCON3(a1)

	; Patch the buffer addresses into the three pointer blocks. Each block
	; is addressed by its own label rather than by a byte offset from the
	; head of the copper list, so inserting copper instructions above one
	; cannot silently misdirect a bitplane.
	lea     loresPtrs(pc),a2
	lea     stripeLores,a3
	bsr     .patchPtrs
	lea     hiresPtrs(pc),a2
	lea     stripeHires,a3
	bsr     .patchPtrs
	lea     shresPtrs(pc),a2
	lea     stripeShres,a3
	bsr     .patchPtrs

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

.patchPtrs:
	; a2 = pointer block (6 pairs of MOVEs, BPL1PT..BPL6PT)
	; a3 = stripe buffer for planes 2 to 5; planes 1 and 6 take the solid one
	movem.l d0-d3/a2-a4,-(sp)
	lea     solidData,a4
	moveq   #0,d0                   ; plane index 0..5
.ppLoop:
	move.l  a4,d3                   ; plane 1 and 6 -> solid
	cmp.w   #0,d0
	beq.s   .ppHave
	cmp.w   #5,d0
	beq.s   .ppHave
	move.l  a3,d3                   ; planes 2-5 -> stripes
.ppHave:
	move.w  d3,6(a2)                ; low word  -> BPLxPTL
	swap    d3
	move.w  d3,2(a2)                ; high word -> BPLxPTH
	lea     8(a2),a2
	addq.w  #1,d0
	cmp.w   #6,d0
	blt.s   .ppLoop
	movem.l (sp)+,d0-d3/a2-a4
	rts

copper:
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON3,$0000
	dc.w    BPLCON4,$0011
	dc.w    DIWSTRT,$2C71
	dc.w    DIWSTOP,$2CC1

	; One DDF window for the whole frame; nothing changes it mid-frame, so
	; every difference between the regions is down to BPLCON0 and BPLCON2.
	dc.w    DDFSTRT,$0038
	dc.w    DDFSTOP,$00C8
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000

	;
	; LORES region
	;
loresPtrs:
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
	dc.w    $3001,$FFFE
	dc.w    BPLCON0,BPLCON0_LORES

	; block 0 (line $30): red notch in a striped line
	dc.w    $3001,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $3041,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $3059,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 1 (line $34): striped notch in a red line
	dc.w    $3401,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $3445,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $345D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $34D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 2 (line $38): red notch in a striped line
	dc.w    $3801,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $3849,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $3861,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 3 (line $3C): striped notch in a red line
	dc.w    $3C01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $3C4D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $3C65,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $3CD9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 4 (line $40): red notch in a striped line
	dc.w    $4001,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $4051,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $4069,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 5 (line $44): striped notch in a red line
	dc.w    $4401,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $4455,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $446D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $44D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 6 (line $48): red notch in a striped line
	dc.w    $4801,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $4859,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $4871,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 7 (line $4C): striped notch in a red line
	dc.w    $4C01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $4C5D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $4C75,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $4CD9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 8 (line $50): red notch in a striped line
	dc.w    $5001,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $5061,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $5079,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 9 (line $54): striped notch in a red line
	dc.w    $5401,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $5465,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $547D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $54D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 10 (line $58): red notch in a striped line
	dc.w    $5801,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $5869,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $5881,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 11 (line $5C): striped notch in a red line
	dc.w    $5C01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $5C6D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $5C85,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $5CD9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 12 (line $60): red notch in a striped line
	dc.w    $6001,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $6071,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $6089,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 13 (line $64): striped notch in a red line
	dc.w    $6401,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $6475,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $648D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $64D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 14 (line $68): red notch in a striped line
	dc.w    $6801,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $6879,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $6891,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 15 (line $6C): striped notch in a red line
	dc.w    $6C01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $6C7D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $6C95,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $6CD9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; Copper timing ruler (from Agnus/DDF/ddf1), bitplanes off
	dc.w    $7001,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    $7139,$FFFE
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
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000

	;
	; HIRES region
	;
	dc.w    $7401,$FFFE
hiresPtrs:
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
	dc.w    $7501,$FFFE
	dc.w    BPLCON0,BPLCON0_HIRES

	; block 0 (line $75): red notch in a striped line
	dc.w    $7501,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $7541,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $7559,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 1 (line $79): striped notch in a red line
	dc.w    $7901,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $7945,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $795D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $79D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 2 (line $7D): red notch in a striped line
	dc.w    $7D01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $7D49,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $7D61,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 3 (line $81): striped notch in a red line
	dc.w    $8101,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $814D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $8165,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $81D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 4 (line $85): red notch in a striped line
	dc.w    $8501,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $8551,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $8569,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 5 (line $89): striped notch in a red line
	dc.w    $8901,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $8955,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $896D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $89D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 6 (line $8D): red notch in a striped line
	dc.w    $8D01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $8D59,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $8D71,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 7 (line $91): striped notch in a red line
	dc.w    $9101,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $915D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $9175,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $91D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 8 (line $95): red notch in a striped line
	dc.w    $9501,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $9561,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $9579,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 9 (line $99): striped notch in a red line
	dc.w    $9901,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $9965,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $997D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $99D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 10 (line $9D): red notch in a striped line
	dc.w    $9D01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $9D69,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $9D81,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 11 (line $A1): striped notch in a red line
	dc.w    $A101,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $A16D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $A185,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $A1D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 12 (line $A5): red notch in a striped line
	dc.w    $A501,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $A571,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $A589,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 13 (line $A9): striped notch in a red line
	dc.w    $A901,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $A975,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $A98D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $A9D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 14 (line $AD): red notch in a striped line
	dc.w    $AD01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $AD79,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $AD91,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 15 (line $B1): striped notch in a red line
	dc.w    $B101,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $B17D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $B195,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $B1D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; Copper timing ruler (from Agnus/DDF/ddf1), bitplanes off
	dc.w    $B501,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    $B639,$FFFE
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
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000

	;
	; SUPER HIRES region
	;
	dc.w    $B901,$FFFE
shresPtrs:
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
	dc.w    $BA01,$FFFE
	dc.w    BPLCON0,BPLCON0_SHRES

	; block 0 (line $BA): red notch in a striped line
	dc.w    $BA01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $BA41,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $BA59,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 1 (line $BE): striped notch in a red line
	dc.w    $BE01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $BE45,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $BE5D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $BED9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 2 (line $C2): red notch in a striped line
	dc.w    $C201,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $C249,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $C261,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 3 (line $C6): striped notch in a red line
	dc.w    $C601,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $C64D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $C665,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $C6D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 4 (line $CA): red notch in a striped line
	dc.w    $CA01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $CA51,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $CA69,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 5 (line $CE): striped notch in a red line
	dc.w    $CE01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $CE55,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $CE6D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $CED9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 6 (line $D2): red notch in a striped line
	dc.w    $D201,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $D259,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $D271,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 7 (line $D6): striped notch in a red line
	dc.w    $D601,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $D65D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $D675,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $D6D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 8 (line $DA): red notch in a striped line
	dc.w    $DA01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $DA61,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $DA79,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 9 (line $DE): striped notch in a red line
	dc.w    $DE01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $DE65,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $DE7D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $DED9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 10 (line $E2): red notch in a striped line
	dc.w    $E201,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $E269,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $E281,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 11 (line $E6): striped notch in a red line
	dc.w    $E601,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $E66D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $E685,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $E6D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 12 (line $EA): red notch in a striped line
	dc.w    $EA01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $EA71,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $EA89,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 13 (line $EE): striped notch in a red line
	dc.w    $EE01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $EE75,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $EE8D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $EED9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 14 (line $F2): red notch in a striped line
	dc.w    $F201,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $F279,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $F291,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	; block 15 (line $F6): striped notch in a red line
	dc.w    $F601,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $F67D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $F695,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $F6D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Done -- shut the display down again.
	;
	dc.w    $FA01,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	dc.l    $fffffffe

	cnop    0,8                     ; 64 bit fetch wants aligned pointers
solidData:   ds.b BUF_SIZE
	cnop    0,8
stripeLores: ds.b BUF_SIZE
	cnop    0,8
stripeHires: ds.b BUF_SIZE
	cnop    0,8
stripeShres: ds.b BUF_SIZE
