## Objective

This test suite verifies various aspects of sprite DMA.

#### blocked1

Related to GitHub issue #799. Sprite DMA is blocked temporarily by expanding the DDF window. The test demonstrates that the old register value is kept during the blocking period. 

#### blocked2

Similar to blocked1. The last sprite line lies withing the disabled DMA area. As a result, the sprite is not disarmed.

#### blocked3

Similar to blocked1 with 2 bitplanes enabled over a larger area. This blocks the first sprite cycle during the whole sprite drawing range. 

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
