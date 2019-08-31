## Objective

Verification of CIA timers and related interrupts.

#### timer1, timer2, timer3

All three tests start timer CIAA::B in the vsync handler. When the timer underflows, a level 2 interrupt is issued. In the interrupt handler, the three tests try different methods to acknowledge the interrupt. timer1 clears the corresponding bit in INTREQ, timer2 clears the corresponding bit in the ICR register of CIA A and timer3 does both. The test pictures reveal that the IRQ bits in both INTREQ and ICR have to be cleared to acknowledge the interrupt. Because timer1 and timer2 fail to acknowledge, the interrupt retriggers immediately. This causes red and white stripes to appear on the screen. 

#### timer4

This test doesn't start the timer. It triggers the level 2 interrupt by writing into INTREQ via the Copper. The test shows that the IRQ is triggered even if the CIA's ICR register has the corresponding IRQ bit set to 0.

#### timer5

This test is a slight modification of timer3. To acknowledge the interrupt, it first writes into INTREQ and then writes into the ICR. The test reveals that the acknowledgment order does not matter. The test produces the same image as timer3. This indicates that Paula is feeding the INTREQ bit and the ICR bit (IRQ line from the CIA) into an OR gate. The output of this gate is then ANDed with the corresponding bit in INTENA. 


Dirk Hoffmann, 2019