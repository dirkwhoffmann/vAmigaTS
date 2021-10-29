## Objective

Performs several small blits with all 16 bit combinations of USEA/USEB/USEC/USED in BLTCON0

#### timing *n*

*n* is the USEA/USEB/USEC/USED bit combination. The test case prepares the blit operation in the VBLANK interrupt handler. It then uses the Copper to trigger the blit. In the upper part, the blits are run with all bitplanes disabled. In the lower part, 5 bitplanes are enabled. 

#### timing*n*f

Runs the test in exclusive and inclusive fill mode, respectively.

#### timing1l

Runs the Line Blitter instead of the Copy Blitter.


Dirk Hoffmann, 2019