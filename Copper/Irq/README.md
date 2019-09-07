## Objective

Verfies the timing of Copper-triggered interrupts.

#### irq1

At certain position, the Copper modifies the background color and triggers a Copper interrupt afterwards by writing into INTREQ. In the interrupt handler, a couple of more background changes happen.

#### irq2

Similar to irq1, but the Copper additionally changes the background color to green after INTREQ has been written to.

Dirk Hoffmann, 2019