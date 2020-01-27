## Objective

Test basic interrupt triggering

#### int1

This test syncs the CPU in the upper part of each frame (magenta area). After that, the Copper is utilized to trigger a level 1, level 2, and level 3 interrupt. Each interrupt handler draws a color stripe. To improve timing visualization, the stack pointer is redirected to the color registers which causes the background color to change when certain elements of the stack frame are written. 

#### int2

This test triggers various level 4 and level 5 interrupts. The Copper is used to set and clear INTREQ/INTENA with various delays in between.

#### int3, int4

Same as int2 with a different CPU delay loop.


Dirk Hoffmann, 2019
