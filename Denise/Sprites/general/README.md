 ## Objective

Verify basic sprite properties.

#### sprites1 to sprites4

This test draws sprite 0, 2, 4, and 6 in a distinct column each. Each sprite is repeated 4 times. In the bitplane area, the Copper is utilized to switch between single-playfield and dual-playfield mode. The tests differ in the priority values written to BPLCON2. Inspect the reference pictures carefully. There a subtle differences which are hard to see at first glance. 

#### sprites5 to sprites7

Similar to sprites1 to sprites4 with the playfield priority bits set to illegal values.

#### sprbpu1 and sprbpu2

Varies BPLCON0::BPU around the coordinates where the sprites are drawn. 

#### reenable

This test uses unusual coordinates letting VSTOP match twice without letting VSTRT match in between.

#### invcoord

Contais a couple of POS/CTL pairs with VSTRT unreachable and VSTRT > VSTOP.

#### termination1

Shows that sprite DMA doesn't terminate on $0000/$0000 even if some books claim so.

#### sprdat1 and sprdat2

Draws sprites via DMA. Utilizes the Copper to modify SPR4DATA and SPR4DATB before resp. after the sprite has been drawn. 


Dirk Hoffmann, 2019
