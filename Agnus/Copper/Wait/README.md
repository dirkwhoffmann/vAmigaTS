## Objective

This test suite verfies particular aspects of the WAIT command.

#### copwait1 and copwait2

Checks the behaviour of the WAIT command with waiting positions near it's own execution cycle. 

#### copwait3 and copwait4

Same as copwait1 and copwait2 with a fifth bitplane enabled.

#### copwait5 and copwait6

Checks the WAIT command with horizontal positions around 0 and $E2, respectively. 

#### copwait7 and copwait8

Same as copwait7 and copwait8 with a fifth bitplane enabled.

#### copwait9

Chains together multiple Waits with the same trigger coordinate.

#### waitblt1 and waitblt2

This test activates the Blitter and verifies the behaviour of the WAIT command in combination with the BFD (Blitter Finish Disable) bit cleared.

#### waitblt3 to waitblit5

Verifies the "WAIT for Blitter" behaviour with a blit crossing the vertical boundary. 


Dirk Hoffmann, 2019 - 2022
