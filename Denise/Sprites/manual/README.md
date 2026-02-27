## Objective

To demonstrate how sprites can be drawn manually, without DMA.

#### manual1 and manual2

Draws sprites without enabling DMA by writing directly into POS, CTL, DATA, and DATB.

#### manual5

This test manually draws sprites 0 and 1 at the same horizontal coordinates. Using horizontal multiplexing, the sprites are repeated twice. The AT bit is changed between the two copies.

#### manual6

This test replays some instructions from the Copper list of "Brian the Lion". It is very sensitive to sprite register timing. 

#### vblen1

This test isolates a bug in vAmiga discussed in GitHub issue #967. By manually setting SPRxCTL and SPRxPOS, it is possible in vAmiga to enable sprite DMA within the VBLANK area. If the sprite DMA bit in DMACON is disabled during the sprite fetch line (0x1A), sprite DMA remains enabled, causing sprite rendering to begin immediately after VBLANK.

Dirk Hoffmann, 2019 - 2026
