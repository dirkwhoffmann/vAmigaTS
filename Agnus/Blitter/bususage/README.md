## Objective

Test Blitter bus cycles

#### bususageX

These tests run the copy Blitter with the channel enable bits ABCD set to X. The Copper is utilized to trigger interrupts. Inside the interrupt handler, the CPU launches the Blitter and changes the background color a couple of times. Because the CPU has to compete with the Blitter for the bus, the color stripes get shifted by a certain amount of pixels. 

#### bususageXf

Same as bususageX with the Blitter running in fill mode.

#### bususageXl

Similar to bususageX with the Blitter running in line mode.


Dirk Hoffmann, 2021