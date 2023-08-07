	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2-a6,-(a7) 

    lea     values+184,a2           ; Result storage
    move.l  a2,a4
    lea     values+188,a5

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
    fmove.l #$60,FPCR               ; Rounding should have no effect for fmovem
    fmovem  fp0-fp2/fp4/fp6,-(a2) 
    fmovem  fp1-fp2/fp7,-(a2)
    fmovem  fp0,-(a2) 
    fmovem  fp0/fp2/fp4/fp6,-(a2) 

    ; Display in the last slot how much a2 has changed
    sub.l   a2,a4                   ; a4 stores the original value of a2
    move.l  a4,(a5)                 ; Difference between a2 and the original value

    movem.l (a7)+,d0/d1/a2-a6
    rte

info: 
    dc.b    'FMOVEMLSEA2 (FMOVEM.X <LIST>,<EA>)', 0
    even 

expected:
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 2
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $40,$00,$00,$00  ; 4
    dc.b    $C9,$0F,$DA,$A2,  $21,$68,$C2,$35  ; 5
    dc.b    $40,$00,$00,$00,  $AD,$F8,$54,$58  ; 6
    dc.b    $A2,$BB,$4A,$9A,  $3F,$FD,$00,$00  ; 7
    dc.b    $DE,$5B,$D8,$A9,  $37,$28,$71,$95  ; 8
    dc.b    $40,$00,$00,$00,  $93,$5D,$8D,$DD  ; 9
    dc.b    $AA,$A8,$AC,$17,  $40,$00,$00,$00  ; 10
    dc.b    $C9,$0F,$DA,$A2,  $21,$68,$C2,$35  ; 11
    dc.b    $3F,$FD,$00,$00,  $9A,$20,$9A,$84  ; 12
    dc.b    $FB,$CF,$F7,$98,  $40,$00,$00,$00  ; 13
    dc.b    $AD,$F8,$54,$58,  $A2,$BB,$4A,$9A  ; 14
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $40,$00,$00,$00  ; 16
    dc.b    $C9,$0F,$DA,$A2,  $21,$68,$C2,$35  ; 17
    dc.b    $3F,$FD,$00,$00,  $9A,$20,$9A,$84  ; 18
    dc.b    $FB,$CF,$F7,$98,  $40,$00,$00,$00  ; 19
    dc.b    $AD,$F8,$54,$58,  $A2,$BB,$4A,$9A  ; 20
    dc.b    $3F,$FD,$00,$00,  $DE,$5B,$D8,$A9  ; 21
    dc.b    $37,$28,$71,$95,  $40,$00,$00,$00  ; 22
    dc.b    $93,$5D,$8D,$DD,  $AA,$A8,$AC,$17  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$9C  ; 24
