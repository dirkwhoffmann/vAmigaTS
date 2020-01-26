## Objective

Test timing behaviour of INTENA, INTENAR, INTREQ, and INTREQR

#### intreg1

This test syncs the CPU in the upper part of each frame (magenta area). After that, the CPU enters a loop where it reads INTENA and translates the contents to a certain background color. The Copper is utilized to set and clear bits in INTENA at certain positions. 


Dirk Hoffmann, 2019