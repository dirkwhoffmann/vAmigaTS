	include "../diw.i"

copper:
	; In this block, we switch to unmatchable coordinates which means that the H flop does 
	; not change any more. Before we reach here, the H flop toggled in each rasterline and is off 
	; when the WAIT position is reached. This means that we switch to a blank screen. 	
	dc.w	$8001,$FFFE  
	dc.w    DIWSTRT,$2801  
	dc.w    DIWSTOP,$30FF

	dc.w    $A001,$FFFE    
	dc.w    DIWSTRT,$28A0  
	dc.w    DIWSTOP,$30A0  	
	dc.l	$fffffffe
	