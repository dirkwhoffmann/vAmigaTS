## Objective

Tests various ways to halt and reactivate the Copper.

#### halt1 and halt2

Reactivates a waiting Copper by writing into COPJMP1.

#### halt3

Reactivates a halted Copper by writing into COPJMP1. The Copper was halted by writing into an OCS register with a low address and the CDANG bit cleared.

#### halt4

Sets the CDANG bit and checks whether the Copper is halted when writing into an OCS register with a low address. The Copper will halt on OCS machines only (one color bar). It won't halt on ECS machines (two color bars).


Dirk Hoffmann, 2020
