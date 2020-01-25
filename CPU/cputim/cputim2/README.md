## Objective

Verify CPU bus access timing.

#### cputim2

Tests CPU bus access timing between two frames. At the bottom of the frame, the CPU gets synced first (magenta stripe, size may differ). After that, an interrupt is issued which starts a CPU color loop. The test is run with 4 bitplanes enabled.


Dirk Hoffmann, 2019
