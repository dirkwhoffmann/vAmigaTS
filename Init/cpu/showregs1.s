;TODO:
;       alloc mem just below "a5" and create a jump table for functions to use in "fistpart"

        include hardware/custom.i
        ;include hardware/cia.i
        ;include hardware/intbits.i
        ;include hardware/dmabits.i
        ;include hardware/adkbits.i
        include exec/types.i
        include exec/exec.i
        ;include exec/memory.i
        include graphics/text.i

_LVOAllocMem           equ     -198
_LVOOldOpenLibrary     equ     -408
_LVOCloseLibrary       equ     -414

_LVOOpenFont           equ     -72

copperlist_size=12

bootblock_start:
        dc.b 'DOS', 0   ; Disk type + flags
        dc.l 0          ; Checksum
        dc.l 880        ; Root block

        ; a1 = IO Request, a6 = SysBase
start:
        movem.l d0-a7, -(a7)    ; Store registers
        move.l  a6, a5          ; Execbase in a5

        move.w  #$f00, $dff180

        lea     gfxname(pc), a1
        jsr     _LVOOldOpenLibrary(a6)
        tst.l   d0
        beq.s   .halt
        move.l  d0, a6

        ; Build textattr
        lea     topazname(pc), a1
        move.l  #$00080000, -(a7) ; ta_YSize=8
        move.l  a1, -(a7)         ; ta_Name='topaz.font',0
        move.l  a7, a0
        ; Open Font
        jsr     _LVOOpenFont(a6)
        add.w   #8, a7
        move.l  d0, a0
        move.l  tf_CharData(a0), a4 ; store character data in a4

        move.l  a6, a1
        move.l  a5, a6
        jsr     _LVOCloseLibrary(a6)

        move.l  #320*256/8 + copperlist_size, d0
        move.l  #MEMF_CHIP!MEMF_CLEAR, d1
        jsr     _LVOAllocMem(a6)
        tst.l   d0
        beq.s   .halt
        move.l  d0, a0  ; coperlist
        lea     copperlist_size(a0), a3  ; bitplane data

        move.l  #$dff000, a6

        move.w  #$7fff, d1
        move.w  d0, intena(a6)
        move.w  d0, dmacon(a6)

        move.l  a0, cop1lc(a6)
        move.l  a3, d0
        move.w  #bplpt+2, (a0)+
        move.w  d0, (a0)+
        swap    d0
        move.w  #bplpt, (a0)+
        move.w  d0, (a0)+
        move.l  #-2, (a0)


        move.l  a3, a0
        move.l  a7, a2
        lea     regnames(pc), a5
        moveq   #15, d2
.l:
        move.b  (a5)+, d0
        bsr.s   writechar
        move.b  (a5)+, d0
        bsr.s   writechar
        move.b  #'=', d0
        bsr.s   writechar
        move.b  #'$', d0
        bsr.s   writechar
        move.l  (a2)+, d0
        bsr.s   writenum
        add.w   #320-12, a0
        dbf     d2, .l


        move.w  #$1200, bplcon0(a6)
        moveq   #0, d0
        move.w  d0, bplcon1(a6)
        move.w  d0, bplcon2(a6)
        move.w  d0, color(a6)
        move.w  #$fff, color+2(a6)

        move.w  #$c180, dmacon(a6) ; Copper+bitplanes

.halt:
        bra.s   .halt


writechar:
        move.l  a0, -(a7)
        moveq   #0, d1
        move.b  d0, d1
        sub.b   #32, d1
        lea     (a4,d1.w), a1
        moveq   #7, d1
.l:     move.b  (a1), (a0)
        add.w   #320/8, a0
        add.w   #256-64, a1
        dbf     d1, .l
        move.l  (a7)+, a0
        addq.w  #1, a0
        rts

writenum:
        movem.l d2-d4, -(a7)
        move.l  d0, d3
        moveq   #7, d2
.l:
        rol.l   #4, d3
        move.b  d3, d0
        and.b   #$f, d0
        add.b   #'0', d0
        cmp.b   #'9', d0
        ble.s   .wr
        add.b   #'a'-'0'-10, d0
.wr:    bsr.s   writechar
        dbf     d2, .l
        movem.l (a7)+, d2-d4
        rts

gfxname:        dc.b 'graphics.library', 0
topazname:      dc.b 'topaz.font', 0
        even

regnames:
        dc.b 'D0', 'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7'
        dc.b 'A0', 'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7'

bootblock_end:

        ; pad
size=bootblock_end-bootblock_start
        printv size
        dcb.b    1024-size, $00
