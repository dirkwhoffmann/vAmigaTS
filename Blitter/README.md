## Objective

#### timing

These tests several small blits with all 16 bit combinations of USEA/USEB/USEC/USED in BLTCON0. Blitter timing is visualized in form of color stripes. The Copper is utilized to both start the Blitter and to recognize when the Blitter has terminated.  In the upper part, the blits are run with all bitplanes disabled. In the lower part, all 6 bitplanes are enabled. 

#### irqtim

Similar to timing with a different method to recognize Blitter termination. Instead of the Copper, the Blitter interrupt is utilized to change the stripe color back to black.


Dirk Hoffmann, 2021