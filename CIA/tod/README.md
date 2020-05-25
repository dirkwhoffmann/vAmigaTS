## Objective

Tests the CIA's 24-bit-counter.

#### tod1

Uses the alarm feature of CIAB to trigger an interrupt in each frame. In the IRQ handler, the background color is modified continously.

#### tod2 and tod3

Checks certain trigger conditions for TOD interrupt. 

#### latch1 to latch9

Tests the TOD's read latch feature. If the is atched, the test produces a still image. If the counter is not  latched, the test case produces an animated counting pattern.

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

#### todint1 and todint2

These tests configure CIAA to trigger TOD interrupts. In the interrupt handler, the values of VPOSR and VHPOSR are displayed, respectively.

#### todint3

Similar to todint2 for CIAB.


Dirk Hoffmann, 2020
