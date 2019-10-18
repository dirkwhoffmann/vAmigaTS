## Objective

This test suite verifies various aspects of sprite DMA.

#### sprdma1 to sprdma3

Toggles the SPRDMA bit in DMACON at certain positions.

#### sprdma4

Keeps sprite DMA disabled at rasterline 25 (where sprite DMA usually starts) and enabled it later manually. The test shows that the sprite logic immediately starts reading sprite data. This means that SPRxPOS and SPRxCTL have to be set manually to get the image right.

#### sprdma5

Same idea as sprdma4, but a bit more sophisticated.

#### sprdma6

Fiddles around with invalid sprite end positions.

Dirk Hoffmann, 2019
