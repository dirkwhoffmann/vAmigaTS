	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; ham8.s -- HAM6 versus HAM8.
;
; The upper half of the screen is drawn in HAM6, the lower half in HAM8,
; with the copper timing ruler from the Agnus/DDF/ddf1 test between them.
; Both halves are LORES: HAM8 requires BPU = 8 with the HIRES bit clear, so
; there is no hires variant to compare against.
;
;
; WHAT DIFFERS BETWEEN THE TWO MODES
; ----------------------------------
;
; Both modes split the colour index into two control bits and a data field,
; and the control codes mean the same thing in both:
;
;     00  set the colour from a palette register
;     01  hold red and green, modify BLUE
;     10  hold green and blue, modify RED
;     11  hold red and blue,   modify GREEN
;
; What differs is where those bits sit and how wide the data field is:
;
;                  control bits        data field       modify writes
;     HAM6         index 5-4           index 3-0        value << 4
;                  (planes 5, 6)       (planes 1-4)     4 bits, 16 steps
;
;     HAM8         index 1-0           index 7-2        value << 2
;                  (planes 1, 2)       (planes 3-8)     6 bits, 64 steps
;
; Note that HAM8 puts its control bits in the LOW two planes, not the high
; two -- it is not simply HAM6 with two more data planes bolted on top, and
; a plane assignment that is right for one mode is wrong for the other.
; In the set case HAM6 reads COLOR00-15 while HAM8 reads COLOR00-63 (the
; index shifted right by two).
;
;
; HOW THE TEST MAKES THAT VISIBLE
; -------------------------------
;
; Each half is four horizontal bands of 20 lines. Every band holds one
; control code constant across the whole line and lets the data field count
; up with the pixel position, so a band is a sawtooth of whatever that
; control code does:
;
;     band 1   code 00   the palette, cycled
;     band 2   code 10   a black to red    ramp
;     band 3   code 11   a black to green  ramp
;     band 4   code 01   a black to blue   ramp
;
; The data field is fed the pixel position in both halves, so its width
; alone decides the period of the sawtooth:
;
;     HAM6   4 bit field   ramp repeats every 16 lores pixels
;     HAM8   6 bit field   ramp repeats every 64 lores pixels
;
; With 256 pixels of display that is 16 teeth per band in the HAM6 half
; against 4 in the HAM8 half. A quarter of the tooth count is not a subtle
; difference, and it is a direct read-out of the data field width, which is
; the thing that actually separates the two modes.
;
; The palette band reads the same way. COLOR00-63 hold a 64 step black to
; white ramp, so the HAM8 band sweeps black to white every 64 pixels while
; the HAM6 band, which can only reach COLOR00-15, sweeps black to a quarter
; grey every 16 pixels. The HAM6 palette band being conspicuously dark is
; the expected result, not a palette bug: a HAM6 picture simply cannot
; address the upper 48 registers.
;
; The ramps start from black because the modify codes hold two channels from
; the previous pixel, and at the left edge of the display window that is
; COLOR00. If a band comes out tinted rather than a pure channel ramp, the
; HAM hold is not being reset to COLOR00 at the start of the line -- worth
; knowing either way, and the reason COLOR00 is forced to black.
;
;
; BITPLANE DATA AND MEMORY
; ------------------------
;
; Only eight buffers exist, each filled with a repeating 4 word (8 byte)
; pattern, and the copper points the eight bitplanes at them:
;
;     bit0  $5555 x4     pixel position bit 0, period  2 pixels
;     bit1  $3333 x4                    bit 1, period  4
;     bit2  $0F0F x4                    bit 2, period  8
;     bit3  $00FF x4                    bit 3, period 16
;     bit4  $0000,$FFFF,$0000,$FFFF     bit 4, period 32
;     bit5  $0000,$0000,$FFFF,$FFFF     bit 5, period 64
;     ones  $FFFF x4                    a constant 1
;     zeros $0000 x4                    a constant 0
;
; A band is then nothing but a choice of pointers: the data planes get bit0
; upwards, and the two control planes get ones or zeros according to the
; band's control code. That is why the two halves can share every buffer
; even though HAM6 and HAM8 take their control bits from opposite ends of
; the plane stack.
;
; FMODE is $0 (16 bit fetch), so a line fetches
;
;     words = (DDFSTOP - DDFSTRT) / 8 + 1
;
; per plane, which for the $38 to $B0 window used here is 16 words = 256
; lores pixels. 16 is a multiple of the 4 word pattern period, so a line
; always ends on a period boundary and the next line starts in phase with
; BPLxMOD left at zero; the pointers are reloaded only when a band starts.
; Choosing the window to satisfy that condition is only safe because the
; window is fixed -- see agascroll.i for the case where it is not.

BPLCON3             equ $106          ; AGA only
BPLCON4             equ $10C          ; AGA only
BPL7PTH             equ $F8           ; AGA only
BPL7PTL             equ $FA           ; AGA only
BPL8PTH             equ $FC           ; AGA only
BPL8PTL             equ $FE           ; AGA only
FMODEREG            equ $1FC          ; AGA only

FMODE               equ $0000         ; 16-bit fetch; 8 lores planes fit fine

DDF_START           equ $0038
DDF_STOP            equ $00B0

; Bitplane data begins at hpos DDF_START*2+17, the window opens 8 pixels
; ahead of it, and 16 fetched words are 256 lores pixels wide, so hstop is
; 129+256 = 385 = $181. DIWSTOP's hstop carries an implicit bit 8, hence
; $81 rather than $181.
DIW_START           equ $2C00+(DDF_START*2)+9
DIW_STOP            equ $2C81

BPLCON0_HAM6        equ $6A00         ; BPU=6, HAM, lores
BPLCON0_HAM8        equ $0A10         ; BPU=8 (BPU3), HAM, lores
BPLCON0_OFF         equ $0200

BAND_LINES          equ 20
PLANE_SIZE          equ 1024          ; BAND_LINES * 32 bytes, plus slack


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

	; Fill the eight buffers with their 4 word patterns.
	lea     bitBuf0,a0
	lea     .pat0(pc),a3
	bsr     .fillPattern
	lea     bitBuf1,a0
	lea     .pat1(pc),a3
	bsr     .fillPattern
	lea     bitBuf2,a0
	lea     .pat2(pc),a3
	bsr     .fillPattern
	lea     bitBuf3,a0
	lea     .pat3(pc),a3
	bsr     .fillPattern
	lea     bitBuf4,a0
	lea     .pat4(pc),a3
	bsr     .fillPattern
	lea     bitBuf5,a0
	lea     .pat5(pc),a3
	bsr     .fillPattern
	lea     onesBuf,a0
	lea     .patOnes(pc),a3
	bsr     .fillPattern
	lea     zerosBuf,a0
	lea     .patZeros(pc),a3
	bsr     .fillPattern

	; Palette: COLOR00-63 hold a 64 step black to white ramp, register n
	; carrying the 8 bit level n*4. A write with LOCT clear stores the
	; given nibble in BOTH halves of each component, and a following write
	; with LOCT set replaces the lower halves, so the pair of passes below
	; lands exactly (n>>2)*16 + (n&3)*4 = n*4 per channel.
	;
	; Registers 0-31 are bank 0 and 32-63 are bank 1. Bank 1 is written
	; first so that bank 0 is written last: on a chipset where BPLCON3's
	; BANK field does nothing, both passes hit the same 32 registers and
	; whichever went last is what sticks -- and that has to be bank 0.
	lea     CUSTOM,a1
	moveq   #1,d7                   ; d7 = bank (1 downto 0)
.bankLoop:
	move.w  d7,d0
	lsl.w   #8,d0
	lsl.w   #5,d0                   ; BANK -> BPLCON3 bits 15-13

	move.w  d0,BPLCON3(a1)          ; LOCT = 0: high nibbles
	lea     COLOR00(a1),a2
	moveq   #0,d6
.hiLoop:
	move.w  d7,d5
	lsl.w   #5,d5
	or.w    d6,d5                   ; d5 = n = bank*32 + reg
	move.w  d5,d2
	lsr.w   #2,d2                   ; n >> 2, the high nibble of n*4
	move.w  d2,d1
	lsl.w   #4,d1
	or.w    d1,d2
	lsl.w   #4,d1
	or.w    d1,d2                   ; replicate into R, G and B
	move.w  d2,(a2)+
	addq.w  #1,d6
	cmp.w   #32,d6
	bne.s   .hiLoop

	or.w    #$0200,d0               ; LOCT = 1: low nibbles
	move.w  d0,BPLCON3(a1)
	lea     COLOR00(a1),a2
	moveq   #0,d6
.loLoop:
	move.w  d7,d5
	lsl.w   #5,d5
	or.w    d6,d5
	and.w   #3,d5
	lsl.w   #2,d5                   ; (n & 3) * 4, the low nibble of n*4
	move.w  d5,d2
	move.w  d2,d1
	lsl.w   #4,d1
	or.w    d1,d2
	lsl.w   #4,d1
	or.w    d1,d2
	move.w  d2,(a2)+
	addq.w  #1,d6
	cmp.w   #32,d6
	bne.s   .loLoop

	dbra    d7,.bankLoop

	; COLOR00 is the base every modify band ramps away from, so force it to
	; true black. It is index 0, which the ramp above already makes black,
	; but writing it explicitly keeps the intent obvious and leaves BPLCON3
	; in a known state.
	move.w  #$0000,BPLCON3(a1)      ; bank 0, LOCT = 0
	move.w  #$0000,COLOR00(a1)
	move.w  #$0200,BPLCON3(a1)      ; bank 0, LOCT = 1
	move.w  #$0000,COLOR00(a1)
	move.w  #$0000,BPLCON3(a1)

	; Patch the buffer addresses into every band's pointer block. Each
	; entry of bandTable is one band: the address of its copper block
	; followed by the eight buffers its planes point at, in plane order.
	lea     bandTable(pc),a4
.bandLoop:
	move.l  (a4)+,d0
	beq.s   .bandDone
	move.l  d0,a2                   ; a2 = the band's BPL1PTH move
	moveq   #7,d6
.planeLoop:
	move.l  (a4)+,d3
	move.w  d3,6(a2)                ; low  word -> BPLxPTL move
	swap    d3
	move.w  d3,2(a2)                ; high word -> BPLxPTH move
	addq.l  #8,a2
	dbra    d6,.planeLoop
	bra.s   .bandLoop
.bandDone:

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


.fillPattern:
	; Replicates the 4-word (8-byte) pattern at a3 across the buffer at a0.
	; in: a0 = dest, a3 = pattern
	; clobbers: a0, a4, d0
	move.w  #(PLANE_SIZE/8)-1,d0
.fpLoop:
	move.l  a3,a4
	move.w  (a4)+,(a0)+
	move.w  (a4)+,(a0)+
	move.w  (a4)+,(a0)+
	move.w  (a4)+,(a0)+
	dbra    d0,.fpLoop
	rts

	; Bit b of the pixel position, as a 4 word period. Pixel 0 is the most
	; significant bit of the first word.
.pat0:     dc.w    $5555,$5555,$5555,$5555   ; period  2 pixels
.pat1:     dc.w    $3333,$3333,$3333,$3333   ; period  4
.pat2:     dc.w    $0F0F,$0F0F,$0F0F,$0F0F   ; period  8
.pat3:     dc.w    $00FF,$00FF,$00FF,$00FF   ; period 16
.pat4:     dc.w    $0000,$FFFF,$0000,$FFFF   ; period 32
.pat5:     dc.w    $0000,$0000,$FFFF,$FFFF   ; period 64
.patOnes:  dc.w    $FFFF,$FFFF,$FFFF,$FFFF
.patZeros: dc.w    $0000,$0000,$0000,$0000


; One entry per band: the copper block to patch, then the buffer each of the
; eight planes points at.
;
; HAM6 takes its control bits from planes 5 and 6 (index bits 4 and 5) and
; its data from planes 1-4. Planes 7 and 8 are not fetched at BPU = 6 but
; are pointed at zerosBuf anyway so no pointer is ever left dangling.
;
; HAM8 takes its control bits from planes 1 and 2 (index bits 0 and 1) and
; its data from planes 3-8. The low control bit is plane 1 in HAM8 and
; plane 5 in HAM6, so "code 10" means plane 6 in the upper half and plane 2
; in the lower one.
bandTable:
	; HAM6, code 00 -- palette
	dc.l    h6set
	dc.l    bitBuf0,bitBuf1,bitBuf2,bitBuf3
	dc.l    zerosBuf,zerosBuf,zerosBuf,zerosBuf
	; HAM6, code 10 -- modify red
	dc.l    h6red
	dc.l    bitBuf0,bitBuf1,bitBuf2,bitBuf3
	dc.l    zerosBuf,onesBuf,zerosBuf,zerosBuf
	; HAM6, code 11 -- modify green
	dc.l    h6green
	dc.l    bitBuf0,bitBuf1,bitBuf2,bitBuf3
	dc.l    onesBuf,onesBuf,zerosBuf,zerosBuf
	; HAM6, code 01 -- modify blue
	dc.l    h6blue
	dc.l    bitBuf0,bitBuf1,bitBuf2,bitBuf3
	dc.l    onesBuf,zerosBuf,zerosBuf,zerosBuf

	; HAM8, code 00 -- palette
	dc.l    h8set
	dc.l    zerosBuf,zerosBuf
	dc.l    bitBuf0,bitBuf1,bitBuf2,bitBuf3,bitBuf4,bitBuf5
	; HAM8, code 10 -- modify red
	dc.l    h8red
	dc.l    zerosBuf,onesBuf
	dc.l    bitBuf0,bitBuf1,bitBuf2,bitBuf3,bitBuf4,bitBuf5
	; HAM8, code 11 -- modify green
	dc.l    h8green
	dc.l    onesBuf,onesBuf
	dc.l    bitBuf0,bitBuf1,bitBuf2,bitBuf3,bitBuf4,bitBuf5
	; HAM8, code 01 -- modify blue
	dc.l    h8blue
	dc.l    onesBuf,zerosBuf
	dc.l    bitBuf0,bitBuf1,bitBuf2,bitBuf3,bitBuf4,bitBuf5

	dc.l    0


; PTRBLOCK -- the eight pointer MOVE pairs of one band, emitted as zero and
; filled in at startup from bandTable. Sixteen MOVEs take 32 color clocks;
; started at hpos $01 they are all done by hpos $23, well ahead of DDFSTRT.
PTRBLOCK	MACRO
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
	ENDM


copper:
	dc.w    FMODEREG,FMODE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0024
	dc.w    BPLCON3,$0000
	dc.w    BPLCON4,$0011           ; AGA defaults (no bitplane colour XOR)
	dc.w    DIWSTRT,DIW_START
	dc.w    DIWSTOP,DIW_STOP
	dc.w    DDFSTRT,DDF_START
	dc.w    DDFSTOP,DDF_STOP
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000

	;
	; HAM6 band 1 (lines $30-$43): code 00, the palette
	;
	dc.w    $3001,$FFFE
h6set:
	PTRBLOCK
	dc.w    BPLCON0,BPLCON0_HAM6

	;
	; HAM6 band 2 (lines $44-$57): code 10, modify red
	;
	dc.w    $4401,$FFFE
h6red:
	PTRBLOCK

	;
	; HAM6 band 3 (lines $58-$6B): code 11, modify green
	;
	dc.w    $5801,$FFFE
h6green:
	PTRBLOCK

	;
	; HAM6 band 4 (lines $6C-$7F): code 01, modify blue
	;
	dc.w    $6C01,$FFFE
h6blue:
	PTRBLOCK

	;
	; Copper timing ruler (from ddf1), between the two halves. Each MOVE
	; takes 4 color clocks, i.e. 8 lores pixels, so the stripes measure
	; copper timing straight across the display. Bitplane DMA is switched
	; off first: left running it would steal slots from the copper and the
	; stripe train would no longer be evenly spaced.
	;
	dc.w    $8001,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF
	dc.w    COLOR00,$000
	dc.w    $8800+DDF_START+1,$FFFE ; ruler starts where the data does
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
	; HAM8 band 1 (lines $90-$A3): code 00, the palette
	;
	dc.w    $9001,$FFFE
h8set:
	PTRBLOCK
	dc.w    BPLCON0,BPLCON0_HAM8

	;
	; HAM8 band 2 (lines $A4-$B7): code 10, modify red
	;
	dc.w    $A401,$FFFE
h8red:
	PTRBLOCK

	;
	; HAM8 band 3 (lines $B8-$CB): code 11, modify green
	;
	dc.w    $B801,$FFFE
h8green:
	PTRBLOCK

	;
	; HAM8 band 4 (lines $CC-$DF): code 01, modify blue
	;
	dc.w    $CC01,$FFFE
h8blue:
	PTRBLOCK

	;
	; Done -- shut the display down again.
	;
	dc.w    $E001,$FFFE
	dc.w    BPLCON0,BPLCON0_OFF

	dc.l    $fffffffe

	cnop    0,8
bitBuf0:  ds.b PLANE_SIZE
	cnop    0,8
bitBuf1:  ds.b PLANE_SIZE
	cnop    0,8
bitBuf2:  ds.b PLANE_SIZE
	cnop    0,8
bitBuf3:  ds.b PLANE_SIZE
	cnop    0,8
bitBuf4:  ds.b PLANE_SIZE
	cnop    0,8
bitBuf5:  ds.b PLANE_SIZE
	cnop    0,8
onesBuf:  ds.b PLANE_SIZE
	cnop    0,8
zerosBuf: ds.b PLANE_SIZE
