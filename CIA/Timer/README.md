## Objective

Verification of CIA timers and related interrupts.

#### timer1, timer2, timer3

All three tests start timer CIAA::B in the vsync handler. When the timer underflows, a level 2 interrupt is issued. In the interrupt handler, the three tests try different methods to acknowledge the interrupt. timer1 clears the corresponding bit in INTREQ, timer2 clears the corresponding bit in the ICR register of CIA A and timer3 does both. The test pictures reveal that the IRQ bits in both INTREQ and ICR have to be cleared to acknowledge the interrupt. Because timer1 and timer2 fail to acknowledge, the interrupt retriggers immediately. This causes red and white stripes to appear on the screen. 

#### timer4

This test doesn't start the timer. It triggers the level 2 interrupt by writing into INTREQ via the Copper. The test shows that the IRQ is triggered even if the CIA's ICR register has the corresponding IRQ bit set to 0.

#### timer5

This test is a slight modification of timer3. To acknowledge the interrupt, it first writes into INTREQ and then writes into the ICR. The test image shows that the interrupt is not acknowledged in the first call to the interrupt handler. The interrupt retriggers. When the interrupt handler is invoked the second time, the interrupt does get acknowledged, because the ICR is already cleared and the write to INTREQ takes effect. Conclusion: Clearing the bit in INTREQ only makes sense if the ICR bit has been cleared. As long as the CIA's interrupt line is held low, the INTREQ bit is reset to 1 immediately. 

Dirk Hoffmann, 2019