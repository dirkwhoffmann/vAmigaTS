## Objective

Tests the CIA's 24-bit-counter.

#### tod1

Uses the alarm feature of CIAB to trigger an interrupt in each frame. In the IRQ handler, the background color is modified continously.

#### tod2 and tod3

Checks certain trigger conditions for TOD interrupt. 

#### latch1 to latch9

Tests the TOD's read latch feature. If the counter is latched, the test produces a still image. If the counter is not  latched, the test case produces an animated counting pattern.

Expected result (A500 8A): 

- latch1: Counting
- latch2: Counting
- latch3: Frozen
- latch4: Counting 
- latch5: Counting 
- latch6: Frozen
- latch7: Counting
- latch8: Counting
- latch9: Counting

#### todint1 and todint2 (DEPRECATED)

These tests configure CIAA to trigger TOD interrupts. In the interrupt handler, the values of VPOSR and VHPOSR are displayed, respectively.

#### todint3  (DEPRECATED)

Similar to todint2 for CIAB.

#### todint4

This test matches the counter value with the alarm value while the timer is stopped. It checks if the IRQ is triggered in this state. 

#### todpulse1a  (DEPRECATED)

This test resets the TOD clock of CIA A inside the VERTB IRQ handler. After that, it wait until the TODLO register changes, and display the value of VHPOSR in form of color bars. 

#### todpulse1b and todpulse2b  (DEPRECATED)

Similar to todpulse1a for CIA B (which counts HSYNC pulses). Both test utilize the Copper to trigger an interrupt at a certain location. Inside the IRQ handler the TOD clock of CIA B is reset to 0. After that, the tests wait until the TODLO register changes, and display the value of VHPOSR in form of color bars.

#### toddelay1 to toddelay3 (DEPRECATED)

These tests reset the TOD clock of CIA B and read back TODLO at certain locations. Two tests of this kind are performed and the results are displayed in form of color bars.


Dirk Hoffmann, 2020
