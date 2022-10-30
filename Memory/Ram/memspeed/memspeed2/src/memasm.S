        XDEF _speed_test
        XDEF _tst_b
        XDEF _tst_l

        ;; Assume CIAB timer B is free!!

ciatblo EQU $0600
ciatbhi EQU $0700
ciaicr  EQU $0D00
ciacra  EQU $0E00
ciacrb  EQU $0F00

intenar EQU $01C
dmaconr EQU $002
dmacon  EQU $096
intena  EQU $09A

ITER EQU 200

        section code, code

_tst_b:
        subq.w  #1, d0 ; for dbf
        sub.l   a0, a0
.l:
        rept ITER
        tst.b   (a0)
        endr
        dbf     d0, .l
        rts

_tst_l:
        subq.w  #1, d0 ; for dbf
        sub.l   a0, a0
.l:
        rept ITER
        tst.l   (a0)
        endr
        dbf     d0, .l
        rts

lsr_main:
        subq.w  #1, d0 ; for dbf
        sub.l   a0, a0
.l:
        rept ITER
        lsr.w   d1, d2
        tst.b   (a0)
        endr
        dbf     d0, .l
        rts

lsr_test macro
        XDEF _lsr_\1
_lsr_\1:
        movem.l d1-d2, -(a7)
        moveq   #\1, d1
        bsr     lsr_main
        movem.l (a7)+, d1-d2
        rts
        endm

        lsr_test 1
        lsr_test 2
        lsr_test 3
        lsr_test 4
        lsr_test 5
        lsr_test 6
        lsr_test 7
        lsr_test 8

        XDEF _pure_fast
_pure_fast:
        movem.l d1-d3, -(a7)
        subq.w  #1, d0 ; for dbf
        sub.l   a0, a0
        moveq   #-1, d2
.l:
        move.w  #ITER-1, d1
.l2:
        mulu.w  d2, d3
        dbf     d1, .l2
        dbf     d0, .l
        movem.l (a7)+, d1-d3
        rts

_speed_test:
        lea     $dff000, a1
        move.w  intenar(a1), d1
        or.w    #$8000, d1
        move.w  d1, -(sp)
        move.w  dmaconr(a1), d1
        or.w    #$8000, d1
        move.w  d1, -(sp)
        move.w  #$7fff, d1
        move.w  d1, intena(a1)
        move.w  d1, dmacon(a1)

        lea     $bfd000, a1 ; CIAB (assume free to use)
        move.b  #8, ciacrb(a1) ; one shot mode
        move.b  #$ff, ciatblo(a1)
        move.b  #$ff, ciatbhi(a1) ; starts timer
        jsr     (a0)
        move.b  #0, ciacrb(a1) ; stop timer
        ; Read timer value
        moveq   #0, d1
        move.b  ciatbhi(a1), d1
        lsl.w   #8, d1
        move.b  ciatblo(a1), d1
        move.l  #$ffff, d0
        sub.w   d1, d0

        ; restore intena/dmacon
        lea     $dff000, a1
        move.w  (sp)+, dmacon(a1)
        move.w  (sp)+, intena(a1)

        rts


