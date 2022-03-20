	include "../showcia.i"

runtest:

    lea    values,a2 

    ; Read CIA B registers
    move.b  $BFD000,(a2)+
    move.b  $BFD100,(a2)+
    move.b  $BFD200,(a2)+
    move.b  $BFD300,(a2)+
    move.b  $BFD400,(a2)+
    move.b  $BFD500,(a2)+
    move.b  $BFD600,(a2)+
    move.b  $BFD700,(a2)+
    move.b  $BFD800,(a2)+
    move.b  $BFD900,(a2)+
    move.b  $BFDA00,(a2)+
    move.b  $BFDB00,(a2)+
    move.b  $BFDC00,(a2)+
    move.b  $BFDD00,(a2)+
    move.b  $BFDE00,(a2)+
    move.b  $BFDF00,(a2)+
    rts

info: 
    dc.b    'Register contents of CIA B', 0

expected:
    dc.b    $FF,$FF,$C0,$FF,$FF,$FF,$FF,$FF,$B5,$00,$00,$FF,$00,$10,$00,$80
