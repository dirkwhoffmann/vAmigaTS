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
        ; Read some chipset registers
        lea     values,a2
        move.w  dmaconr(a1),(a2)+
        move.w  joy0dat(a1),(a2)+
        move.w  joy1dat(a1),(a2)+
        move.w  clxdat(a1),(a2)+
        move.w  adkcon(a1),(a2)+
        move.w  pot0dat(a1),(a2)+
        move.w  pot1dat(a1),(a2)+
        move.w  potinp(a1),(a2)+
        move.w  serdatr(a1),(a2)+
        move.w  intenar(a1),(a2)+
        move.w  intreqr(a1),(a2)+
        move.w  $0,(a2)+
        move.w  $0,(a2)+
        move.w  $0,(a2)+
        move.w  $0,(a2)+
        move.w  $0,(a2)+

        movem.l d0-a7,-(a7)     ; Store registers
        move.l  $4,a6           ; Execbase in a6
        move.l  $4,a5           ; Execbase in a5

        move.w  #$f00,$dff180   ; Red background => In case of error

        lea     gfxname(pc),a1
        jsr     _LVOOldOpenLibrary(a6)
        tst.l   d0
        beq     .halt
        move.l  d0,a6

        ; Build textattr
        lea     topazname(pc),a1
        move.l  #$00080000,-(a7)  ; ta_YSize=8
        move.l  a1,-(a7)          ; ta_Name='topaz.font',0
        move.l  a7,a0
        ; Open Font
        jsr     _LVOOpenFont(a6)
        tst.l   d0
        beq     .halt
        add.w   #8,a7
        move.l  d0,a0
        move.l  tf_CharData(a0),a4 ; store character data in a4

        move.l  a6,a1
        move.l  a5,a6
        jsr     _LVOCloseLibrary(a6)

        move.l  #320*200/8+copperlist_size,d0
        move.l  #MEMF_CHIP!MEMF_CLEAR,d1
        jsr     _LVOAllocMem(a6)
        tst.l   d0
        beq     .halt
        move.l  d0,a0  ; coperlist
        lea     copperlist_size(a0),a3  ; bitplane data

        move.l  #$dff000,a6

        ; Disable DMA+Interrupts
        move.w  #$7fff,d0
        move.w  d0,intena(a6)
        move.w  d0,dmacon(a6)

        ; Create copper list
        move.l  a0,cop1lc(a6)
        move.l  a3,d0
        move.w  #bplpt+2,(a0)+
        move.w  d0,(a0)+
        swap    d0
        move.w  #bplpt,(a0)+
        move.w  d0,(a0)+
        move.l  #-2,(a0)


        move.l  a3,a0
        lea     values,a2
        lea     regnames(pc),a5
        moveq   #10,d2
.l:
        moveq   #6,d3
.l2
        move.b  (a5)+,d0
        bsr     writechar
        dbf     d3,.l2
        move.b  #' ',d0
        bsr     writechar
        move.b  #'=',d0
        bsr     writechar
        move.b  #' ',d0
        bsr     writechar
        move.b  #'$',d0
        bsr     writechar
        moveq   #0,d0
        move.w  (a2)+,d0
        bsr     writenum
        add.w   #320-15,a0
        dbf     d2,.l


        ; Setup 320x200x1 screen
        move.w  #$1200,bplcon0(a6)
        move.w  #$2c81,diwstrt(a6)
        move.w  #$f4c1,diwstop(a6)
        move.w  #$0038,ddfstrt(a6)
        move.w  #$00d0,ddfstop(a6)
        moveq   #0,d0
        move.w  d0,bplcon1(a6)
        move.w  d0,bplcon2(a6)
        move.w  d0,bplcon3(a6)
        move.w  d0,bplcon4(a6)
        move.w  d0,bpl1mod(a6)
        move.w  d0,bpl2mod(a6)
        move.w  d0,fmode(a6)
        move.w  d0,color(a6)
        move.w  #$FF8,color+2(a6)

        move.w  #$8380,dmacon(a6) ; Copper+bitplanes

.halt:
        bra.s   .halt


writechar:
        move.l  a0,-(a7)
        moveq   #0,d1
        move.b  d0,d1
        sub.b   #32,d1
        lea     (a4,d1.w),a1
        moveq   #7,d1
.l:     move.b  (a1),(a0)
        add.w   #320/8,a0
        add.w   #256-64,a1
        dbf     d1,.l
        move.l  (a7)+,a0
        addq.w  #1,a0
        rts

writenum:
        movem.l d2-d4,-(a7)
        move.l  d0,d3
        moveq   #16,d2
        rol.l   d2,d3
        moveq   #3,d2
.l:
        rol.l   #4,d3
        move.b  d3,d0
        and.b   #$f,d0
        add.b   #'0',d0
        cmp.b   #'9',d0
        ble.s   .wr
        add.b   #'a'-'0'-10,d0
.wr:    bsr.s   writechar
        dbf     d2,.l
        movem.l (a7)+,d2-d4
        rts

gfxname:        dc.b 'graphics.library', 0
topazname:      dc.b 'topaz.font', 0
        even

values:
        ds.w 	16,0

regnames:

        dc.b 'DMACONR'
        dc.b 'JOY0DAT'
        dc.b 'JOY1DAT'
        dc.b 'CLXDAT '
        dc.b 'ADKCONR'
        dc.b 'POT0DAT'
        dc.b 'POT1DAT'
        dc.b 'POTINP '
        dc.b 'SERDATR'
        dc.b 'INTENAR'
        dc.b 'INTREQR'

bootblock_end:

        ; pad
size=bootblock_end-bootblock_start
        printv size
        dcb.b    1024-size, $00
