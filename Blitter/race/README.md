## Objective

Tests the behaviour of the BLTPRI bit.

#### race<x>

The test starts two blits where x is the Blitter channel combination. The CPU runs side by side with the Blitter and changes the background color multiple times. The first blit is run with the BLTPRI bit set and the second with the BLTPRI bit cleared.

#### toggle1

Similar to race15. The BLTPRI bit is toggled in the middle of each blit. 


Dirk Hoffmann, 2020
