	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2-a6,-(a7) 

    lea     values,a2               ; Result storage
    lea     payload,a3 
    move.l  a3,a4                   ; Save a copy in a4

.loop:

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

    ; Write all registers into memory
    fmovem  fp0-fp7,payload

    ; Perform test
    fmove.l #$50,FPCR               ; Rounding should have no effect for fmovem
    moveq   #$0F,d0
    fmovem  (a3),d0
    moveq   #$F0,d1
    fmovem  48(a3),d1
    
    ; Write all registers into the result area 
    fmovem  fp0-fp7,(a2)

    ; Display in the last slot how much a3 has changed
    sub.l   a4,a3                   ; a4 stores the original value
    addq    #1,a3                   ; +1 to make the value visible among many zeroes
    move.l  a3,188(a2)              

    movem.l (a7)+,d0/d1/a2-a6
    rte

info: 
    dc.b    'FMOVEMEADN1 (FMOVEM.X <EA>,DN)', 0
    even 

payload:
    ds.b    128,0

expected:
    dc.b    $3F,$FD,$00,$00,  $DE,$5B,$D8,$A9  ; 1
    dc.b    $37,$28,$71,$95,  $3F,$FE,$00,$00  ; 2
    dc.b    $B1,$72,$17,$F7,  $D1,$CF,$79,$AC  ; 3
    dc.b    $40,$00,$00,$00,  $93,$5D,$8D,$DD  ; 4
    dc.b    $AA,$A8,$AC,$17,  $3F,$FF,$00,$00  ; 5
    dc.b    $80,$00,$00,$00,  $00,$00,$00,$00  ; 6
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 7
    dc.b    $21,$68,$C2,$35,  $3F,$FD,$00,$00  ; 8
    dc.b    $9A,$20,$9A,$84,  $FB,$CF,$F7,$98  ; 9
    dc.b    $40,$00,$00,$00,  $AD,$F8,$54,$58  ; 10
    dc.b    $A2,$BB,$4A,$9A,  $3F,$FF,$00,$00  ; 11
    dc.b    $B8,$AA,$3B,$29,  $5C,$17,$F0,$BC  ; 12
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 14
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 16
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 18
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 20
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 22
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$01  ; 24
