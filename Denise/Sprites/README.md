## Objective

This test suite verfies some basic sprite properties.

#### attached1

Draws two columns of attached sprites (sprites with the AT bit set).

#### collision1 to collision7

This tests draws two overlapping sprites. One of the two sprites overlaps a portion of the playfield, too. During vBlank, the CLXDAT register is read and split into four 4-bit chunks. After that, the chunks are written into color registers 0 to 3 to make the bit-pattern visible. The test is carried out with different sprite numbers and different values in CLXCON. 

#### sprites1 to sprites4

Draws sprite 0, 2, 4, and 6 in a distinct column each. Each sprite is repeated 4 times. In the bitplane area, the Copper is used to switch between single-playfield and dual-playfield mode. The test differ in the priority values written to BPLCON2. Inspect the reference pictures carefully. There a subtle differences which are hard to see at first glance. 


Dirk Hoffmann, 2019