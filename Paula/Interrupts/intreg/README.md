## Objective

Test timing behaviour of INTENA, INTENAR, INTREQ, and INTREQR

#### intreg1

This test syncs the CPU in the upper part of each frame (magenta area). After that, the CPU enters a loop where it reads INTENA and translates the contents to a certain background color. The Copper is utilized to set and clear bits in INTENA at certain positions. No interrupts are triggered in this test.

#### intreg1b - intreg1d

Variants of intreg1 with a modified CPU polling loop.

#### intreg2

Same as intreg1 for register INTREQ.

#### flicker

The CPU runs in an infinite loop. In each iteration, it reads the VERTB bit in INTREQR and changes the background color to green if the bit is set. The Copper changes the color back to red and black. On the real machine, the upper area toggles between green and black which means that the bit is sometimes 1 and sometimes 0. In the latter case, the IRQ handler has been executed before the CPU was able to check the bit. 

#### flicker2

Same as flicker1 with the Copper disabled.


Dirk Hoffmann, 2019
