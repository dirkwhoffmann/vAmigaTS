trap0:
trapv:
	move.w  #$F00,COLOR00(a1)
	rte
	
	irq1:
	move.w  #$FF0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$F00,COLOR00(a1)

	move.w  #$000,COLOR00(a1)
	move.w  #$000,COLOR01(a1)
	move.w  #$000,COLOR02(a1)

	move.l  #$DFF182,a7   ; Redirect stack pointer to color registers
	move    #$F,SR        ; Restore SR manually  

	bra  	cpuwait       ; Exit IRQ handler manually

irq2:
	move.w  #$FF0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$F00,COLOR00(a1)
	
	move.w  #$000,COLOR00(a1)
	move.w  #$000,COLOR01(a1)
	move.w  #$000,COLOR02(a1)

	move.l  #$DFF184,a7   ; Redirect stack pointer to color registers
	move    #$F,SR        ; Restore SR manually  
	bra 	cpuwait       ; Exit IRQ handler manually

irq3:
	move.w  #$FF0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$F00,COLOR00(a1)

	move.w  #$000,COLOR00(a1)
	move.w  #$000,COLOR01(a1)
	move.w  #$000,COLOR02(a1)

	move.l  #$DFF186,a7   ; Redirect stack pointer to color registers
	move    #$F,SR        ; Restore SR manually  
	bra 	cpuwait       ; Exit IRQ handler manually

irq4:
	move.w  #$FF0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$F00,COLOR00(a1)

	move.w  #$000,COLOR00(a1)
	move.w  #$000,COLOR01(a1)
	move.w  #$000,COLOR02(a1)

	move.l  #$DFF186,a7   ; Redirect stack pointer to color registers
	move    #$F,SR        ; Restore SR manually  
	bra 	mainLoop      ; Branch back to main loop

irq5:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	rte 

irq6:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	rte 
