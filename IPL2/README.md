## Objective

All tests in this test suite utilize the UART TBE interrupt to test IPL timing of CPU instructions. Using the TBE interrupt is more fine grained than the Copper interrupt approach which is taken by the tests in the IPL directory. Each test image consists of five sections. In the first two sections, no bitplane DMA is enabled. In the lower three sections, the instruction under test is run through a DMA area with 4, 5, and 6 bitplanes enabled, respectively. 


Dirk Hoffmann, 2022