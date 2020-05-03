## Objective

To demonstrate how sprites can be drawn manually, without DMA.

#### manual1 and manual2

Draws sprites without enabling DMA by writing directly into POS, CTL, DATA, and DATB.

#### manual5

This test manually draws sprites 0 and 1 at the same horizontal coordinates. Using horizontal multiplexing, the sprites are repeated twice. The AT bit is changed between the two copies.

Dirk Hoffmann, 2019 - 2020
