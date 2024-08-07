	include "../../fpureg.i"

trap0:

    movem.l d0/d1/d2/a2/a3,-(a7) 

    lea     values,a2 
    lea     payload,a3 
    moveq   #11,d1      ; Loop counter (12 iterations)
    moveq   #0,d0       ; FPCR payload 

.loop:

    ; Setup control register
    fmove.l d0,FPCR
    add     #$10,d0

    ; Load a floating-point value from a register and write it back
    move.l  (a3)+,d2
    fmove.w d2,FP0
    fmove   FPCR,8(a2)
    fmove   FPSR,12(a2)
    fmove.x FP0,(a2)

    add     #16,a2

    dbra    d1,.loop

    movem.l (a7)+,d0/d1/d2/a2/a3
    rte

info: 
    dc.b    'FMOVE5-W', 0
    even 

payload:
    dc.b    $81,$82,$83,$84,$85,$86,$87,$88,$89,$0A,$0B,$0C,$0D,$0E,$0F,$10
    dc.b    $11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20
    dc.b    $81,$82,$83,$84,$85,$86,$87,$88,$89,$0A,$0B,$0C,$0D,$0E,$0F,$10
    dc.b    $11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20
    dc.b    $81,$82,$83,$84,$85,$86,$87,$88,$89,$0A,$0B,$0C,$0D,$0E,$0F,$10
    dc.b    $11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20
    dc.b    $81,$82,$83,$84,$85,$86,$87,$88,$89,$0A,$0B,$0C,$0D,$0E,$0F,$10
    dc.b    $11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20
    dc.b    $81,$82,$83,$84,$85,$86,$87,$88,$89,$0A,$0B,$0C,$0D,$0E,$0F,$10
    dc.b    $11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20

expected:
    dc.b    $C0,$0D,$00,$00,  $F8,$F8,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$00  ; 2
    dc.b    $C0,$0D,$00,$00,  $F0,$F0,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$00  ; 4
    dc.b    $40,$0A,$00,$00,  $B0,$C0,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 6
    dc.b    $40,$0A,$00,$00,  $F1,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 8
    dc.b    $40,$0B,$00,$00,  $98,$A0,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 10
    dc.b    $40,$0B,$00,$00,  $B8,$C0,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
    dc.b    $40,$0B,$00,$00,  $D8,$E0,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 14
    dc.b    $40,$0B,$00,$00,  $F9,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 16
    dc.b    $C0,$0D,$00,$00,  $F8,$F8,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$00  ; 18
    dc.b    $C0,$0D,$00,$00,  $F0,$F0,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$00  ; 20
    dc.b    $40,$0A,$00,$00,  $B0,$C0,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 22
    dc.b    $40,$0A,$00,$00,  $F1,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 24
