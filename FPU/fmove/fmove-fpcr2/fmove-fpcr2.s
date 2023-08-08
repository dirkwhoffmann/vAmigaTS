	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2/a3,-(a7) 

    lea     values,a2 

    ; Load some values
    fmove   #$ABCDABCD,FPCR
    fmove   #$BCDABCDA,FPSR
    fmove   #$CDABCDAB,FPIAR

    ; Execute the instruction under test
    fmovem  fpcr,(a2)+
    fmovem  fpsr,(a2)+
    fmovem  fpiar,(a2)+
    fmovem  fpcr/fpsr,(a2)+
    fmovem  fpcr/fpiar,(a2)+
    fmovem  fpsr/fpiar,(a2)+
    fmovem  fpcr/fpsr/fpiar,(a2)+

    fmove   #$12345678,FPCR
    fmove   #$34567812,FPSR
    fmove   #$56781234,FPIAR

    fmovem  fpcr,(a2)
    fmovem  fpsr,4(a2)
    fmovem  fpiar,8(a2)
    fmovem  fpcr/fpsr,12(a2)
    fmovem  fpcr/fpiar,16(a2)
    fmovem  fpsr/fpiar,20(a2)
    fmovem  fpcr/fpsr/fpiar,24(a2)

    lea     values+24*8,a2 
    fmovem  fpcr,-(a2)
    fmovem  fpsr,-(a2)
    fmovem  fpiar,-(a2)
    fmovem  fpcr/fpsr,-(a2)
    fmovem  fpcr/fpiar,-(a2)
    fmovem  fpsr/fpiar,-(a2)
    fmovem  fpcr/fpsr/fpiar,-(a2)

    movem.l (a7)+,d0/d1/a2/a3
    rte

info: 
    dc.b    'FMOVE-FPCR2', 0
    even 

expected:
    dc.b    $00,$00,$AB,$C0,  $0C,$DA,$BC,$D8  ; 1
    dc.b    $CD,$AB,$CD,$AB,  $00,$00,$AB,$C0  ; 2
    dc.b    $0C,$DA,$BC,$D8,  $00,$00,$AB,$C0  ; 3
    dc.b    $CD,$AB,$CD,$AB,  $0C,$DA,$BC,$D8  ; 4
    dc.b    $CD,$AB,$CD,$AB,  $00,$00,$AB,$C0  ; 5
    dc.b    $0C,$DA,$BC,$D8,  $CD,$AB,$CD,$AB  ; 6
    dc.b    $00,$00,$56,$70,  $04,$56,$78,$10  ; 7
    dc.b    $56,$78,$12,$34,  $00,$00,$56,$70  ; 8
    dc.b    $00,$00,$56,$70,  $04,$56,$78,$10  ; 9
    dc.b    $00,$00,$56,$70,  $04,$56,$78,$10  ; 10
    dc.b    $56,$78,$12,$34,  $00,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 14
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 16
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 18
    dc.b    $00,$00,$56,$70,  $04,$56,$78,$10  ; 19
    dc.b    $56,$78,$12,$34,  $04,$56,$78,$10  ; 20
    dc.b    $56,$78,$12,$34,  $00,$00,$56,$70  ; 21
    dc.b    $56,$78,$12,$34,  $00,$00,$56,$70  ; 22
    dc.b    $04,$56,$78,$10,  $56,$78,$12,$34  ; 23
    dc.b    $04,$56,$78,$10,  $00,$00,$56,$70  ; 24
