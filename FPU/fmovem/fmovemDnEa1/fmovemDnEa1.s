	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2-a6,-(a7) 

    lea     values,a2               ; Result storage
    move.l  a2,a4                   ; Save a copy in a4
    ; lea     payload,a3 

    ; Setup registers
    fmove.l #$00,FPCR
    fmovecr #$00,FP0
    fmovecr #$0B,FP1
    fmovecr #$0C,FP2
    fmovecr #$0D,FP3
    fmovecr #$0E,FP4
    fmovecr #$30,FP5
    fmovecr #$31,FP6
    fmovecr #$32,FP7


    ; Perform test
    fmove.l #$10,FPCR               ; Rounding should have no effect for fmovem
    move.l  #$57,d0
    fmovem  d0,(a2) 
    move.l  #$86,d1
    fmovem  d1,96(a2) 
    
    ; Display in the last slot how much a2 has changed
    sub.l   a4,a2                   ; a4 stores the original value of a2
    addq    #1,a2                   ; +1 to make the value visible among many zeroes
    move.l  a2,188(a4)              ; Difference between a2 and the original value

    movem.l (a7)+,d0/d1/a2-a6
    rte

info: 
    dc.b    'FMOVEMDNEA1 (FMOVEM.X DN,<EA>)', 0
    even 

expected:
    dc.b    $3F,$FD,$00,$00,  $9A,$20,$9A,$84  ; 1
    dc.b    $FB,$CF,$F7,$98,  $3F,$FF,$00,$00  ; 2
    dc.b    $B8,$AA,$3B,$29,  $5C,$17,$F0,$BC  ; 3
    dc.b    $3F,$FE,$00,$00,  $B1,$72,$17,$F7  ; 4
    dc.b    $D1,$CF,$79,$AC,  $40,$00,$00,$00  ; 5
    dc.b    $93,$5D,$8D,$DD,  $AA,$A8,$AC,$17  ; 6
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 8
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 10
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 13
    dc.b    $21,$68,$C2,$35,  $3F,$FE,$00,$00  ; 14
    dc.b    $B1,$72,$17,$F7,  $D1,$CF,$79,$AC  ; 15
    dc.b    $40,$00,$00,$00,  $93,$5D,$8D,$DD  ; 16
    dc.b    $AA,$A8,$AC,$17,  $00,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 18
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 20
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 22
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$01  ; 24
