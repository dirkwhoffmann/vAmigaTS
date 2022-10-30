	include "../showcia.i"

runtest:

    lea    values,a2 

    ; Read CIA A registers
    move.b  $BFE001,(a2)+
    move.b  $BFE101,(a2)+
    move.b  $BFE201,(a2)+
    move.b  $BFE301,(a2)+
    move.b  $BFE401,(a2)+
    move.b  $BFE501,(a2)+
    move.b  $BFE601,(a2)+
    move.b  $BFE701,(a2)+
    move.b  $BFE801,(a2)+
    move.b  $BFE901,(a2)+
    move.b  $BFEA01,(a2)+
    move.b  $BFEB01,(a2)+
    move.b  $BFEC01,(a2)+
    move.b  $BFED01,(a2)+
    move.b  $BFEE01,(a2)+
    move.b  $BFEF01,(a2)+
    rts

info: 
    dc.b    'Register contents of CIA A', 0

expected:
    dc.b    $FC,$FF,$03,$00,$FF,$FF,$CB,$02,$8D,$00,$00,$FF,$02,$00,$00,$08
