        include hardware/custom.i
        include exec/types.i
        include exec/exec.i
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

        lea     gfxname(pc), a1
        jsr     _LVOOldOpenLibrary(a6)
        tst.l   d0
        beq.s   .error
        move.l  d0, a6

        ; Build textattr
        lea     topazname(pc), a1
        move.l  #$00080000, -(a7) ; ta_YSize=8
        move.l  a1, -(a7)         ; ta_Name='topaz.font',0
        move.l  a7, a0
        ; Open Font
        jsr     _LVOOpenFont(a6)
        tst.l   d0
        beq.s   .error
        add.w   #8, a7
        lea     font(pc), a0
        move.l  d0, (a0)

        move.l  a6, a1
        move.l  a5, a6
        jsr     _LVOCloseLibrary(a6)

        move.l  #320*200/8 + copperlist_size, d0
        move.l  #MEMF_CHIP!MEMF_CLEAR, d1
        jsr     _LVOAllocMem(a6)
        tst.l   d0
        beq.s   .error
        move.l  d0, a0  ; coperlist
        lea     copperlist_size(a0), a3  ; bitplane data

        move.l  #$dff000, a6

        ; Disable DMA+Interrupts
        move.w  #$7fff, d0
        move.w  d0, intena(a6)
        bsr.s   waitframe
        move.w  d0, dmacon(a6)

        ; Create copper list
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


        ; Setup 320x200x1 screen
        move.w  #$1200, bplcon0(a6)
        move.w  #$2c81, diwstrt(a6)
        move.w  #$f4c1, diwstop(a6)
        move.w  #$0038, ddfstrt(a6)
        move.w  #$00d0, ddfstop(a6)
        moveq   #0, d0
        move.w  d0, bplcon1(a6)
        move.w  d0, bplcon2(a6)
        move.w  d0, bplcon3(a6)
        move.w  d0, bplcon4(a6)
        move.w  d0, bpl1mod(a6)
        move.w  d0, bpl2mod(a6)
        move.w  d0, fmode(a6)
        move.w  d0, color(a6)
        move.w  #$fff, color+2(a6)

        clr.w   copjmp1(a6) ; reload copper pointer before enabling DMA
        bsr.s   waitframe

        move.w  #$8380, dmacon(a6) ; Copper+bitplanes

.halt:  bra.s   .halt

.error: move.w  #$f00, $dff180
        bra.s   .halt

waitframe:
        btst.b  #0, vposr+1(a6)
        beq.s   waitframe
.wait2: btst.b  #0, vposr+1(a6)
        bne.s   .wait2
        rts

writechar:
        move.l  a0, -(a7)
        move.l  font(pc), a4
        moveq   #0, d1
        move.b  d0, d1
        sub.b   tf_LoChar(a4), d1
        add.w   d1, d1
        add.w   d1, d1
        move.l  tf_CharLoc(a4), a1
        move.w  (a1,d1.w),d1
        lsr.w   #3, d1
        move.l  tf_CharData(a4), a1
        lea     (a1,d1.w), a1
        moveq   #7, d1
.l:     move.b  (a1), (a0)
        add.w   #320/8, a0
        add.w   tf_Modulo(a4), a1
        dbf     d1, .l
        move.l  (a7)+, a0
        addq.w  #1, a0
        rts

writenum:
        movem.l d2-d4, -(a7)
        move.l  d0, d3
        moveq   #7, d2
.l:     rol.l   #4, d3
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
font: ; Need room for one long here

        ; pad
size=bootblock_end-bootblock_start
        printv size
        dcb.b    1024-size, $00
