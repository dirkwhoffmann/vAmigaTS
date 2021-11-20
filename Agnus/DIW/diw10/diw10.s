	include "../diw.i"

copper:

	; In this block, we switch to unmatchable coordinates which means that the H flop does 
	; not change any more. Before we reach here, the H flop did not toggle either, because  
	; unmatchable coordinates have been set at the end of the Copper list. 
	; Because the H flop is set at the beginning of a frame (this is the hypothesis we want to 
	; prove with this test), the H flop was on all the time. Hence, we see the screen before 
	; and after the following WAIT statement.
	
	dc.w	$8001,$FFFE    ; WAIT 
	dc.w    DIWSTRT,$2801  ; Unmatchable H coordinate
	dc.w    DIWSTOP,$30FF  ; Unmatchable H coordinate

	dc.w    $A001,$FFFE    ; WAIT
	dc.w    DIWSTRT,$28A0  ; Matchable coordinate
	dc.w    DIWSTOP,$30A0  ; Matchable coordinate 

    ; When we reach the following WAIT statement, the H flop is off. Because we switch
	; to unmatchable coordinates, the flop stays off all the time and the screen gets blank.
	
	dc.w    $C101,$FFFE    ; WAIT
	dc.w    DIWSTRT,$2801  ; Unmatchable H coordinate 
	dc.w    DIWSTOP,$30FF  ; Unmatchable H coordinate
	
	dc.l	$fffffffe
