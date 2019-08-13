## Objective

This test suite verfies some basic sprite properties.

#### attached1

Draws two columns of attached sprites (sprites with the AT bit set).

#### collision1 to collision7

This tests draws two overlapping sprites. One of the two sprites overlaps a portion of the playfield, too. During vBlank, the CLXDAT register is read and split into four 4-bit chunks. After that, the chunks are written into color registers 0 to 3 to make the bit-pattern visible. The test is carried out with different sprite numbers and different values in CLXCON. 

#### collision5s and collision5d

Like collosion5 without toggling between single-playfield and dual-playfield mode. collision5s draws solely in single-playfield mode and collision5d solely in dual-playfield mode.

#### sprites1 to sprites4

Draws sprite 0, 2, 4, and 6 in a distinct column each. Each sprite is repeated 4 times. In the bitplane area, the Copper is used to switch between single-playfield and dual-playfield mode. The test differ in the priority values written to BPLCON2. Inspect the reference pictures carefully. There a subtle differences which are hard to see at first glance. 

#### sprites5

Sets the BPU value in BPLCON0 to 0 around the sprite DMA cycles. 

Dirk Hoffmann, 2019
