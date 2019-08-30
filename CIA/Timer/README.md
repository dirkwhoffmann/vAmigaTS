## Objective

Verification of CIA timers and related interrupts.

#### timer1

This tests starts timer CIAA::B in the vsync handler. When the timer underflows, it triggers a level 2 interrupt. In the interrupt handler, it is tried to acknowledge the interrupt by clearing the corresponding bit in INTREQ. The test shows that this does not work, because the interrupt bit doesn't get cleared in CIAA::ICR. Hence, the interrupt retriggers immediately and causes the red and white stripe pattern to appear on the screen. 


Dirk Hoffmann, 2019