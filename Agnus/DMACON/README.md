## Objective

Verify timing of the BMPEN line (bitmap enable, see Agnus schematics).

#### bploncop1 - bploncop4

The Copper is utilized to modify the BPLEN bit in DMACON around the trigger cycle. 

#### bploncpu1 - bploncpu4

Same as bploncop1 - bploncop4 with the modification being carried out by the CPU.

#### spren1, spren2

Draw a couple of sprites and utilizes the Copper to switch sprite DMA off or on around the sprite DMA cylces. 

#### spren3, spren4

Similar to spren1 and spren2, but the writes to DMACON are carried out by the CPU. 


Dirk Hoffmann, 2022
