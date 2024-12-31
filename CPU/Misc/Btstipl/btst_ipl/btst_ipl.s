        include exec/execbase.i
        include lvo/exec_lib.i
        include lvo/dos_lib.i
        include hardware/custom.i
        include hardware/intbits.i

NTESTS=17

custom=$dff000

        opt o-

PRINTF MACRO
        movem.l d0-d3/a0-a2/a6,-(sp)
        sub.l   #200,sp
        move.l  sp,a3
        clr.b   (a3)
CARG set 9
        rept 8
        ifnb \.
        move.l  \.,-(sp)
        endc
CARG set CARG-1
        endr
        lea     .fmt\@(pc),a0
        move.l  sp,a1
        lea     appendchar(pc),a2
        move.l  $4.w,a6
        jsr     _LVORawDoFmt(a6)
        move.l  a3,a0
        bsr     putbstr
        bra     .done\@
.fmt\@  dc.b    \1
        dc.b    0
        even
.done\@
        add     #200+4*(NARG-1),sp
        movem.l (sp)+,d0-d3/a0-a2/a6
        ENDM


start
        move.l  $4.w,a6
        lea     dosname(pc),a1
        jsr     _LVOOldOpenLibrary(a6)
        move.l  d0,dosbase

        move.w  intenar+custom,-(sp)
        move.w  dmaconr+custom,-(sp)

        move.w  #$7fff,d0
        move.w  d0,intena+custom
        move.w  d0,dmacon+custom

        ; XXX: Don't bother VBR, we only care about 68000
        move.l  $6c.w,-(sp)
        move.l  $80.w,-(sp)

        lea     level3(pc),a0
        move.l  a0,$6c.w
        lea     .sup(pc),a0
        move.l  a0,$80.w
        trap    #0
        bra     .done
.sup

        lea     custom,a6
        move.w  #INTF_SETCLR!INTF_VERTB,intena(a6)
        moveq   #0,d7
        lea     results(pc),a5
.loop
        moveq   #0,d6
        move.w  d7,d0
        move.w  #INTF_SETCLR!INTF_INTEN,intena(a6)
        bsr     test
        move.w  #INTF_INTEN,intena(a6)
        move.w  d0,(a5)+
        addq.w  #1,d7
        cmp.w   #NTESTS,d7
        bne     .loop
        move.w  #INTF_VERTB,intena(a6)
        rte

.done
        move.w  #$7fff,intena+custom

        move.l  (sp)+,$80.w
        move.l  (sp)+,$6c.w

        move.w  #$8000,d0
        or.w    (sp)+,d0
        move.w  d0,dmacon+custom

        move.w  #$8000,d0
        or.w    (sp)+,d0
        move.w  d0,intena+custom

        moveq   #0,d7
        moveq   #0,d6
        lea     results(pc),a5
.prloop
        move.w  (a5)+,d6
        PRINTF  <"%ld: %ld", 10>, d7, d6
        addq.w  #1,d7
        cmp.w   #NTESTS,d7
        bne     .prloop

        move.l  $4.w,a6
        move.l  dosbase,a1
        jsr     _LVOCloseLibrary(a6)
        rts

appendchar
        tst.b   d0
        beq     .skip
        move.l  d1,-(sp)
        moveq   #0,d1
        move.b  (a3),d1
        addq.b  #1,d1
        move.b  d0,(a3,d1.w)
        move.b  d1,(a3)
        move.l  (sp)+,d1
.skip
        rts

putbstr
        movem.l d2-d3/a6,-(sp)
        moveq   #0,d3
        move.b  (a0)+,d3
        move.l  a0,d2
        move.l  dosbase,a6
        jsr     _LVOOutput(a6)
        move.l  d0,d1
        jsr     _LVOWrite(a6)
        movem.l (sp)+,d2-d3/a6
        rts

; Entry 44(5/3)
level3
        move.w  #INTF_VERTB,intreq+custom       ; 20(4/1)
        move.w  #INTF_VERTB,intreq+custom       ; 20(4/1)
        addq.w  #1,d6                           ; 4(1/0)
        ; XXX Obviously dangerous in normal circumstances
        cmp.w   #22,d6                          ; 8(2/0)
        bne.b   .out                            ; 10(2/0) [taken]
        pea     exitloop(pc)
        move.l  (sp)+,2(sp)
.out
        ; Waste some cycles for alignment
        nop
        nop
        rte                                     ; 20(5/0)

test
        moveq   #0,d5
        moveq   #0,d6
        stop    #$2000
        nop
        stop    #$2000
        lsr.w   d0,d1
.loop:
        btst.b  #INTB_VERTB,intreqr+1(a6)       ; 16(4/0)
        beq.b   .loop                           ; 10(2/0) [taken]
        nop
        nop
        addq.w  #1,d5
        cmp.w   #10,d5
        bne     .loop
exitloop
        move.w  d5,d0
        rts

dosname
        dc.b    'dos.library',0
        even
dosbase
        ds.l    1
results
        ds.w    NTESTS
