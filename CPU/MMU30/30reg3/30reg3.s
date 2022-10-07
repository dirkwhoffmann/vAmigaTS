	include "../30reg.i"

trap0:

    ; Write some values into the MMU registers
    lea    payload,a2 
    pmove  (a2),MMUSR
    addq   #2,a2
    pmovefd  (a2),TC
    addq   #4,a2
    pmovefd  (a2),TT0
    addq   #4,a2
    pmovefd  (a2),TT1
    addq   #4,a2
    pmovefd  (a2),CRP
    addq   #8,a2
    pmovefd  (a2),SRP
    addq   #8,a2

    ; Read back values
    lea    values,a2 
    pmove  MMUSR,(a2)
    addq   #2,a2
    pmove  TC,(a2)
    addq   #4,a2 
    pmove  TT0,(a2)
    addq   #4,a2 
    pmove  TT1,(a2)
    addq   #4,a2 
    pmove  CRP,(a2)
    addq   #8,a2 
    pmove  SRP,(a2)
    addq   #8,a2 
    rte

info: 
    dc.b    '30REG3: PMOVEFD TEST', 0
    even 

payload:
    dc.b    $00,$01,$02,$03,$14,$15,$16,$17,$20,$21,$22,$23,$34,$35,$36,$37
    dc.b    $40,$41,$42,$43,$54,$55,$56,$57,$60,$61,$62,$63,$74,$75,$76,$77

expected:
	dc.w   	$0001
	dc.w   	$0203
	dc.w   	$1415
	dc.w   	$1617
	dc.w   	$0021
	dc.w   	$2223
	dc.w   	$0435
	dc.w   	$3637
	dc.w   	$4041
	dc.w   	$4243
	dc.w   	$5455
	dc.w   	$5657
	dc.w   	$6061
	dc.w   	$6263
	dc.w   	$7475
	dc.w   	$0000
