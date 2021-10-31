## Objective

Test Blitter bus cycles

#### bususage1 - bususage15

These tests run the Blitter with various combinations for the channel bits, the fill bit, and the line mode bit. The Copper is utilized to trigger interrupts. Inside the interrupt handler, the CPU launches the Blitter and changes the background color a couple of times. Because the CPU has to compete with the Blitter for the bus, the color stripes get shifted by a certain amount of pixels. 


Dirk Hoffmann, 2021