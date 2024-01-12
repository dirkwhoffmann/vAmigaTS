## Objective

This test suite verifies various aspects of sprite DMA.

#### interfere*n*

Theses tests manually modify SPRxCTL and SPRxPOS inside the sprite DMA area to see how competing register modifications are resolved. 

#### interfere*n*b

Same as interfere*n* with the register writes happening two DMA cycles later.

#### sprdma1 to sprdma3

Toggles the SPRDMA bit in DMACON at certain positions.

#### sprdma4

Keeps sprite DMA disabled at rasterline 25 (where sprite DMA usually starts) and enabled it later manually. The test shows that the sprite logic immediately starts reading sprite data. This means that SPRxPOS and SPRxCTL have to be set manually to get the image right.

#### sprdma5

Same idea as sprdma4, but a bit more sophisticated.

#### sprdma6

Fiddles around with invalid sprite end positions.

#### sprdma7

This test uses DMA to read SPR2POS and SPR2CTL. It then disables DMA and reenables it in the middle of vertical range spanned by the sprite. 

#### sprdma8

More DMA on / off fun

#### sprdma9

Rewrites the current values of SPRxPOS and SPRxCTL by the Copper. For the first two sprites, the rewrites happen before the DMA sprite cycles. For the remaining two sprites they happen afterwards.

#### sprdma10

Draws sprites via DMA and uses the Copper to interfere. The SPRxCTL and SPRxPOS are written manually at certain locations to see how DMA is affected by the manual writes. 

#### sprdma11

Sprite DMA is on all the time. The Copper is utilized to change SPRxPOS and SPRxCTL at various locations.

#### sprdma12

Modified SPRxCTL at the end of a rasterline, just before the next control word pair would be read. 

#### sprdma18

Shows that sprite DMA can be switched off manually by writing into SPRxCTL under certain conditions.

#### sprdma19

Enables sprite DMA manually by writing into SPRxCTL with a matching vertical value.


Dirk Hoffmann, 2019
