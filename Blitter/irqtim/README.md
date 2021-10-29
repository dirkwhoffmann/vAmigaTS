## Objective

Test Blitter interrupt timing

#### cputim1 - cputim6

These tests run the Blitter with various combinations for the channel bits, the fill bit, and the line mode bit. The Copper is utilized to change the background color and to start the Blitter. Once the Blitter terminates, an interrupt is triggered. In the interrupt handler the background color is changed back to black.


Dirk Hoffmann, 2021