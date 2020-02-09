## Objective

Verification of CIA timers and related interrupts.

#### timer1

Starts timers CIAA::A and CIAB::A in the IRQ level 1 handler. When the timers fire, the IRQ level 2 handler or the level 6 IRQ handler is called, respectively. The background color is changed to enable timing verification.

#### timer2

Same as timer1 for timers CIAA::B and CIAB::B and different timer values.

#### timer3, timer3b, timer3c

Starts CIAA::A and CIAB::A as one-shot timers in the IRQ level 1 handler. Right after, the contents of CIAA::CRA and CIAB::CRA is read and visualized by color stripes. timer3b and timer3c differ in the initial CRA value ($FF instead of $08) and the point in time where CRA is read (timer3c). 

#### timer4, timer4b, timer4c

Same as timer3 for timers CIAA:B and CIAB::B.

#### timer5, timer5b, timer5c

Modifies TALO, TAHI a second time. The test verifies if and when the latch is copied to the counter registers when the timer is already running.


Dirk Hoffmann, 2020
