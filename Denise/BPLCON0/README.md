## Objective

The tests in this test suite modify register BPLCON0 in various ways.

#### dual1

Toggles between single-playfield mode and dual-playfield mode at certain DMA cycle positions. 

#### dual2 and dual3

Similar to dual1, with the priorities of one or both playfields set to illegal values. 

#### hires1

Draws an image in hires mode and reduces the number of bitplanes after each color block.

#### hires2

Enables hires mode with invalid bpu values (5,6,7).

#### hires3 

Switches back and forth between valid and invalid bpu values.

#### hires4 

Switches back and forth between hires and lowres mode.

#### invplanes1

Switches on 7 bitplanes (invalid value) and manually writes to BPL5DAT and BPL6DAT.

#### ham1

Switches on 7 bitplanes (invalid value) in HAM mode and manually writes to BPL5DAT and BPL6DAT.


Dirk Hoffmann, 2019 - 2020
