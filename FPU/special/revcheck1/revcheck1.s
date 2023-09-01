	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2/a3,-(a7) 

    lea     values,a2 

    ; Run the 68882 test.
    bsr     test68882

    ; Display "68881" or "68882" in the first row (left value)
    move.l  #$68881,(a2)
    cmp.b   #0,d0
    beq     .skip
    move.l  #$68882,(a2)
    addq    #4,a2
.skip:
    ; Displays the stack frame size in the first row (right value)
    move.l  d2,(a2)+

    ; Display the stack frame in line 2 and below
    ; fsave   (a2)

    movem.l (a7)+,d0/d1/a2/a3
    rte

; Returns true in d0 iff an MC68882 is installed. Returns the stack frame size in d2.
; Adapted from https://forums.atariage.com/topic 192508-motorola-68881-68882-math-co-processors/page/2/
test68882:
   move.l   d1,-(sp)
   moveq.l  #0,d0
   moveq.l  #0,d1
   move.l   sp,d2
   fsave    -(sp)
   sub.l    sp,d2
   move.b   1(sp),d1
   cmp.b    #$18,d1
   beq.s    .is68881
   moveq.l  #1,d0
.is68881:
   frestore (sp)+
   move.l   (sp)+,d1
   rts

info: 
    dc.b    'REVCHECK1', 0
    even 

spare:
    dc.s    16,0

expected:
    dc.b    $00,$06,$88,$82,  $00,$00,$00,$3C  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 2
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 4
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 6
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 8
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
