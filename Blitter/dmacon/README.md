## Objective

To verify the contents of the DMACON register before, after, and in the middle of a Blitter
operation.

#### dmacon1

This test executes two blits in a frame, records the value of DMACON, and  visualizes the 
recorded value in form of color bars. The first Blit is a zero blit, meaning that the D register is 
cleared all the time. Hence, the BZERO flag will be set for this Blit. The second operation is 
a non zero Blit, the D register contains $FFFF all the time. 

In this test, DMACON is recorded after the Blitter has finished the first blit. 

#### dmacon2

Similar to dmacon1, but DMACON is recorded after the Blitter has finished the second blit. 

#### dmacon3

Similar to dmacon1, but DMACON is recorded in the middle of the first blit.

#### dmacon4

Similar to dmacon1, but DMACON is recorded in the middle of the second blit.

#### dmacon5

Similar to dmacon1, but DMACON is recorded directly after the first blit has been started.

#### dmacon6

Similar to dmacon1, but DMACON is recorded directly after the second blit has been started.


Dirk Hoffmann, 2020
