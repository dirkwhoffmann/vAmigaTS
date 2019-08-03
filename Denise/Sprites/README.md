## Objective

This test suite verfies some basic sprite properties.

#### attached1

Draws two column of attached sprites (sprites with the AT bit set).

#### sprites1

Draws sprite 0, 2, 4, and 6 in a distinct column each. Each sprite is repeated 4 times. In the bitplane area, the Copper is used to switch between single-playfield and dual-playfield mode. 

#### sprites2

Same as sprites1 with the PF2PRI bit set in BPLCON2. Look carefully at the reference pictures. There a subtle differences which are hard to see at first glance. 



Dirk Hoffmann, 2019