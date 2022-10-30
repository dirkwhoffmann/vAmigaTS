trap0:
	move.w  #$F00,COLOR00(a1)
	rte
	
trapv:
	move.w  #$FF0,COLOR00(a1)
	bra 	retirq            ; Exit trap handler manually

irq1:
	move.w  #$0F0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.l  a7,a6             ; Save stack pointer to color registers
	move.l  #$DFF182,a7       ; Redirect stack pointer to color registers
	move    #$02,CCR
	trapv

irq2:
	move.w  #$0F0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.l  a7,a6             ; Save stack pointer to color registers
	move.l  #$DFF184,a7       ; Redirect stack pointer to color registers
	move    #$02,CCR
	trapv

irq3:
	move.w  #$0F0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.l  a7,a6             ; Save stack pointer to color registers
	move.l  #$DFF186,a7       ; Redirect stack pointer to color registers
	move    #$02,CCR
	trapv

irq4:
	move.w  #$0F0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.l  a7,a6             ; Save stack pointer to color registers
	move.l  #$DFF188,a7       ; Redirect stack pointer to color registers
	move    #$02,CCR
	trapv

irq5:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	rte 

irq6:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	rte 

retirq:
	move.w  #$000,COLOR00(a1)
	move.l  a6,a7             ; Restore stack pointer
	rte
