## Objective

Verify timing of the DDFSTART and DDSTOP registers.

#### ddftimcop1 - ddftimcop4

The Copper is utilized to modify DDFSTRT around the trigger cycle. 

#### ddftimcop5 - ddftimcop8

The Copper is utilized to write a value into DDFSTRT which is close to the current DMA cycle.

#### ddftimcop9

The Copper is utilized to modify DDFSTRT around the trigger cycle. In this test, the existing value is written back. In the test picture, you'll notice a missing line. In this line, the write cycle matches the trigger cycle which causes neither the old nor the new value to match.

#### ddftimcpu1 - ddftimcpu8

Same as ddfcoptim1 - ddfcoptim8 with the modification being carried out by the CPU.

#### ddftimcpu9 - ddftimcpu15

Similiar to ddftimcop9 with the modification being carried out by the CPU.

Dirk Hoffmann, 2022
