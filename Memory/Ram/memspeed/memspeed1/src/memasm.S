        XDEF _speed_test

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


        section code, code

_speed_test:
        subq.w  #1, d0 ; for dbf

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
.l:
        rept 1000
        tst.b   (a0)
        endr
        dbf     d0, .l
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


