## Objective

Verify timing of the DDFSTART and DDSTOP registers.

#### ddftimcop1 - ddftimcop4

The Copper is utilized to modify DDFSTRT around the trigger cycle. 

#### ddftimcop5 - ddftimcop8

The Copper is utilized to write a value into DDFSTRT which is close to the current DMA cycle.

#### ddftimcpu1 - ddftimcpu8

Same as ddfcoptim1 - ddfcoptim8, but the modification is carried out by the CPU.


Dirk Hoffmann, 2022
