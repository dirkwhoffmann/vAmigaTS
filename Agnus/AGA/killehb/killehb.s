; killehb.s -- AGA Extra Half-Brite / BPLCON2::KILLEHB test.
;
; Six bitplanes are enabled throughout, with neither HAM nor DPF set --
; the standard precondition for Extra Half-Brite. The bitplane data is
; deliberately trivial: only two buffers exist, shared by all six planes.
;
;   planes 1 and 6   solid $FFFF, so bits 0 and 5 of the colour index are
;                    always set, contributing a fixed 1 + 32 = 33
;   planes 2-5       all four point at ONE shared $FF00 buffer, so bits
;                    1-4 rise and fall together, contributing 0 or
;                    2 + 4 + 8 + 16 = 30
;
; Every pixel is therefore either index 33 or index 63, and the picture is
; an 8-pixel-wide blue/yellow stripe pattern. Both buffers repeat every
; single word, so drift in the bitplane pointers is invisible: BPLxMOD
; stays zero and there is no fetch-count arithmetic to get wrong.
;
; The stripe is 8 pixels wide rather than the 1 pixel $AAAA would give. At
; one pixel the two colours are simply too fine to survive the display:
; blue $00F and yellow $FF0 are complementary, so alternating them pixel by
; pixel averages to $777 and the field reads as flat white, with only the
; outermost stripe on each edge -- the ones bordering black rather than
; their complement -- keeping their true colour. Widening the stripe is
; what makes the two colours actually visible as two colours.
;
; The screen is a LORES stripe field, then the Agnus/DDF/ddf1 Copper timing
; ruler with all bitplanes disabled, then a HIRES stripe field. The stripe
; is 8 pixels wide in whatever the current resolution is, so the HIRES
; stripes come out half the physical width of the LORES ones and the two
; regions are easy to tell apart.
;
; With KILLEHB set the indices address COLOR33 and COLOR63 directly, and
; those are blue and yellow, so the stripe pattern shows at full
; brightness. While EHB is active it substitutes COLOR(n-32) at half
; brightness instead -- index 33 takes COLOR01 and index 63 takes COLOR31
; (NOT COLOR63; 63-32 = 31) -- and both of those are red, so the two
; indices collapse onto one colour and the stripes vanish into a flat red
; line.
;
; The whole test therefore reads as presence-vs-absence of a pattern:
;
;   blue/yellow stripes  EHB is killed   (KILLEHB = 1)
;   flat red             EHB is active   (KILLEHB = 0)
;
; That is far harder to misjudge on real hardware than a brightness step
; would be. KILLEHB is the resting state here, so the screen is stripes
; throughout with red punched into it a few lines at a time, and the
; stripes get COLOR33/COLOR63 unhalved rather than the dimmed pair EHB
; would hand them.
;
; The Copper drives KILLEHB from a block placed on every 4th line of both
; regions, alternating two patterns:
;
;   even blocks  the line holds KILLEHB set, drops it for a stretch, and
;                raises it again before the line ends -- a red notch in a
;                striped line.
;   odd blocks   the inverse: the line starts with KILLEHB clear, it is
;                raised for a stretch, dropped again, then raised at the
;                end of the line -- a striped notch in a red line.
;
; The switch positions advance steadily down the screen, so the notches
; form a diagonal. Both patterns end the line with KILLEHB SET, so the
; three lines between blocks are always striped and every block is read
; against the same background.

	include "../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

FMODEREG            equ $1FC           ; AGA only
BPLCON3             equ $106           ; AGA only
BPLCON4             equ $10C           ; AGA only

KILLEHB_OFF         equ $0024          ; EHB on
KILLEHB_ON          equ $0224          ; EHB off (bit 9 set)

BPLCON0_LORES       equ $6200          ; 6 planes, lores
BPLCON0_HIRES       equ $E200          ; 6 planes, hires
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

	; FMODE must be non-zero. At FMODE=0 a HIRES line fetches only planes
	; 1-4 -- the fetch unit has no slots for 5 and 6 -- so plane 6 would
	; never arrive and the HIRES half could not reach colour index 33 or 63
	; at all. A 32-bit fetch gives all six planes their slots.
	move.w  #$0001,FMODEREG(a1)     ; BPL32: 32-bit fetch

	; Bitplane data: two buffers, shared by all six planes.
	lea     solidData,a0
	move.w  #(BUF_SIZE/2)-1,d0
.fillSolid: move.w  #$FFFF,(a0)+
	dbra    d0,.fillSolid

	lea     stripeData,a0
	move.w  #(BUF_SIZE/2)-1,d0
.fillStripe: move.w  #$FF00,(a0)+
	dbra    d0,.fillStripe

	; Clear all 256 AGA colour registers. Only four are used, but an
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

	; Bank 1 registers 1 and 31 are COLOR33 and COLOR63 -- what indices 33
	; and 63 show once EHB is killed. Two different hues, and taken with no
	; halving, so the killed state is a full-brightness blue/yellow stripe
	; pattern. Each is written twice (LOCT=0 then LOCT=1) to fill both
	; nibbles of every channel, giving a true $FF component rather than $F0.
	move.w  #$2000,BPLCON3(a1)      ; bank 1, LOCT=0
	move.w  #BLUE,COLOR01(a1)       ; COLOR33
	move.w  #YELLOW,COLOR31(a1)     ; COLOR63
	move.w  #$2200,BPLCON3(a1)      ; bank 1, LOCT=1
	move.w  #BLUE,COLOR01(a1)
	move.w  #YELLOW,COLOR31(a1)

	; Bank 0 registers 1 and 31 are COLOR01 and COLOR31 -- what EHB
	; substitutes for indices 33 and 63 while it is active. BOTH are red, so
	; wherever EHB is doing its job the two stripe indices collapse onto one
	; colour and the pattern disappears into a flat red line.
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT=0
	move.w  #RED,COLOR01(a1)
	move.w  #RED,COLOR31(a1)
	move.w  #$0200,BPLCON3(a1)      ; bank 0, LOCT=1
	move.w  #RED,COLOR01(a1)
	move.w  #RED,COLOR31(a1)
	move.w  #$0000,BPLCON3(a1)      ; leave BPLCON3 in a known state

	; Patch the two buffer addresses into both regions' pointer blocks.
	; Planes 1 and 6 take the solid buffer, planes 2-5 share the stripe
	; buffer. Offsets are fixed byte distances from the 'copper' label.
	lea     copper(pc),a2
	; lores
	lea     solidData,a3
	move.l  a3,d3
	move.w  d3,46(a2)
	swap    d3
	move.w  d3,42(a2)
	lea     stripeData,a3
	move.l  a3,d3
	move.w  d3,54(a2)
	swap    d3
	move.w  d3,50(a2)
	lea     stripeData,a3
	move.l  a3,d3
	move.w  d3,62(a2)
	swap    d3
	move.w  d3,58(a2)
	lea     stripeData,a3
	move.l  a3,d3
	move.w  d3,70(a2)
	swap    d3
	move.w  d3,66(a2)
	lea     stripeData,a3
	move.l  a3,d3
	move.w  d3,78(a2)
	swap    d3
	move.w  d3,74(a2)
	lea     solidData,a3
	move.l  a3,d3
	move.w  d3,86(a2)
	swap    d3
	move.w  d3,82(a2)
	; hires
	lea     solidData,a3
	move.l  a3,d3
	move.w  d3,950(a2)
	swap    d3
	move.w  d3,946(a2)
	lea     stripeData,a3
	move.l  a3,d3
	move.w  d3,958(a2)
	swap    d3
	move.w  d3,954(a2)
	lea     stripeData,a3
	move.l  a3,d3
	move.w  d3,966(a2)
	swap    d3
	move.w  d3,962(a2)
	lea     stripeData,a3
	move.l  a3,d3
	move.w  d3,974(a2)
	swap    d3
	move.w  d3,970(a2)
	lea     stripeData,a3
	move.l  a3,d3
	move.w  d3,982(a2)
	swap    d3
	move.w  d3,978(a2)
	lea     solidData,a3
	move.l  a3,d3
	move.w  d3,990(a2)
	swap    d3
	move.w  d3,986(a2)

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

copper:
	dc.w    BPLCON0,BPLCON0_OFF     ; planes off until the lores region
	dc.w    BPLCON1,$0000
	dc.w    BPLCON3,$0000
	dc.w    BPLCON4,$0011           ; AGA defaults
	dc.w    DIWSTRT,$2C71
	dc.w    DIWSTOP,$2CC1

	; One DDF window for the whole frame -- the hires region simply uses
	; the lores values, giving a slightly narrower picture there. Nothing
	; changes DDF mid-frame.
	dc.w    DDFSTRT,$0038
	dc.w    DDFSTOP,$00C8
	dc.w    BPL1MOD,$0000           ; see the bitplane data note in MAIN
	dc.w    BPL2MOD,$0000

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

	;
	; LORES stripe field
	;
	dc.w    $3001,$FFFE
	dc.w    BPLCON0,BPLCON0_LORES

	;
	; Lores block 0 (line $30): red notch in a striped line
	;
	dc.w    $3001,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $3041,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $3059,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 1 (line $34): striped notch in a red line
	;
	dc.w    $3401,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $3445,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $345D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $34D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 2 (line $38): red notch in a striped line
	;
	dc.w    $3801,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $3849,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $3861,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 3 (line $3C): striped notch in a red line
	;
	dc.w    $3C01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $3C4D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $3C65,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $3CD9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 4 (line $40): red notch in a striped line
	;
	dc.w    $4001,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $4051,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $4069,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 5 (line $44): striped notch in a red line
	;
	dc.w    $4401,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $4455,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $446D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $44D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 6 (line $48): red notch in a striped line
	;
	dc.w    $4801,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $4859,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $4871,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 7 (line $4C): striped notch in a red line
	;
	dc.w    $4C01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $4C5D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $4C75,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $4CD9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 8 (line $50): red notch in a striped line
	;
	dc.w    $5001,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $5061,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $5079,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 9 (line $54): striped notch in a red line
	;
	dc.w    $5401,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $5465,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $547D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $54D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 10 (line $58): red notch in a striped line
	;
	dc.w    $5801,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $5869,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $5881,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 11 (line $5C): striped notch in a red line
	;
	dc.w    $5C01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $5C6D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $5C85,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $5CD9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 12 (line $60): red notch in a striped line
	;
	dc.w    $6001,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $6073,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $608B,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 13 (line $64): striped notch in a red line
	;
	dc.w    $6401,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $6477,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $648F,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $64D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 14 (line $68): red notch in a striped line
	;
	dc.w    $6801,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $687B,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $6893,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 15 (line $6C): striped notch in a red line
	;
	dc.w    $6C01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $6C7F,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $6C97,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $6CD9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 16 (line $70): red notch in a striped line
	;
	dc.w    $7001,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $7083,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $709B,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 17 (line $74): striped notch in a red line
	;
	dc.w    $7401,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $7487,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $749F,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $74D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 18 (line $78): red notch in a striped line
	;
	dc.w    $7801,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $788B,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $78A3,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 19 (line $7C): striped notch in a red line
	;
	dc.w    $7C01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $7C8F,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $7CA7,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $7CD9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 20 (line $80): red notch in a striped line
	;
	dc.w    $8001,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $8093,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $80AB,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 21 (line $84): striped notch in a red line
	;
	dc.w    $8401,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $8497,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $84AF,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $84D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 22 (line $88): red notch in a striped line
	;
	dc.w    $8801,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $889B,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $88B3,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Lores block 23 (line $8C): striped notch in a red line
	;
	dc.w    $8C01,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $8CA1,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $8CB9,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $8CD9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	;
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

	;
	; HIRES stripe field. Pointers are reloaded while the planes are
	; still off, then the region is switched on one line later.
	;
	dc.w    $9401,$FFFE
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

	dc.w    $9501,$FFFE
	dc.w    BPLCON0,BPLCON0_HIRES

	;
	; Hires block 0 (line $95): red notch in a striped line
	;
	dc.w    $9501,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $9541,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $9559,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 1 (line $99): striped notch in a red line
	;
	dc.w    $9901,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $9945,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $995D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $99D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 2 (line $9D): red notch in a striped line
	;
	dc.w    $9D01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $9D49,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $9D61,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 3 (line $A1): striped notch in a red line
	;
	dc.w    $A101,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $A14D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $A165,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $A1D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 4 (line $A5): red notch in a striped line
	;
	dc.w    $A501,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $A551,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $A569,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 5 (line $A9): striped notch in a red line
	;
	dc.w    $A901,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $A955,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $A96D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $A9D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 6 (line $AD): red notch in a striped line
	;
	dc.w    $AD01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $AD59,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $AD71,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 7 (line $B1): striped notch in a red line
	;
	dc.w    $B101,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $B15D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $B175,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $B1D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 8 (line $B5): red notch in a striped line
	;
	dc.w    $B501,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $B561,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $B579,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 9 (line $B9): striped notch in a red line
	;
	dc.w    $B901,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $B965,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $B97D,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $B9D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 10 (line $BD): red notch in a striped line
	;
	dc.w    $BD01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $BD69,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $BD81,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 11 (line $C1): striped notch in a red line
	;
	dc.w    $C101,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $C16D,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $C185,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $C1D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 12 (line $C5): red notch in a striped line
	;
	dc.w    $C501,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $C573,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $C58B,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 13 (line $C9): striped notch in a red line
	;
	dc.w    $C901,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $C977,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $C98F,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $C9D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 14 (line $CD): red notch in a striped line
	;
	dc.w    $CD01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $CD7B,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $CD93,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 15 (line $D1): striped notch in a red line
	;
	dc.w    $D101,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $D17F,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $D197,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $D1D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 16 (line $D5): red notch in a striped line
	;
	dc.w    $D501,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $D583,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $D59B,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 17 (line $D9): striped notch in a red line
	;
	dc.w    $D901,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $D987,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $D99F,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $D9D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 18 (line $DD): red notch in a striped line
	;
	dc.w    $DD01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $DD8B,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $DDA3,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 19 (line $E1): striped notch in a red line
	;
	dc.w    $E101,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $E18F,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $E1A7,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $E1D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 20 (line $E5): red notch in a striped line
	;
	dc.w    $E501,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $E593,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $E5AB,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 21 (line $E9): striped notch in a red line
	;
	dc.w    $E901,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $E997,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $E9AF,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $E9D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 22 (line $ED): red notch in a striped line
	;
	dc.w    $ED01,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $ED9B,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $EDB3,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	;
	; Hires block 23 (line $F1): striped notch in a red line
	;
	dc.w    $F101,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $F1A1,$FFFE
	dc.w    BPLCON2,KILLEHB_ON
	dc.w    $F1B9,$FFFE
	dc.w    BPLCON2,KILLEHB_OFF
	dc.w    $F1D9,$FFFE
	dc.w    BPLCON2,KILLEHB_ON

	;
	; Done -- shut the display down again.
	;
	dc.w    $F501,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	dc.l    $fffffffe

	cnop    0,8                     ; 32-bit fetch wants aligned pointers
solidData:  ds.b BUF_SIZE
	cnop    0,8
stripeData: ds.b BUF_SIZE
