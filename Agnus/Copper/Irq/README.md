## Objective

Verfies the timing of Copper-triggered interrupts.

#### irq1

At certain position, the Copper modifies the background color and triggers a Copper interrupt afterwards by writing into INTREQ. In the interrupt handler, a couple of more background changes happen.

#### irq2

Similar to irq1, but the Copper additionally changes the background color to green after INTREQ has been written to.

#### irq3

Utilizes the Copper to trigger a level 4 interrupt which sends the CPU into a NOP field. After that, a level 5 is triggerd which changes the background color three times. Because the INTREQ bit is not cleared, the IRQ retriggers continously.

#### irq4

Utilizes the Copper to trigger a level 4 interrupt which sends the CPU into a NOP field. After that, a level 5 is triggerd and disabled immediately afterwards. The test case shows that the level 5 interrupt is never executed: 

	dc.w 	INTREQ,$8800         ; Trigger a level 5 interrupt
	dc.w 	INTENA,$0800         ; Disable level 5 interrupts

Dirk Hoffmann, 2019