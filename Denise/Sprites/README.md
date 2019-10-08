## Objective

This test suite verfies some basic sprite properties.

#### sprdma1 to sprdma3

Toggles the SPRDMA bit in DMACON at certain positions.

#### attached1

Draws two columns of attached sprites (sprites with the AT bit set).

#### collision1 to collision7

This tests draws two overlapping sprites. One of the two sprites overlaps a portion of the playfield, too. During vBlank, the CLXDAT register is read and split into four 4-bit chunks. After that, the chunks are written into color registers 0 to 3 to make the bit-pattern visible. The test is carried out with different sprite numbers and different values in CLXCON. 

#### collision5s and collision5d

Like collosion5 without toggling between single-playfield and dual-playfield mode. collision5s draws solely in single-playfield mode and collision5d solely in dual-playfield mode.

#### sprites1 to sprites4

Draws sprite 0, 2, 4, and 6 in a distinct column each. Each sprite is repeated 4 times. In the bitplane area, the Copper is used to switch between single-playfield and dual-playfield mode. The test differ in the priority values written to BPLCON2. Inspect the reference pictures carefully. There a subtle differences which are hard to see at first glance. 

#### sprites5 to sprites7

Similar, with the playfield priority bits set to illegal values.

#### sprbpu1 and sprbpu2

Varies BPLCON0::BPU around the coordinates where the sprites are drawn. 

#### sprclip1 and sprclip2

Tests basic sprite clipping properties in lores and hires mode.

#### reenable

This test uses unusual coordinates letting the VSTOP match twice without letting VSTRT match in between.

#### multiplex1

Display the same sprite twice horizontally. Same trick as in R-Type II.

#### invcoord

Contais a couple of POS/CTL pairs with VSTRT unreachable and VSTRT > VSTOP.

#### termination1

Shows that Sprite DMA doesn't terminate on $0000/$0000 even if some books claim this.

#### manual1 and manual2

Draws sprites without enabling DMA by writing directly into POS, CTL, DATA, and DATB.

Dirk Hoffmann, 2019
