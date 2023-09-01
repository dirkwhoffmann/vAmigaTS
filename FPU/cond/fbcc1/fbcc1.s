	include "../../fpureg.i"

DUMP    MACRO
        fmove   FPSR,12(a2)
        fmove.x FP0,(a2)
        add     #16,a2
        ENDM

trap0:

    movem.l d0-d3/a2/a3,-(a7) 

    lea     values,a2 
    moveq   #0,d0       ; FPSR payload
    moveq   #15,d2      ; Loop counter (16 iterations)

    fmove.l #0,FPCR

.loop1:
    fmove.l d0,FPSR     ; Setup status register 

    moveq   #0,d1       ; Clear result bits

    ; Execute first chunk of test instructions
    fbge    .skip1
    ori     #$0001,d1
.skip1:
    fbgl    .skip2
    ori     #$0002,d1
.skip2: 
    fbgle   .skip3
    ori     #$0004,d1
.skip3: 
    fbgt    .skip4
    ori     #$0008,d1
.skip4: 
    fble    .skip5
    ori     #$0010,d1
.skip5: 
    fblt    .skip6
    ori     #$0020,d1
.skip6: 
    fbnge   .skip7
    ori     #$0040,d1
.skip7: 
    fbngl   .skip8
    ori     #$0080,d1
.skip8: 
    fbngle .skip9
    ori     #$0100,d1
.skip9: 
    fbngt   .skip10
    ori     #$0200,d1
.skip10: 
    fbnle   .skip11
    ori     #$0400,d1
.skip11: 
    fbnlt   .skip12
    ori     #$0800,d1
.skip12: 
    fbseq   .skip13
    ori     #$1000,d1
.skip13: 
    fbsne   .skip14
    ori     #$2000,d1
.skip14: 
    fbsf    .skip15
    ori     #$4000,d1
.skip15: 
    fbst    .skip16
    ori     #$8000,d1
.skip16: 

    move.l  d1,(a2)+

    moveq   #0,d1       ; Clear result bits

    ; Execute second chunk of test instructions

    fboge   .skip17
    ori     #$0001,d1
.skip17:
    fbogl   .skip18
    ori     #$0002,d1
.skip18: 
    fbor    .skip19
    ori     #$0004,d1
.skip19: 
    fbogt   .skip20
    ori     #$0008,d1
.skip20: 
    fbole   .skip21
    ori     #$0010,d1
.skip21: 
    fbolt   .skip22
    ori     #$0020,d1
.skip22: 
    fbuge   .skip23
    ori     #$0040,d1
.skip23: 
    fbueq   .skip24
    ori     #$0080,d1
.skip24: 
    fbun    .skip25
    ori     #$0100,d1
.skip25: 
    fbugt   .skip26
    ori     #$0200,d1
.skip26: 
    fbule   .skip27
    ori     #$0400,d1
.skip27: 
    fbult   .skip28
    ori     #$0800,d1
.skip28: 
    fbeq    .skip29
    ori     #$1000,d1
.skip29: 
    fbne    .skip30
    ori     #$2000,d1
.skip30: 
    fbf     .skip31
    ori     #$4000,d1
.skip31: 
    fbt     .skip32
    ori     #$8000,d1
.skip32: 

    add.l   #$01000000,d0
    dbra    d2,.loop1

    movem.l (a7)+,d0-d3/a2/a3
    rte

info: 
    dc.b    'FBCC1', 0
    even 

spare:
    dc.s    16,0

expected:
    dc.b    $00,$00,$53,$F0,  $00,$00,$50,$3F  ; 1
    dc.b    $00,$00,$53,$F0,  $00,$00,$50,$3F  ; 2
    dc.b    $00,$00,$65,$6A,  $00,$00,$40,$2A  ; 3
    dc.b    $00,$00,$65,$6A,  $00,$00,$40,$2A  ; 4
    dc.b    $00,$00,$5D,$89,  $00,$00,$50,$3F  ; 5
    dc.b    $00,$00,$5D,$89,  $00,$00,$50,$3F  ; 6
    dc.b    $00,$00,$65,$6A,  $00,$00,$40,$2A  ; 7
    dc.b    $00,$00,$65,$6A,  $00,$00,$40,$2A  ; 8
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 10
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
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
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 24
