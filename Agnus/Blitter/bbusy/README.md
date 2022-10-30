## Objective

Test BBUSY bit timing.

#### bbusyX

These tests run the copy Blitter with the channel enable bits ABCD set to X. The Copper is utilized to trigger interrupts. Inside the interrupt handler, the CPU launches the Blitter, waits until the BBUSY bit is cleared and changes the background color back to black. 

#### bbusyXf

Same as bbusyX with the Blitter running in fill mode.

#### bbusyXl

Similar to bbusyX with the Blitter running in line mode.


Dirk Hoffmann, 2021