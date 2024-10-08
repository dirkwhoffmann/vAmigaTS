	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2/a3,-(a7) 

    lea     values,a2 
    lea     payload,a3 
    moveq   #11,d1      ; Loop counter (12 iterations)
    moveq   #0,d0       ; FPCR payload 

.loop:

    ; Setup control register
    fmove.l d0,FPCR
    add     #$10,d0

    ; Load a floating-point value from memory and write it back
    fmove.p (a3)+,FP0
    fmove   FPSR,12(a2)
    fmove   FP0,FP1
    fmove.p FP1,(a2)

    add     #16,a2

    dbra    d1,.loop

    movem.l (a7)+,d0/d1/a2/a3
    rte

info: 
    dc.b    'FMOVE4-P', 0
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
    dc.b    $81,$82,$00,$04,  $85,$86,$87,$88  ; 1
    dc.b    $89,$10,$11,$12,  $08,$00,$01,$08  ; 2
    dc.b    $03,$13,$10,$01,  $11,$21,$31,$41  ; 3
    dc.b    $51,$61,$71,$79,  $00,$00,$01,$08  ; 4
    dc.b    $09,$21,$00,$01,  $22,$32,$42,$52  ; 5
    dc.b    $08,$18,$28,$38,  $00,$00,$01,$88  ; 6
    dc.b    $85,$86,$00,$08,  $89,$10,$11,$12  ; 7
    dc.b    $13,$14,$15,$09,  $08,$00,$01,$88  ; 8
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $02,$00,$13,$C8  ; 10
    dc.b    $00,$38,$00,$03,  $40,$28,$23,$46  ; 11
    dc.b    $63,$85,$28,$85,  $00,$00,$13,$C8  ; 12
    dc.b    $FF,$FF,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $0A,$00,$13,$C8  ; 14
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $02,$00,$13,$C8  ; 16
    dc.b    $81,$82,$00,$04,  $85,$86,$87,$88  ; 17
    dc.b    $89,$10,$11,$11,  $08,$00,$03,$C8  ; 18
    dc.b    $03,$08,$00,$01,  $79,$76,$93,$13  ; 19
    dc.b    $48,$62,$31,$57,  $00,$00,$13,$C8  ; 20
    dc.b    $03,$08,$00,$01,  $79,$76,$93,$13  ; 21
    dc.b    $48,$62,$31,$57,  $00,$00,$13,$C8  ; 22
    dc.b    $83,$08,$00,$01,  $79,$76,$93,$13  ; 23
    dc.b    $48,$62,$31,$57,  $08,$00,$13,$C8  ; 24
