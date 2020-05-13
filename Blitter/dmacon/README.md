## Objective

Displays the contents of the DMACON register at certain points in time.

#### dmacon1

Triggers a Blitter operation and records the value of DMACON while the Blitter is still running.

#### dmacon2

Triggers a Blitter operation and records the value of DMACON after the Blitter has terminated.

#### dmacon3 and dmacon4

Same as dmacon1 resp. dmacon2 with the BLTPRI set to 1.

#### dmacon5

Same setup as in dmacon4 with Blitter DMA disabled.

#### dmacon6

This test starts a blit and reads back DMACONR immediately. It shows that the BBUSY bit is set immediately. 

Dirk Hoffmann, 2019 - 2020
